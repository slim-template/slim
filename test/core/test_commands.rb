require 'helper'
require 'open3'
require 'tempfile'

class TestSlimCommands < Minitest::Test
  # nothing complex
  STATIC_TEMPLATE = "p Hello World!\n"

  # requires a `name` variable to exist at render time
  DYNAMIC_TEMPLATE = "p Hello \#{name}!\n"

  # a more complex example
  LONG_TEMPLATE = "h1 Hello\np\n  | World!\n  small Tiny text"

  # exception raising example
  EXCEPTION_TEMPLATE = '- raise NotImplementedError'

  def test_option_help
    out, err = exec_slimrb '--help'

    assert err.empty?
    assert_match %r{Show this message}, out
  end

  def test_option_version
    out, err = exec_slimrb '--version'

    assert err.empty?
    assert_match %r{\ASlim #{Regexp.escape Slim::VERSION}$}, out
  end

  def test_render
    prepare_common_test STATIC_TEMPLATE do |out, err|
      assert err.empty?
      assert_equal "<p>Hello World!</p>\n", out
    end
  end

  # superficial test, we don't want to test Tilt/Temple
  def test_compile
    prepare_common_test STATIC_TEMPLATE, '--compile' do |out, err|
      assert err.empty?
      assert_match %r{\"<p>Hello World!<\/p>\".freeze}, out
    end
  end

  def test_erb
    prepare_common_test DYNAMIC_TEMPLATE, '--erb' do |out, err|
      assert err.empty?
      assert_equal "<p>Hello <%= ::Temple::Utils.escape_html((name)) %>!</p>\n", out
    end
  end

  def test_rails
    prepare_common_test DYNAMIC_TEMPLATE, '--rails' do |out, err|
      assert err.empty?

      if Gem::Version.new(Temple::VERSION) >= Gem::Version.new('0.9')
        assert out.include? %Q{@output_buffer = output_buffer || ActionView::OutputBuffer.new;}
      else
        assert out.include? %Q{@output_buffer = ActiveSupport::SafeBuffer.new;}
      end
      assert out.include? %Q{@output_buffer.safe_concat(("<p>Hello ".freeze));}
      assert out.include? %Q{@output_buffer.safe_concat(((::Temple::Utils.escape_html((name))).to_s));}
      assert out.include? %Q{@output_buffer.safe_concat(("!</p>".freeze));}
    end
  end

  def test_pretty
    prepare_common_test LONG_TEMPLATE, '--pretty' do |out, err|
      assert err.empty?
      assert_equal "<h1>\n  Hello\n</h1>\n<p>\n  World!<small>Tiny text</small>\n</p>\n", out
    end
  end

  def test_locals_json
    data = '{"name":"from slim"}'
    prepare_common_test DYNAMIC_TEMPLATE, '--locals', data do |out, err|
      assert err.empty?
      assert_equal "<p>Hello from slim!</p>\n", out
    end
  end

  def test_locals_yaml
    data = "name: from slim"
    prepare_common_test DYNAMIC_TEMPLATE, '--locals', data do |out, err|
      assert err.empty?
      assert_equal "<p>Hello from slim!</p>\n", out
    end
  end

  def test_locals_hash
    data = '{name:"from slim"}'
    prepare_common_test DYNAMIC_TEMPLATE, '--locals', data do |out, err|
      assert err.empty?
      assert_equal "<p>Hello from slim!</p>\n", out
    end
  end

  def test_require
    with_tempfile 'puts "Not in slim"', 'rb' do |lib|
      prepare_common_test STATIC_TEMPLATE, '--require', lib, stdin_file: false, file_file: false do |out, err|
        assert err.empty?
        assert_equal "Not in slim\n<p>Hello World!</p>\n", out
      end
    end
  end

  def test_error
    prepare_common_test EXCEPTION_TEMPLATE, stdin_file: false do |out, err|
      assert out.empty?
      assert_match %r{NotImplementedError: NotImplementedError}, err
      assert_match %r{Use --trace for backtrace}, err
    end
  end

  def test_trace_error
    prepare_common_test EXCEPTION_TEMPLATE, '--trace', stdin_file: false do |out, err|
      assert out.empty?
      assert_match %r{bin\/slimrb}, err
    end
  end

private

  # Whether you call slimrb with a file argument or pass the slim content
  # via $stdin; whether you want the output written to $stdout or into
  # another file given as argument, the output is the same.
  #
  # This method prepares a test with this exact behaviour:
  #
  # It yields the tupel (out, err) once after the `content` was passed
  # in via $stdin and once it was passed as a (temporary) file argument.
  #
  # In effect, this method executes a test (given as block) 4 times:
  #
  # 1. read from $stdin, write to $stdout
  # 2. read from file, write to $stdout
  # 3. read from $stdin, write to file
  # 4. read from file, write to file
  def prepare_common_test(content, *args)
    options = Hash === args.last ? args.pop : {}

    # case 1. $stdin → $stdout
    unless options[:stdin_stdout] == false
      out, err = exec_slimrb(*args, '--stdin') do |i|
        i.write content
      end
      yield out, err
    end

    # case 2. file → $stdout
    unless options[:file_stdout] == false
      with_tempfile content do |in_file|
        out, err = exec_slimrb(*args, in_file)
        yield out, err
      end
    end

    # case 3. $stdin → file
    unless options[:stdin_file] == false
      with_tempfile content do |out_file|
        _, err = exec_slimrb(*args, '--stdin', out_file) do |i|
          i.write content
        end
        yield File.read(out_file), err
      end
    end

    # case 3. file → file
    unless options[:file_file] == false
      with_tempfile '' do |out_file|
        with_tempfile content do |in_file|
          _, err = exec_slimrb(*args, in_file, out_file) do |i|
            i.write content
          end
          yield File.read(out_file), err
        end
      end
    end
  end

  # Calls bin/slimrb as a subprocess.
  #
  # Yields $stdin to the caller and returns a tupel (out,err) with the
  # contents of $stdout and $stderr.
  #
  # (I'd like to use Minitest::Assertions#capture_subprecess_io here,
  # but then there's no way to insert data via $stdin.)
  def exec_slimrb(*args)
    out, err = nil, nil

    Open3.popen3 'ruby', 'bin/slimrb', *args do |i,o,e,t|
      yield i if block_given?
      i.close
      out, err = o.read, e.read
    end

    return out, err
  end

  # Creates a temporary file with the given content and yield the path
  # to this file. The file itself is only available inside the block and
  # will be deleted afterwards.
  def with_tempfile(content=nil, extname='slim')
    f = Tempfile.new ['slim', ".#{extname}"]
    if content
      f.write content
      f.flush # ensure content is actually saved to disk
      f.rewind
    end

    yield f.path
  ensure
    f.close
    f.unlink
  end

end
