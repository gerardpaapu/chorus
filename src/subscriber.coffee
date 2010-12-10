Chorus = @Chorus ?= {}
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
            fn args... for fn in list

        return this

class Subscription
    constructor: (@publisher, @subscriber, @type='update') ->
        @callback = (data) =>
            @subscriber.update data, @publisher

        @publisher.bind @type, @callback

    cancel: ->
        @publisher.unbind @type, @callback

class Subscriber extends Events
    subscribe: (publisher) ->
        @subscriptions.push(new Subscription publisher, this)

    subscriptions: []

    unsubscribe: (subscription) ->
        index = indexOf @subscriptions, subscription
        if index isnt -1
            @subscription.splice index, 1
            subscription.cancel()

    update: (data, source) ->
        this

class Publisher extends Events
    publish: (data, type='update') ->
        @trigger type, data

extend Chorus, {Subscriber, Subscription, Publisher}
