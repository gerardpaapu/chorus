{inArray, makeArray, extend} = $ = jQuery
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

    statuses: []
    latest: null
    timer: null

    update: -> throw Error "Not Implemented"

    startUpdates: (period) ->
        period ?= @options.updatePeriod
        @timer = setInterval (=> @update()), period

    stopUpdates: ->
        clearInterval @timer
        @timer = null

    prePublish: (data) ->
        statuses = ( s for s in this.statusesFromData(data) when @isNew s )

        if statuses.length > 0
            @statuses.push statuses...
            @statuses = sortStatuses(@statuses)
            @latest = @statuses[0]
            @publish @statuses

    isNew: (status) ->
        !@latest or status.date.getTime() > @latest.date.getTime()

    @shorthands: []

    @from: (t) ->
        return t if t instanceof Timeline

        for short in Timeline.shorthands
            match = short.pattern.exec t
            return short.fun match... if match

        null

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

    update: (data, source) ->
        statuses = []
        count = @options.count

        @statuses.push source.statuses[0..count]...
        @statuses = sortStatuses(@statuses)
        @statuses = @statuses[0..count]

        @trigger 'update'

    subscribe: (source) -> super Timeline.from(source)

    toElement: ->
        element = $ '<div class="view chorus_view" />'

        @bind 'update', => @updateElement element
        @updateElement element
        element.data 'View', this

    updateElement: (element) ->
        children = (@renderStatus status for status in @statuses)
        element.empty().append children...

    renderStatus: (status) ->
        options = @options.renderOptions
        key = status.toKey()
        @htmlCache ?= {}

        unless key in @htmlCache
            @htmlCache[key] = status.toElement(@options.renderOptions)

        @htmlCache[key]

sortStatuses = (statuses) ->
    arr = Array::slice.call(statuses)
    arr.sort(Status.byDate)
    distinct(arr, Status.equal)

distinct = (arr, test) ->
    test ?= (a, b) -> a is b

    _some = (fn) ->
        return true for i in this when fn(i)

        false

    some = Array::some ? _some

    out = []

    for i in arr when not out.some((item) -> test item, i)
        out.push(i)

    out

extend Chorus, {Timeline, View}

$.fn.chorus = (arg) ->
    view = switch Object::toString.call arg
        when "[object String]"
            new View feeds: makeArray(arguments)

        when "[object Object]"
            new View arg

        else null

    $(this)
        .append(view.toElement())
        .data('View', view)
