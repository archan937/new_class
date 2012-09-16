require File.expand_path("../../test_helper", __FILE__)

module Unit
  class TestClass < MiniTest::Unit::TestCase

    describe "A class having included NewClass" do
      before do
        class A
        end
        class B
          include NewClass
        end
      end

      it "should respond to new_class" do
        assert !A.respond_to?(:new_class)
        assert B.respond_to?(:new_class)
      end

      it "should be able to return a new class" do
        assert_equal Class, B.new_class.class
      end

      describe "the new class" do
        before do
          @B = B.new_class
          @C = B.new_class({}, "C")
        end

        it "should respond to _name and _variables" do
          assert !A.respond_to?(:_name)
          assert !A.respond_to?(:_variables)

          assert_equal(B.name, @B._name)
          assert_equal({}, @B._variables)

          assert_equal("C", @C._name)
          assert_equal({}, @C._variables)
        end

        it "should override method_missing and respond_to?" do
          klass = B.new_class "foo" => "bar"

          assert klass.respond_to?(:foo)
          assert_equal "bar", klass.foo

          assert klass.new.respond_to?(:foo)
          assert_equal "bar", klass.new.foo

          assert !klass.respond_to?(:bar)
          assert_raises NoMethodError do
            klass.bar
          end

          assert !klass.new.respond_to?(:bar)
          assert_raises NoMethodError do
            klass.new.bar
          end
        end

        it "should be able to create instances" do
          assert @B.new.is_a?(B)
          assert_equal B.name, @B.new.class.name
          assert_equal B.name, @B.new.class.to_s

          assert @C.new.is_a?(B)
          assert_equal "C", @C.new.class.name
          assert_equal "C", @C.new.class.to_s
        end
      end

      describe "and having a superclass" do
        before do
          class Greeter
            @@translations = {}

            def self.translate(language, translation)
              @@translations[language.to_sym] = translation
            end
            def self.translation(language)
              @@translations[language.to_sym]
            end
            def greet(language = :english)
              self.class.translation(language).gsub("{class}", self.class.name.match(/[^:]+$/).to_s)
            end

            translate :english, "Hi, I am a {class}"
          end
          class C < Greeter
            include NewClass
            def self.defined
              translations.each do |language, translation|
                translate language, translation
              end
            end
          end
        end

        it "should behave as expected" do
          assert_equal "Hi, I am a C", C.new.greet
        end

        it "should have defined called" do
          @C = C.new_class({:translations => {:dutch => "Hallo, ik ben een {class}"}})
          @D = C.new_class({:translations => {:dutch => "Hallo, ik ben een {class}"}}, "D")

          assert_equal "Hi, I am a C", @C.new.greet
          assert_equal "Hallo, ik ben een C", @C.new.greet(:dutch)

          assert_equal "Hi, I am a D", @D.new.greet
          assert_equal "Hallo, ik ben een D", @D.new.greet(:dutch)
        end
      end
    end

  end
end