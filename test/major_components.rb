require_relative "test_helper"

class TestMajorComponentsReader < MiniTest::Unit::TestCase

  def test_major_components_gettter
    getter = BomGetter.new
    attrs = getter.get_major_component  6991,  'sVrXIqos994v0pkehHI28Q=='
    assert_equal 6, attrs.size
  end

end