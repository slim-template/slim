require 'temple'

class LiterateTest < Temple::Engine
  class Parser < Temple::Parser
    def call(lines)
      stack = [[:multi]]
      until lines.empty?
        case lines.shift
        when /\A(#+)\s*(.*)\Z/
          stack.pop(stack.size - $1.size)
          block = [:multi]
          stack.last << [:section, $2, block]
          stack << block
        when /\A~{3,}\s*(\w+)\s*\Z/
          lang = $1
          code = []
          until lines.empty?
            case lines.shift
            when /\A~{3,}\s*\Z/
              break
            when /\A.*\Z/
              code << $&
            end
          end
          stack.last << [lang.to_sym, code.join("\n")]
        when /\A\s*\Z/
        when /\A\s*(.*?)\s*Z/
          stack.last << [:comment, $1]
        end
      end
      stack.first
    end
  end

  class Compiler < Temple::Filter
    def call(exp)
      @opts, @in_testcase = {}, false
      "require 'helper'\n\n#{compile(exp)}"
    end

    def on_section(title, body)
      old_opts = @opts.dup
      raise Temple::FilterError, 'New section between slim and html block' if @in_testcase
      "describe #{title.inspect} do\n  #{compile(body).gsub("\n", "\n  ")}\nend\n"
    ensure
      @opts = old_opts
    end

    def on_multi(*exps)
      exps.map {|exp| compile(exp) }.join("\n")
    end

    def on_comment(text)
      "#{@in_testcase ? '  ' : ''}# #{text}"
    end

    def on_slim(code)
      raise Temple::FilterError, 'Slim block must be followed by html block' if @in_testcase
      @in_testcase = true
      "it 'should render' do\n  slim = #{code.inspect}"
    end

    def on_html(code)
      raise Temple::FilterError, 'Html block must be preceded by slim block' unless @in_testcase
      @in_testcase = false
      result =  "  html = #{code.inspect}\n".dup
      if @opts.empty?
        result << "  _(render(slim)).must_equal html\nend\n"
      else
        result << "  options = #{@opts.inspect}\n  _(render(slim, options)).must_equal html\nend\n"
      end
    end

    def on_options(code)
      raise Temple::FilterError, 'Options set inside test case' if @in_testcase
      @opts.update(eval("{#{code}}"))
      "# #{code.gsub("\n", "\n# ")}"
    end

    def on(*exp)
      raise Temple::InvalidExpression, exp
    end
  end

  use Parser
  use Compiler
  use(:Evaluator) {|code| eval(code) }
end

Dir.glob(File.join(File.dirname(__FILE__), '*.md')) do |file|
  LiterateTest.new.call(File.readlines(file))
end
