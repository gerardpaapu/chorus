{Status, Timeline} = Chorus = @Chorus
{extend} = _

class FacebookStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @userid) ->
        super id, username, avatar, date, text, raw

    getStreamUrl: -> "http://facebook.com/profile.php?id=#{@userid}"

    getUrl: -> "http://facebook.com/#{@userid}/posts/#{@id}"

    getAvatar: -> "https://graph.facebook.com/#{@userid}/picture"

    toElement: (options) ->
        element = super options

        if options.comment then $.ajax
            url: "https://graph.facebook.com/#{@userid}_#{@id}/comments"
            dataType: "jsonp"
            success: (json) =>
                if json.data.length > 0
                    container = $ '<div class="comments" />'
                    comments = (renderComment item for item in json.data)
                    container.append comments...
                    element.append container

        element

    @from = (data) ->
        return data if data instanceof Status

        match = /_(.*)$/.exec(data.id)
        id = match and match[1]
        link = data.source or data.link
        text = data.message ? ''
        if link? then text += """<a href="#{link}">#{data.name}</a>"""

        new FacebookStatus id, data.from.name, null, data.created_time, text, data, data.from.id

renderComment = (data) ->
    url = FacebookStatus::getStreamUrl.call {userid: data.from.id}
    """
    <p class="comment">
        <a href="#{url}">#{data.from.name}</a>:
        #{ data.message }
    </p>"""

class FacebookTimeline extends Timeline
    constructor: (@username, options) ->
        @queryUrl = "https://graph.facebook.com/#{@username}/feed"
        super options

    update: (n) ->
        jQuery.ajax
            url: @queryUrl
            dataType: 'jsonp'
            success: (data) => @prePublish data

    statusesFromData: (json) -> FacebookStatus.from item for item in json.data

Timeline.shorthands.unshift
    pattern: /^FB:(.*)$/
    fun: (_, name) -> new FacebookTimeline name

extend Chorus, {FacebookStatus, FacebookTimeline}
