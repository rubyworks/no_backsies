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
    def callback(name, options={}, &block)
      callbacks[name.to_sym] << [block, options]
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

    # Invoke a callback.
    def callback_invoke(name, *args)
      name = name.to_sym
      return unless callback_express[name]
      callbacks[name].each do |block, options|
        if options[:safe]
          callback_express(name=>false) do
            block.call(*args)            
          end
        else
          block.call(*args)
        end
        if options[:once]
          callbacks[name].delete([block, options])
        end
      end
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
      callback_invoke(:method_added, method)
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
      callback_invoke(:method_removed, method)
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
      callback_invoke(:method_undefined, method)
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
      callback_invoke(:singleton_method_added, method)
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
      callback_invoke(:singleton_method_removed, method)
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
      callback_invoke(:singleton_method_undefined, method)
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
      callback_invoke(:const_missing, const)
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
      callback_invoke(:included, mod)
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
      callback_invoke(:extended, mod)
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
      callback_invoke(:inherited, mod)
    end
  end

end

