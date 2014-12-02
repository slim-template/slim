require 'helper'

class TestSlimThreadOptions < TestSlim
  def test_thread_options
    source = %q{p.test}

    assert_html '<p class="test"></p>', source
    assert_html "<p class='test'></p>", source, attr_quote: "'"

    Slim::Engine.with_options(attr_quote: "'") do
      assert_html "<p class='test'></p>", source
      assert_html '<p class="test"></p>', source, attr_quote: '"'
    end

    assert_html '<p class="test"></p>', source
    assert_html "<p class='test'></p>", source, attr_quote: "'"
  end
end
