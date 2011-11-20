require "new_class/version" unless defined?(NewClass::VERSION)

module NewClass

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def new_class(variables = {}, name = nil)
      Class.new(self).tap do |klass|
        klass.extend NewClassMethods
        klass.extend MethodMissing
        klass.send :include, NewClassInstanceMethods
        klass.send :include, MethodMissing
        klass.instance_variable_set :@name, name || self.name
        klass.instance_variable_set :@variables, variables.inject({}){|h, (k, v)| h.merge k.to_sym => v}
        klass.defined if klass.respond_to?(:defined)
      end
    end

    module NewClassMethods
      def name
        @name || super
      end
      alias :to_s :name

      attr_reader :variables
    end

    module NewClassInstanceMethods
      def variables
        self.class.variables
      end
    end

    module MethodMissing
      def method_missing(method, *args)
        variables.include?(key = method.to_sym) ? define_method(key){ variables[key] }.call : super
      end

      def respond_to?(symbol, include_private = false)
        variables.include?(symbol.to_sym) || super
      end
    end
  end

end