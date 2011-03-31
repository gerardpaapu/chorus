Chorus = @Chorus ?= {}
{inArray, makeArray, extend} = $ = jQuery

# OrderedSet
# ----------
#
# A Collection class that wraps an Array.
# It maintains immutability, an order, and
# does not contain duplicates
#
# You can specialize your objects for 
# OrderedSet by implementing `__eq__` (equals)
# and `__gt__` (greater-than). 
#
# `eq` is used to disallow duplicates
# `gt` is used to enforce ordering
#
# otherwise strict equality `===` is used for `eq`
# and the builtin `>` is used for `gt`
#
# When implementing `__eq__` and `__gt__` these
# constraints must be observed.
#
#     if eq(a, b) is true:
#         eq(a, b) must be true
#         gt(a, b) must be false
#         gt(b, a) must be false
#    
#     if gt(a, b) is true:
#         eq(a, b) must be false
#         gt(b, a) must be false
#
class OrderedSet
    constructor: (arr, ordered, uniq) ->
        # arr     - an Array
        # ordered - if the Array is known to be ordered (skip ordering)
        # uniq    - if the Array is known to not contain 
        #           any duplicates (skip uniquifying)
        @items = arr or []

        unless uniq
            uniquify this

        else unless ordered
            sort this

        @length = @items.length

    contains: (a) ->
        for item in @items
            return true  if eq a, item
            # because the collection is ordered
            # we can bail here
            return false if gt item, a

        false

    toArray: -> @items.slice()

    slice: (a, b) -> @items.slice(a, b)

    item: (i) -> @items[i]

    concat: (ls) ->
        out = []
        if ls instanceof OrderedSet
            ls = ls.items

        for item in ls
            out.push item unless @contains item

        if out.length is 0
            this
        else
            new OrderedSet @items.concat(out), yes

# Private Functions
# ----------------
#
# Declared separately so that minifiers can mangle them
#
# Maintain the order of elements such that
# for [a, ... b], gt(b, a) is true
LESS = -1
MORE = 1
EQUAL = 0

sort = (set) ->
    set.items.sort (a, b) ->
        if gt a, b
            MORE
        else if gt b, a
            LESS
        else
            EQUAL

# Remove duplicates so that for no 
# two elements (a, b) eq(a, b)
uniquify = (set) ->
    i = 0
    len = set.items.length
    items = []

    # the uniquify algorithm depends on the
    # contents being ordered
    sort(set)

    while i < len
        # current is new so we save it
        items.push(current = set.items[i])

        # because set is sorted, all the duplicates
        # will be adjacent and we can skip them 
        i++ while i < len and eq current, set.items[i]

    set.items = items

eq = (a, b) ->
    if a.__eq__ then a.__eq__(b) else a is b

gt = (a, b) ->
    if a.__gt__ then a.__gt__(b) else a > b

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
            fn.call listener, data, src
            @publish data

        listener.subscribe object
        listener


class Status
    constructor: (@id, @username, @avatar, date, @text, @raw) ->
        @date = new Date(date)

    toKey: -> "<Status:#{@username} ID:#{@id}>"

    toElement: (options = {}) ->
        body     = @renderBody()
        element  = $ '<div class="status" />'

        element.append(
            @renderAvatar(),
            @renderScreenName(),
            body,
            @renderTimestamp())

        if options.extras?
            extras = (fn(element, body, this) for fn in options.extras)
            elements = (extra for extra in extras when extra)

            if elements.length > 0
                el = $ '<div class="extras" />'
                element.append(el)
                el.append elements...

        element

    getAvatar: -> @avatar

    getUrl: -> null
    getStreamUrl: -> null

    renderAvatar: -> """
        <a href="#{@getStreamUrl()}" class="avatar">
            <img src="#{@getAvatar()}" class="avatar" />
        </a>"""

    renderTimestamp: ->
        el = $ """
        <a class="date"
           href="#{ @getUrl() }"
           title="#{ iso_datestring @date }">
            #{ @date.toLocaleTimeString() } #{ @date.toLocaleDateString() }
        </a>"""

        if $.fn.timeago? then el.timeago() else el

    renderScreenName: -> """
        <a class="username"
           href="#{@getStreamUrl()}">
            #{@username}
        </a>"""

    renderBody: -> """<p class="statusBody">#{@text.replace '\n', '<br />'}</p>"""

    raw: null

    __eq__: (status) -> @toKey() is status.toKey()

    __gt__: (status) -> @date.getTime() < status.date.getTime()

iso_datestring = (d) ->
    pad = (n) -> if n < 10 then '0' + n else n
    year    = pad d.getUTCFullYear()
    month   = pad d.getUTCMonth() + 1
    day     = pad d.getUTCDate()
    hours   = pad d.getUTCHours()
    minutes = pad d.getUTCMinutes()
    seconds = pad d.getUTCSeconds()

    "#{year}-#{month}-#{day}T#{hours}:#{minutes}:#{seconds}Z"


class Timeline extends PubSub
    constructor: (options) ->
        @options = extend {}, @options, options

        if @options.updateOnStart then @fetch()
        if @options.updatePeriod  then @startUpdates()

    options:
        count: 25
        updateOnStart: true
        updatePeriod: 90000
        filter: -> true

    statuses: new OrderedSet()
    subscribers: []
    timer: null

    fetch: -> throw Error "Not Implemented"

    startUpdates: (period) ->
        period ?= @options.updatePeriod
        @timer = setInterval (=> @fetch()), period

    stopUpdates: ->
        clearInterval @timer
        @timer = null

    update: (data, source) ->
        statuses = @statuses.concat(s for s in @statusesFromData data when @options.filter s)

        unless statuses is @statuses
            @statuses = statuses
            @publish statuses.toArray()

    @shorthands: []

    @from: (t) ->
        return t if t instanceof Timeline
        t = trim t
        [_, root, filter] = /(.*)(?:\[(.*)\])?/.exec t
        for short in Timeline.shorthands
            match = short.pattern.exec root
            if match
                timeline = short.fun match...
                timeline.options.filter = filter_from filter
                return timeline

        null

trim = (str) ->
    str.replace(/^\s*/, '').replace(/\s*$/, '')

filter_from = (pattern) ->
    return (-> true) unless pattern
    switch pattern[0]
        when '#', '/'
           (status) -> status.text.match(new RegExp pattern)

        else -> true

class View extends PubSub
    constructor: (options) ->
        @options = extend {}, @options, options
        @subscribe feed for feed in @options.feeds when feed?

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

    statuses: new OrderedSet()

    htmlCache: null

    subscribe: (pub) -> super Timeline.from(pub)

    update: (data, source) ->
        new_statuses = (s for s in source.statuses.slice(0, @options.count) when @options.filter s)
        statuses = @statuses.concat new_statuses

        if statuses != @statuses
            @statuses = statuses
            @publish statuses

    toElement: ->
        element = $ '<div class="view chorus_view" />'

        PubSub.bind this, => @updateElement element
        @updateElement element
        element.data 'View', this

    updateElement: (element) ->
        statuses = @statuses.slice 0, @options.count
        children = (@renderStatus status for status in statuses)
        element.empty().append children...

    renderStatus: (status) ->
        options = @options.renderOptions
        key = status.toKey()
        @htmlCache ?= {}

        unless key in @htmlCache
            @htmlCache[key] = status.toElement(@options.renderOptions)

        @htmlCache[key]

extend @Chorus, {
    OrderedSet,
    PubSub,
    Timeline,
    View,
    Status
}

$.fn.chorus = (arg) ->
    view = switch $.type(arg)
        when "string"
            new View feeds: makeArray(arguments)

        when "object"
            new View arg

        else null

    $(this)
        .append(view.toElement())
        .data('View', view)
