require "new_class/version" unless defined?(NewClass::VERSION)

module NewClass

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def when_defined(&block)
      @when_defined = block
    end

    def new_class(variables = {}, name = nil)
      Class.new(self).tap do |klass|
        klass.extend NewClassMethods
        klass.send :include, NewClassInstanceMethods
        klass.instance_variable_set :@name, name || self.name
        klass.instance_variable_set :@variables, variables
        klass.instance_eval &@when_defined if @when_defined
      end
    end

    module NewClassMethods
      def name
        @name || super
      end
      alias :to_s :name

      def var(key)
        (@variables || {})[key]
      end
    end

    module NewClassInstanceMethods
      def var(key)
        self.class.var(key)
      end
    end
  end

end