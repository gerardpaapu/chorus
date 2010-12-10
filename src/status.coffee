class Status
    constructor: (@id, @username, @avatar, date, @text, @raw) ->
        @date = new Date(date)

    toKey: -> "<Status:#{@username} ID:#{@id}>"

    toElement: (option) ->
        options ?= {}
        body     = @renderBody()
        element  = $ '<div class="status" />'

        element.append(
            @renderAvatar(),
            @renderScreenName(),
            body,
            @renderTimestamp())

        if options.extras?
            extras = fn(element, body, this) for fn in options.extras
            elements = extra for extra in extras when extra

            if elements.length > 0
                el = $ '<div class="extras" />'
                el.append elements...
                element.append(el)

        element

    getAvatar: -> @avatar

    getUrl: -> null
    getStreamUrl: -> null

    renderAvatar: -> """
        <a href="#{@getStreamUrl()}">
            <img src="#{@getAvatar()}" class="avatar" />
        </a>"""

    renderTimestamp: -> 
        el = $ """
        <a class="date"
           href="#{ @getUrl() }"
           title="#{ iso_datestring @date }">
            #{ @date.toLocaleDateString() } 
        </a>"""

        if $.fn.timeago? then el.timeago() else el

    renderScreenName: -> """
        <a class="username"
           href="#{@getStreamUrl()}">
            #{@username}
        </a>"""

    renderBody: -> """<p class="statusBody">#{@text.replace '\n', '<br />'}</p>"""

    raw: null

    @equal: (a, b) -> a.toKey() is b.toKey()

    @byDate: (a, b) -> b.date.getTime() - a.date.getTime()

iso_datestring = (d) ->
    pad = (n) -> if n < 10 then '0' + n else n
    year    = pad d.getUTCFullYear()
    month   = pad d.getUTCMonth() + 1
    day     = pad d.getUTCDate()
    hours   = pad d.getUTCHours()
    minutes = pad d.getUTCMinutes()
    seconds = pad d.getUTCSeconds()

    "#{year}-#{month}-#{day}T#{hours}:#{minutes}:#{seconds}Z"

@Chorus.Status = Status
