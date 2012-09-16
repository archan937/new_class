require File.expand_path("../../test_helper", __FILE__)

module Unit
  class TestNewClass < MiniTest::Unit::TestCase

    describe "NewClass module" do
      it "should be defined" do
        assert defined?(NewClass)
      end
    end

  end
end