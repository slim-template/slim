require 'helper'

class TestSlimChainManipulation < TestSlim
  def test_replace
    source = %q{
p Test
}
    chain = proc do |engine|
      engine.replace(:Pretty, :ReplacementFilter) do |exp|
        [:dynamic, '1+1']
      end
    end

    assert_html '2', source, :chain => chain
  end

  def test_before
    source = %q{
p Test
}
    chain = proc do |engine|
      engine.before(Slim::Parser, :WrapInput) do |input|
        "p Header\n#{input}\np Footer"
      end
    end

    assert_html '<p>Header</p><p>Test</p><p>Footer</p>', source, :chain => chain
  end

  def test_after
    source = %q{
p Test
}
    chain = proc do |engine|
      engine.after(Slim::Parser, :ReplaceParsedExp) do |exp|
        [:slim, :output, false, '1+1', [:multi]]
      end
    end

    assert_html '2', source, :chain => chain
  end
end
