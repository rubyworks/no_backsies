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
# easier to control callback expression via the #callback_express
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
#       callback_express :method_added=>false do
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
#
#--
# TODO: What about adding `super if defined?(super)` to callback methods?
# Should this be standard? Should it occur before or after? Or should
# in be controlled via a special callback, e.g. `callback method_added, :super`?
#++

module NoBacksies

  #

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

  module CallbackMethods
    # Define a callback.
    def callback(name, express={}, &block)
      express[name.to_sym] = express.delete(:this) if express.key?(:this)
      callbacks[name.to_sym] << [block, express]
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
    def callback_express(express={}, &block)
      @_callback_express ||= Hash.new{|h,k| h[k]=true}

      if block
        tmp = @_callback_express.dup
        express.each{ |k,v| @_callback_express[k.to_sym] = !!v }
        block.call
        @_callback_express = tmp
      else
        express.each{ |k,v| @_callback_express[k.to_sym] = !!v }
      end

      @_callback_express
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
      return unless callback_express[:method_added]
      callbacks[:method_added].each do |block, express|
        callback_express(express) do
          block.call(method)
        end
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
      return unless callback_express[:method_removed]
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
      return unless callback_express[:method_undefined]
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
      return unless callback_express[:singleton_method_added]
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
      return unless callback_express[:singleton_method_removed]
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
      return unless callback_express[:singleton_method_undefined]
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
      return unless callback_express[:cont_missing]
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
      return unless callback_express[:included]
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
      return unless callback_express[:extended]
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
      return unless callback_express[:inherited]
      callbacks[:inherited].each do |block|
        block.call(mod)
      end
    end
  end

end

