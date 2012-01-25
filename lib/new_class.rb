require "active_support/core_ext/class/attribute"
require "active_support/concern"
require "new_class/version" unless defined?(NewClass::VERSION)

module NewClass

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def new_class(variables = {}, name = nil)
      Class.new(self).tap do |klass|
        klass.send :include, Concerns, MethodMissing
        klass.extend MethodMissing
        klass._name = name || self.name
        klass._variables = variables.inject({}){|h, (k, v)| h.merge k.to_sym => v}
        klass.defined if klass.respond_to?(:defined)
      end
    end

    module Concerns
      extend ActiveSupport::Concern
      included do
        class_attribute :_name, :_variables
      end
      module ClassMethods
        def name
          _name || super
        end
        alias :to_s :name
      end

      def _variables
        self.class._variables
      end
    end

    module MethodMissing
      def method_missing(method, *args)
        _variables.include?(key = method.to_sym) ? _variables[key] : super
      end
      def respond_to?(symbol, include_private = false)
        _variables.include?(symbol.to_sym) || super
      end
    end
  end

end