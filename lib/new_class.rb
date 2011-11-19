require "new_class/version"

module NewClass

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def new_class(variables = {}, name = nil)
      Class.new(self).tap do |klass|
        klass.instance_variable_set :@name, name || self.name
        klass.instance_variable_set :@variables, variables
        klass.extend NewClassMethods
        klass.defined if klass.respond_to?(:defined)
      end
    end

    module NewClassMethods
      def name
        @name || super
      end
      alias :to_s :name

      def variable(key)
        (@variables || {})[key]
      end
    end
  end

end