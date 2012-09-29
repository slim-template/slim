require 'temple'

class LiterateTest < Temple::Engine
  class Parser < Temple::Parser
    def call(lines)
      stack = [[:multi]]
      until lines.empty?
        case lines.shift
        when /\A(#+)\s*(.*)\Z/
          while stack.size > $1.size
            stack.pop
          end
          block = [:multi]
          stack.last << [:section, $2, block]
          stack << block
        when /\A~{3,}\s*(\w+)\s*\Z/
          lang = $1
          block = []
          until lines.empty?
            case lines.shift
            when /\A~{3,}\Z/
              break
            when /\A.*\Z/
              block << $&
            end
          end
          stack.last << [lang.to_sym, block.join("\n")]
        when /\A\s*\Z/
        when /\A.*\Z/
          stack.last << [:comment, $&]
        end
      end
      stack.first
    end
  end

  class Compiler < Temple::Filter
    def call(exp)
      @opts = nil
      @in_testcase = nil
      @level = 0
      "require 'helper'\n\n" << compile(exp)
    end

    def on_section(title, body)
      old_options = @opts
      @level += 1
      raise 'Section inside of test case' if @in_testcase
      result = "describe #{title.inspect} do\n  "
      result << "include Helper\n  " if @level == 1
      result << compile(body).gsub("\n", "\n  ") << "\nend\n"
    ensure
      @opts = old_options
      @level -= 1
    end

    def on_multi(*exps)
      exps.map {|exp| compile(exp) }.join("\n")
    end

    def on_comment(text)
      "#{@in_testcase ? '  ' : ''}# #{text}"
    end

    def on_slim(code)
      raise 'Two slim blocks inside test case' if @in_testcase
      @in_testcase = true
      "it 'should render' do\n  slim = #{code.inspect}"
    end

    def on_html(code)
      raise 'HTML block must come after slim block' unless @in_testcase
      @in_testcase = false
      result =  "  html = #{code.inspect}\n"
      result << "  options = {#{@opts}}\n" if @opts
      result << "  assert_html(html, slim#{@opts && ', options'})\nend\n"
    end

    def on_options(code)
      raise 'Options set inside test case' if @in_testcase
      @opts = code
      "# #{@opts.gsub("\n", "\n# ")}"
    end
  end

  use Parser
  use Compiler
  use(:Evaluator) {|code| eval(code) }
end

LiterateTest.new.call(File.readlines(File.join(File.dirname(__FILE__), 'TESTS.md')))
