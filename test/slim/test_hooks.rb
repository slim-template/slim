require 'helper'

class TestSlimHooks < TestSlim
  def test_before_compile_hook
    source = %q{
p Test
}
    assert_html '2', source, :before_compile => proc {|exp| [:slim, :output, false, '1+1', [:multi]] }
  end

  def test_before_html_hook
    source = %q{
p Test
}
    assert_html '2', source, :before_html => proc {|exp| [:dynamic, '1+1'] }
  end

  def test_before_optimize_hook
    source = %q{
p Test
}
    assert_html '2', source, :before_optimize => proc {|exp| [:dynamic, '1+1'] }
  end
end
