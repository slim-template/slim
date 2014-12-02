require 'helper'

class TestSlimTabs < TestSlim

  def teardown
    Slim::Engine.set_options tabsize: 4
  end

  def test_single_tab1_expansion

    Slim::Engine.set_options tabsize: 1

    source = %Q{
|
\t0
 \t1
  \t2
   \t3
    \t4
     \t5
      \t6
       \t7
        \t8
}

    result = %q{
0
 1
  2
   3
    4
     5
      6
       7
        8
}.strip

    assert_html result, source
  end

  def test_single_tab4_expansion

    Slim::Engine.set_options tabsize: 4

    source = %Q{
|
\t0
 \t1
  \t2
   \t3
    \t4
     \t5
      \t6
       \t7
        \t8
}

    result = %q{
0
1
2
3
    4
    5
    6
    7
        8
}.strip

    assert_html result, source
  end

  def test_multi_tab1_expansion

    Slim::Engine.set_options tabsize: 1

    source = %Q{
|
\t0
 \t\t1
 \t \t2
 \t  \t3
 \t   \t4
  \t\t1
  \t \t2
  \t  \t3
  \t   \t4
   \t\t1
   \t \t2
   \t  \t3
   \t   \t4
    \t\t1
    \t \t2
    \t  \t3
    \t   \t4
}

    result = %q{
0
  1
   2
    3
     4
   1
    2
     3
      4
    1
     2
      3
       4
     1
      2
       3
        4
}.strip

    assert_html result, source
  end

  def test_multi_tab4_expansion

    Slim::Engine.set_options tabsize: 4

    source = %Q{
|
\t0
 \t\t1
 \t \t2
 \t  \t3
 \t   \t4
  \t\t1
  \t \t2
  \t  \t3
  \t   \t4
   \t\t1
   \t \t2
   \t  \t3
   \t   \t4
    \t\t1
    \t \t2
    \t  \t3
    \t   \t4
}

    result = %q{
0
    1
    2
    3
    4
    1
    2
    3
    4
    1
    2
    3
    4
        1
        2
        3
        4
}.strip

    assert_html result, source
  end

end
