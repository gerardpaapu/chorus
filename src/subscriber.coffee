Chorus = @Chorus ?= {}
{inArray, makeArray, extend} = $ = jQuery

class PubSub
    __subscribers__: []

    subscribe: (publisher) -> publisher.addSubscriber this

    unsubscribe: (publisher) ->
        publisher.removeSubscriber this
        this

    publish: (data) ->
        sub.update(data, this) for sub in @__subscribers__
        this

    update: -> this

    addSubscriber: (subscriber) ->
        if inArray(@__subscribers__, subscriber) is -1
            @__subscribers__ = @__subscribers__.concat [ subscriber ] 

        this

    removeSubscriber: (subscriber) ->
        index = inArray(@__subscribers__, subscriber)
        @__subscribers__.splice(index, 1) unless index is -1

    @bind: (object, fn) ->
        listener = new PubSub()
        listener.update = (data, src) ->
            fn data
            @publish data

        listener.subscribe object
        listener

Chorus.PubSub = PubSub
