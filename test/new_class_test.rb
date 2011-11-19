require File.expand_path("../test_helper", __FILE__)

class NewClassTest < Test::Unit::TestCase

  context "NewClass module" do
    should "be defined" do
      assert defined?(NewClass)
    end
  end

end