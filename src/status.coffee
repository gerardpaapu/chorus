class Status
    constructor: (@id, @username, @avatar, date, @text, raw) ->
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

    renderTimestamp: -> """
        <a class="date" href="#{ @getUrl() }">
            #{ @date.toLocaleDateString() }, 
            #{ @date.toLocaleTimeString() }
        </a>"""

    renderScreenName: -> """
        <a class="username"
           href="#{@getStreamUrl()}">
            #{@username}
        </a>"""

    renderBody: -> """<p class="statusBody">#{@text}</p>"""

    raw: null

    @equal: (a, b) -> a.toKey() is b.toKey()

    @byDate: (a, b) -> b.date.getTime() - a.date.getTime()

@Chorus.Status = Status
