$ = jQuery
{extend, map} = _

class Timeline extends Publisher
    constructor: (options) ->
        extend @options, options

        if @options.updateOnStart then @update()
        if @options.updatePeriod  then @startUpdates()

    options:
        count: 25
        updateOnStart: true
        updatePeriod: 90000

    latest: null
    timer: null

    startUpdates: (period) ->
        period ?= @options.updatePeriod
        @timer = setInterval ( => @update() ), period

    stopUpdates: ->
        clearInterval @timer
        @timer = null

    prePublish: (data) ->
        statuses = this.statusesFromData(data).filter (status) => @isNew status

        if statuses.length > 0
            statuses.sort Status.byDate
            @latest = statuses[0]
            @publish statuses

    isNew: (status) ->
        !@latest or status.date.getTime() > @latest.date.getTime()


class View extends Subscriber
    renderStatus: (status) ->
       cache = @htmlCache ?= {}
       options = @options.renderOptions

       cache[status.toKey()] ?= status.toElement(options)

    statuses: []

    update: (statuses, source) ->
        @statuses = distinct(@statuses.concat(statuses), (a, b) -> a.toKey() is b.toKey())
        @statuses.sort Status.byDate
        @trigger 'update', [statuses, source, this]
