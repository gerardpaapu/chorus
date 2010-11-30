Chorus = @Chorus ? {}
{extend, indexOf} = _

class Events
    bind: (ev, callback) ->
        @_callbacks ?= {}
        list = @_callbacks[ev] ?= []
        list.push callback

        this

    unbind: (ev, callback) ->
        if not ev?
            # remove all callbacks
            @_callbacks = {}

        if not callback?
            # if no callback is passed
            # unbind all events of this type
            @_callbacks[ev] = []

        else
            list = @_callbacks[ev]
            index = indexOf list, callback

            list.splice index, 1 unless index is -1

        this

    trigger: (ev, args...) ->
        return this unless @_callbacks?

        if (list = @_callbacks[ev])?
            fn args... for fn in list

        if (list = @_callbacks.all)?
            fn.args... for fn in list

        return this

class Subscription
    cancel: ->
        

class Subscriber extends Events
    subscribe: (publisher) ->
        new Subscription publisher, this

    subscription: []

class Publisher extends Events


extend Chorus, {Subscriber, Subscription, Publisher}
