class Status
    constructor: (@id, @username, @avatar, date, @text) ->
        @date = Date.parse date

    toKey: -> "<Status:#{username} #{id}>"

    toElement: (option) ->
        options ?= {}
        body     = @renderBody()
        element  = $ '<div class="status" />'

        element.append
            @renderAvatar()
            @renderScreenName()
            body
            @renderTimestamp()

        if options.extras?
            extras = fn(element, body, this) for fn in options.extras
            el = $ '<div class="extras" />'
            el.append.apply(el, extras)

        element

    getAvatar: -> @avatar

    renderAvatar: -> """
        <a href="#{@getStreamUrl()}">
            <img src="#{@getAvatar()}" class="avatar" />
        </a>"""

    getTimestamp: ->
        # insert some timeago now

    renderScreenName: -> """
        <a class="username"
           href="#{@getStreamUrl()}">
            #{@username}
        </a>"""

    renderBody: -> """<p class="statusBody">#{@text}</p>"""

    @equal: (a, b) -> a.toKey() is b.toKey()

    @byDate: (a, b) -> b.date.getTime() - a.date.getTime()
