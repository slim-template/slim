class LiterateTest
  def initialize(file)
    lines = File.readlines(file)
    exp = parse(lines)
    @code = "require 'helper'\n\n" + compile(exp, "  include Helper\n\n")
  end

  def parse(lines)
    stack = []
    until lines.empty?
      line = lines.shift
      case line
      when /\A(#+)\s*(.*)\Z/
        while stack.size >= $1.size
          stack.pop
        end
        exp = [:section, $2]
        stack.last << exp if stack.last
        stack << exp
      when /\A~{3,}\s*(\w+)\s\Z/
        lang = $1
        block = []
        until lines.empty?
          line = lines.shift
          case line
          when /\A~{3,}\Z/
            break
          when /\A.*\Z/
            block << $&
          end
        end
        stack.last << [lang.to_sym, block.join("\n")]
      when /\A\s+\Z/
      when /\A.*\Z/
        stack.last << [:comment, $&]
      end
    end
    stack.first
  end

  def compile(exp, preamble = '')
    case exp.first
    when :section
      begin
        old_options = @options
        raise 'Section inside of test case' if @in_testcase
        type, title, *rest = exp
        rest = rest.map {|exp| compile(exp) }.join("\n").gsub("\n", "\n  ")
        "describe #{title.inspect} do\n#{preamble}  #{rest}\nend\n"
      ensure
        @options = old_options
      end
    when :comment
      "#{@in_testcase ? '  ' : ''}# #{exp.last}"
    when :slim
      puts exp.last
      raise 'Two slim blocks inside test case' if @in_testcase
      @in_testcase = true
      "it 'should render' do\n  slim = #{exp.last.inspect}"
    when :html
      raise 'HTML block must come after slim block' unless @in_testcase
      @in_testcase = false
      result =  "  html = #{exp.last.inspect}\n"
      result << "  options = {#{@options}}\n" if @options
      result << "  assert_html(html, slim#{@options && ', options'})\nend\n"
    when :options
      raise 'Options set inside test case' if @in_testcase
      @options = exp.last
      "# #{@options.gsub("\n", "\n# ")}"
    end
  end

  def run
    puts @code
    eval(@code)
  end
end

LiterateTest.new(File.join(File.dirname(__FILE__), 'TESTS.md')).run
