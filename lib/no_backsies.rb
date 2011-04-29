# NoBacksies module ecapsulates all supported callback mixins.
#
# NoBackseis::Callbacks can be mixed-in and all supported callbacks will
# be applied to the class or module. 
# 
#   class Y
#     include NoBacksies::Callbacks
#
#     def self.list
#       @list ||= []
#     end
#
#     callback :method_added do |method|
#       list << method
#     end
#
#     def foo; end
#     def bar; end
#   end
#
#   Y.list.assert #=> [:foo, :bar]
#
# Using callbacks can easily lead to infinite loops. NoBacksies makes it
# easier to control callback expression via the #callback_expression
# method.
#
#   class Z
#     include NoBacksies::Callbacks
#
#     def self.list
#       @list ||= []
#     end
#
#     callback :method_added do |method|
#       callback_expression :method_added=>false do
#         define_method("#{method}!") do
#           send(method) + "!"
#         end
#       end
#     end
#
#     def foo; "foo"; end
#     def bar; "bar"; end
#   end
#
#   y = Y.new
#   y.foo! #=> "foo!"
#
# NOTE: Currently the NoBackies module only supports class level callbacks.
# We will look into adding instance level callbacks in a future version.

module NoBacksies

  module Callbacks
    # Apply all supported callback modules.
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend MethodAdded
      base.extend MethodRemoved
      base.extend MethodUndefined
      base.extend SingletonMethodAdded
      base.extend SingletonMethodRemoved
      base.extend SingletonMethodUndefined
      base.extend ConstMissing
      base.extend Included
      base.extend Extended
    end
  end

  # The CallbackMethods module adds the callback methods which are used
  # define and access callback definitions. Mixing-in this module is
  # handled automatically, so you do not need to worry with it. In other
  # words, consider the module *private*.
  #
  #--
  # TODO: What about adding `super if defined?(super)` ot callback methods?
  # Should this be standard? Should it occur before or after? Or should
  # in be controlled via a special callback, e.g. `callback method_added, :super`?
  #++
  module CallbackMethods
    #
    def callback(name, &block)
      callbacks[name.to_sym] << block
    end

    #
    def callbacks
      @_callbacks ||= (
        anc = ancestors[1..-1].find do |anc|
          anc.callbacks rescue nil  # TODO: Need faster way!
        end
        anc ? anc.callbacks.dup : Hash.new{|h,k| h[k]=[]}
      )
    end

    # Returns Hash of true/false activity state of callbacks.
    #
    # TODO: Should expression be inherited?
    def callback_expression(express={}, &block)
      @_callback_expression ||= Hash.new{|h,k| h[k]=true}

      if block
        tmp = @_callback_expression.dup
        express.each{ |k,v| @_callback_expression[k.to_sym] = !!v }
        block.call
        @_callback_expression = tmp
      else
        express.each{ |k,v| @_callback_expression[k.to_sym] = !!v }
      end

      @_callback_expression
    end
  end

  # Callback system for #method_added.
  module MethodAdded
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def method_added(method)
      return unless callback_expression[:method_added]
      callbacks[:method_added].each do |block|
        block.call(method)
      end
    end
  end

  # Callback system for #method_removed.
  module MethodRemoved
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def method_removed(method)
      return unless callback_expression[:method_removed]
      callbacks[:method_removed].each do |block|
        block.call(method)
      end
    end
  end

  # Callback system for #method_removed.
  module MethodUndefined
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def method_undefined(method)
      return unless callback_expression[:method_undefined]
      callbacks[:method_undefined].each do |block|
        block.call(method)
      end
    end
  end

  # Callback system for #method_added.
  module SingletonMethodAdded
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def singleton_method_added(method)
      return unless callback_expression[:singleton_method_added]
      callbacks[:singleton_method_added].each do |block|
        block.call(method)
      end
    end
  end

  # Callback system for #method_removed.
  module SingletonMethodRemoved
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def singleton_method_removed(method)
      return unless callback_expression[:singleton_method_removed]
      callbacks[:singleton_method_removed].each do |block|
        block.call(method)
      end
    end
  end

  # Callback system for #method_removed.
  module SingletonMethodUndefined
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def singleton_method_undefined(method)
      return unless callback_expression[:singleton_method_undefined]
      callbacks[:singleton_method_undefined].each do |block|
        block.call(method)
      end
    end
  end

  # Callback system for #const_missing.
  module ConstMissing
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def const_missing(const)
      return unless callback_expression[:cont_missing]
      callbacks[:const_missing].each do |block|
        block.call(const)
      end
    end
  end

  # Callback system for #included.
  module Included
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def included(mod)
      return unless callback_expression[:included]
      callbacks[:included].each do |block|
        block.call(mod)
      end
    end
  end

  # Callback system for #extended.
  module Extended
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def extended(mod)
      return unless callback_expression[:extended]
      callbacks[:extended].each do |block|
        block.call(mod)
      end
    end
  end

  # Callback system for #inherited.
  module Inherited
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def extended(mod)
      return unless callback_expression[:inherited]
      callbacks[:inherited].each do |block|
        block.call(mod)
      end
    end
  end

end

