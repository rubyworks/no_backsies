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
# == Calling Super
#
# Each callback invocation passes along a superblock procedure, which can be
# used to invoke `super` for the underlying callback method. For example,
# it is common to call `super` in a `const_missing` callback if the dynamic
# constant lookup fails.
#
#     callback :const_missing do |const, &superblock|
#       psuedo_constants[const] || superblock.call
#     end
#
# By default, super is called after call callback procedures are called becuase
# that is by far the most commonly desired behavior. To suppress this behavior
# pass the `:superless=>true` flag to the `callback` method.
#
#   callback :included, :superless=>true do |mod|
#     ...
#   end
#
# == Customizing the Underlying Callback Procedure
#
# Every callback follows the same simply pattern, e.g. for `method_added`:
#
#    def self.method_added(method)
#      if defined?(super)
#        callback_invoke(:method_added, method){ super(method) }
#      else
#        callback_invoke(:method_added, method)
#      end
#    end
#
# So it is easy enough to customize if you have some special requirements.
# Say you want to call super before all callback procedures, and never allow
# any callback procedure to do so themselves, then you could simply redefine
# the underlying callback method as:
#
#    def self.method_added(method)
#      super(method) if defined?(super)
#      callback_invoke(:method_added, method)
#    end
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
    #
    def callback_invoke(name, *args, &superblock)
      name = name.to_sym
      return unless callback_express[name]
      callbacks[name].each do |block, options|
        if options[:safe]
          callback_express(name=>false) do
            block.call(*args, &superblock)            
          end
        else
          block.call(*args, &superblock)
        end
        if options[:once]
          callbacks[name].delete([block, options])
        end
        if !options[:superless]
          superblock.call if superblock
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
      if defined?(super)
        callback_invoke(:method_added, method){ super(method) }
      else
        callback_invoke(:method_added, method)
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
      if defined?(super)
        callback_invoke(:method_removed, method){ super(method) }
      else
        callback_invoke(:method_removed, method)
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
      if defined?(super)
        callback_invoke(:method_undefined, method){ super(method) }
      else
        callback_invoke(:method_undefined, method)
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
      if defined?(super)
        callback_invoke(:singleton_method_added, method){ super(method) }
      else
        callback_invoke(:singleton_method_added, method)
      end
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
      if defined?(super)
        callback_invoke(:singleton_method_removed, method){ super(method) }
      else
        callback_invoke(:singleton_method_removed, method)
      end
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
      if defined?(super)
        callback_invoke(:singleton_method_undefined, method){ super(method) }
      else
        callback_invoke(:singleton_method_undefined, method)
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
      if defined?(super)
        callback_invoke(:included, mod){ super(mod) }
      else
        callback_invoke(:included, mod)
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
      if defined?(super)
        callback_invoke(:extended, mod){ super(mod) }
      else
        callback_invoke(:extended, mod)
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
    def inherited(base)
      if defined?(super)
        callback_invoke(:inherited, base){ super(base) }
      else
        callback_invoke(:inherited, base)
      end
    end
  end

  # Callback system for #const_missing.
  #
  # Unlike other callback mixins, this does NOT invoke super (for obvious reasons).
  module ConstMissing
    #
    def self.append_features(base)
      base.extend CallbackMethods
      base.extend self
    end

    #
    def const_missing(const)
      if defined?(super)
        callback_invoke(:const_missing, const){ super(const) }
      else
        callback_invoke(:const_missing, const)
      end
    end
  end

end
