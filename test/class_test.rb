require File.expand_path("../test_helper", __FILE__)

class ClassTest < Test::Unit::TestCase

  context "A class" do
    setup do
      class A
      end
      class B
        include NewClass
      end
    end

    context "when having included NewClass" do
      should "respond to new_class" do
        assert !A.respond_to?(:new_class)
        assert B.respond_to?(:new_class)
      end

      context "and having a superclass" do
        setup do
          class Greeter
            @@translations = {}
            def self.translate(language, translation)
              @@translations[language.to_sym] = translation
            end
            def self.translation(language)
              @@translations[language.to_sym]
            end
            translate :english, "Hi, I am a {kind}"
            def greet(language = :english)
              self.class.translation(language).gsub("{kind}", self.class.name.match(/[^:]+$/).to_s)
            end
          end
          class C < Greeter
            include NewClass
            def self.defined
              (variable(:translations) || {}).each do |language, translation|
                translate language, translation
              end
            end
          end
        end

        should "behave as expected" do
          assert_equal "Hi, I am a C", C.new.greet
        end

        should "be able to return a new class" do
          assert_equal Class, C.new_class.class
        end

        context "the new class" do
          should "have @name and @variables defined" do
            assert C.new_class.instance_variable_defined?(:@name)
            assert_equal(C.name, C.new_class.instance_variable_get(:@name))
            assert_equal("D", C.new_class({}, "D").instance_variable_get(:@name))

            assert C.new_class.instance_variable_defined?(:@variables)
            assert_equal({}, C.new_class.instance_variable_get(:@variables))
            assert_equal({}, C.new_class({}, "D").instance_variable_get(:@variables))
          end

          should "respond to variable" do
            assert !C.respond_to?(:variable)

            assert C.new_class({:foo => "bar"}).respond_to?(:variable)
            assert C.new_class({:foo => "bar"}, "D").respond_to?(:variable)

            assert_equal "bar", C.new_class({:foo => "bar"}).variable(:foo)
            assert_equal "bar", C.new_class({:foo => "bar"}, "D").variable(:foo)
          end

          should "be able to create instances" do
            assert C.new_class.new.is_a?(C)
            assert_equal C.name, C.new_class.new.class.name
            assert_equal C.name, C.new_class.new.class.to_s
            assert_equal "Hi, I am a C", C.new_class.new.greet

            assert C.new_class({}, "D").new.is_a?(C)
            assert_equal "D", C.new_class({}, "D").new.class.name
            assert_equal "D", C.new_class({}, "D").new.class.to_s
            assert_equal "Hi, I am a D", C.new_class({}, "D").new.greet
          end

          should "have @defined called" do
            klass = C.new_class({:translations => {:dutch => "Hallo, ik ben een {kind}"}})
            assert_equal "Hi, I am a C", klass.new.greet
            assert_equal "Hallo, ik ben een C", klass.new.greet(:dutch)

            klass = C.new_class({:translations => {:dutch => "Hallo, ik ben een {kind}"}}, "D")
            assert_equal "Hi, I am a D", klass.new.greet
            assert_equal "Hallo, ik ben een D", klass.new.greet(:dutch)
          end
        end
      end
    end
  end

end