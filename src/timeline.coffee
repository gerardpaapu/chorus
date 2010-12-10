$ = jQuery
{extend, map, filter, indexOf} = _
{Publisher, Subscriber, Status} = Chorus = @Chorus

class Timeline extends Publisher
    constructor: (options) ->
        @options = extend {}, @options, options
        if @options.updateOnStart then @update()
        if @options.updatePeriod  then @startUpdates()

    options:
        count: 25
        updateOnStart: true
        updatePeriod: 90000

    latest: null
    timer: null

    update: -> throw Error "Not Implemented"

    startUpdates: (period) ->
        period ?= @options.updatePeriod
        @timer = setInterval ( => @update() ), period

    stopUpdates: ->
        clearInterval @timer
        @timer = null

    prePublish: (data) ->
        statuses = ( s for s in this.statusesFromData(data) when @isNew s )

        if statuses.length > 0
            statuses.sort Status.byDate
            @latest = statuses[0]
            @publish statuses

    isNew: (status) ->
        !@latest or status.date.getTime() > @latest.date.getTime()

Timeline.shorthands = []
Timeline.from = (t) ->
    return t if t instanceof Timeline

    for short in Timeline.shorthands
        match = short.pattern.exec t
        return short.fun match... if match

    return null

class View extends Subscriber
    constructor: (options) ->
        @options = extend {}, @options, options
        @subscribe feed for feed in @options.feeds

        if @options.container?
            @toElement().appendTo @options.container

    options:
        count: 10
        feeds: []
        container: false
        renderOptions: {}
        filter: -> true

    renderStatus: (status) ->
       cache = @htmlCache ?= {}
       options = @options.renderOptions

       cache[status.toKey()] ?= status.toElement(options)

    statuses: []
    htmlCache: null

    update: (statuses, source) ->
        @statuses = distinct(@statuses.concat(statuses), (a, b) -> a.toKey() is b.toKey())
        @statuses.sort Status.byDate
        @trigger 'update', [statuses, source, this]

    subscribe: (source) -> super Timeline.from(source)

    toElement: ->
        element = $ '<div class="view" />'

        @bind 'update', => @updateElement element
        @updateElement element
        element.data 'View', this

    updateElement: (element) ->
        children = for status in @statuses[0..@options.count - 1]
            @renderStatus status

        element.empty().append children...

    renderStatus: (status) ->
        options = @options.renderOptions
        key = status.toKey()
        @htmlCache ?= {}

        unless key in @htmlCache
            @htmlCache[key] = status.toElement(@options.renderOptions)

        @htmlCache[key]

distinct = (arr, test) ->
    out = []
    out.push(i) for i in arr when indexOf out, i is -1
    return out

extend Chorus, {Timeline, View}
