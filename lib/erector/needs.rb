module Erector
  module Needs
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Class method by which widget classes can declare that they need certain
      # parameters. If needed parameters are not passed in to #new, then an
      # exception will be thrown (with a hopefully useful message about which
      # parameters are missing). This is intended to catch silly bugs like
      # passing in a parameter called 'name' to a widget that expects a
      # parameter called 'title'.
      #
      # You can also declare default values for parameters using hash syntax.
      # You can put #needs declarations on multiple lines or on the same line;
      # the only caveat is that if there are default values, they all have to be
      # at the end of the line (so they go into the magic hash parameter).
      #
      # If a widget has no #needs declaration then it will accept any
      # combination of parameters just like normal. If a widget wants to declare
      # that it takes no parameters, use the special incantation "needs nil"
      # (and don't declare any other needs, or kittens will cry).
      #
      # Usage:
      #    class FancyForm < Erector::Widget
      #      needs :title, :show_okay => true, :show_cancel => false
      #      ...
      #    end
      #
      # That means that
      #   FancyForm.new(:title => 'Login')
      # will succeed, as will
      #   FancyForm.new(:title => 'Login', :show_cancel => true)
      # but
      #   FancyForm.new(:name => 'Login')
      # will fail.
      #
      def needs(*args)
        args.each do |arg|
          (@needs ||= []) << (arg.nil? ? nil : (arg.is_a? Hash) ? arg : arg.to_sym)
        end
      end

      def get_needs
        @needs ||= []

        ancestors[1..-1].inject(@needs.dup) do |needs, ancestor|
          needs.push(*ancestor.get_needs) if ancestor.respond_to?(:get_needs)
          needs
        end
      end

      def get_needed_variables
        get_needs.map{|need| need.is_a?(Hash) ? need.keys : need}.flatten
      end

      def get_needed_defaults
        get_needs.inject({}) do |defaults, need|
          defaults = need.merge(defaults) if need.is_a? Hash
          defaults
        end
      end
    end

    def needed
      @needed ||= self.class.get_needed_variables
    end

    def needed_defaults
      @needed_defaults ||= self.class.get_needed_defaults
    end

    def has_needs?
      !needed.empty?
    end

    def unneeded?(name)
      has_needs? && !needed.include?(name)
    end

    def assign_instance_variables(instance_variables)
      super

      assigned = instance_variables.keys

      # set variables with default values
      needed_defaults.each do |name, value|
        unless assigned.include?(name)
          assign_instance_variable(name, value)
          assigned << name
        end
      end

      missing = needed - assigned
      unless missing.empty? || missing == [nil]
        raise "Missing parameter#{missing.size == 1 ? '' : 's'}: #{missing.join(', ')}"
      end
    end

    def assign_instance_variable(name, value)
      if unneeded?(name)
        raise "Unknown parameter '#{name}'. #{self.class.name} accepts only #{needed.join(', ')}"
      end

      super
    end
  end
end