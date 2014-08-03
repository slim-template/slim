require 'helper'
require 'slim/include'

class TestSlimInclude < TestSlim
  def test_include
    source = %q{
a: include slimfile
b: include textfile
c: include slimfile.slim
d: include subdir/test
}
    assert_html '<a>slim1recslim2</a><b>1+2=3</b><c>slim1recslim2</c><d>subdir</d>', source, :include_dirs => [File.expand_path('files', File.dirname(__FILE__))]
  end
end
