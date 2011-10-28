# NoBacksies module ecapsulates all supported callback mixins.
#
# NoBacksies::Callbacks can be mixed-in and all supported callbacks will
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
# After all callbacks for a class are invoked, NoBacksies will invoke the
# callback method of the parent class via `super`, if such a method is defined.
# To change this, you can reconstruct the main callback method itself. It's not
# difficult. Every callback follows the same pattern, e.g. for `method_added`:
#
#    def self.method_added(method)
#      callback_invoke(:method_added, method)
#      super(method) if defined?(super)
#    end
#
# So if you want to call super before the other callbacks, then you could
# simply redefine this with:
#
#    def self.method_added(method)
#      super(method) if defined?(super)
#      callback_invoke(:method_added, method)
#    end
#
# The default behavior is to call it afterward becuase that is by far the most
# commonly desired behavior.
#
# NOTE: Currently the NoBacksies module only supports class level callbacks.
# We will look into adding instance level callbacks, such as `method_missing`
# in a future version.

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
      base.extend Inherited
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
  end #module

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
      super(method) if defined?(super)
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
      super(method) if defined?(super)
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
      super(method) if defined?(super)
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
      super(method) if defined?(super)
    end
  end

  # Callback system for #singleton_method_removed.
  module SingletonMethodRemoved
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def singleton_method_removed(method)
      callback_invoke(:singleton_method_removed, method)
      super(method) if defined?(super)
    end
  end

  # Callback system for #singleton_method_undefined.
  module SingletonMethodUndefined
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def singleton_method_undefined(method)
      callback_invoke(:singleton_method_undefined, method)
      super(method) if defined?(super)
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
      super(const) if defined?(super)
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
      super(mod) if defined?(super)
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
      super(mod) if defined?(super)
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
    def inherited(base)
      callback_invoke(:inherited, base)
      super(base) if defined?(super)
    end
  end

end

