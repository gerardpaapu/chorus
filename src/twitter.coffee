{Timeline, Status} = Chorus = @Chorus
{extend} = $ = jQuery

class Tweet extends Status
    constructor: (id, username, avatar, date, @text, @reply) ->
        super id, username, avatar, Tweet.datefix(date), text, reply

    getUrl: -> "http://twitter.com/#{@username}/statuses/#{@id}"

    getStreamUrl: -> "http://twitter.com/#{@username}"

    renderBody: -> """
        <p class="statusBody">
            #{ Tweet.linkify(@text).replace '\n', '<br />' }
        </p>"""

    renderReply: -> """
        <a class="reply"
           href="http://twitter.com/#{@reply.username}/statuses/#{@reply.statusID}">
           in reply to @#{@reply.username}
        </a>"""

    toElement: (options) ->
        element = super options
        if @reply? then element.append @renderReply()

        element

    @from: (data) ->
        return data if data instanceof Tweet

        data = data.retweeted_status ? data

        reply = if data.in_reply_to_status_id?
            username: data.in_reply_to_screen_name
            userID: data.in_reply_to_user_id_str
            statusID: data.in_reply_to_status_id_str

        {id_str, created_at, text} = data

        if not data.user? # is this data from the Search API
            user_name = data.from_user
            avatar = data.profile_image_url
        else
            user_name = data.user.screen_name
            avatar = data.user.profile_image_url

        new Tweet id_str, user_name, avatar, created_at, text, reply

    @datefix: (str) ->
        # Twitter seems to give some wacky date format
        # that IE can't handle, so I convert it to something more normal.
        str.replace(/^(.+) (\d+:\d+:\d+) ((?:\+|-)\d+) (\d+)$/, "$1 $4 $2 GMT$3")

    @linkify: (str) ->
        # creates links for hashtags, mentions and urls
        # TODO: replace this BS with some code to read the entities property
        # that twitter delivers from the API
        str .replace(/(\s|^)(mailto\:|(news|(ht|f)tp(s?))\:\/\/\S+)/g, '$1<a href="$2">$2</a>')
            .replace(/(\s|^)@(\w+)/g, '$1<a class="mention" href="http://twitter.com/$2">@$2</a>')
            .replace(/(\s|^)#(\w+)/g, '$1<a class="hashTag" href="http://twitter.com/search?q=%23$2">#$2</a>')

    @fromID: (id, callback) ->
        unless callback?
            placeholder = $ '<div class="placeholder" />'
            callback = (status) ->
                status.toElement().replaceAll(placeholder)

        $.ajax
            url: "http://api.twitter.com/1/statuses/show/#{id}.json"
            success: (json) -> callback Tweet.from(json)

        return placeholder || null

class TwitterTimeline extends Timeline
    update: (n) ->
        data = extend {}, @sendData

        if @latest then data.since_id = @latest.id

        jQuery.ajax
            url: @queryUrl
            data: data
            dataType: 'jsonp'
            success: (data) => @prePublish data

    queryUrl: "http://api.twitter.com/1/statuses/public_timeline.json"

    statusesFromData: (data) -> Tweet.from item for item in data

class TwitterUserTimeline extends TwitterTimeline
    constructor: (username, options) ->
        @options  = extend {}, @options, options
        @username = username.toLowerCase()
        @sendData =
            screen_name: @username
            count: @options.count
            include_rts: @options.includeRetweets

        super options

    options: extend({}, Timeline::options, { includeRetweets: yes })

    queryUrl: "http://api.twitter.com/1/statuses/user_timeline.json"

Timeline.shorthands.push
    pattern: /^@([a-z-_]+)/i
    fun: (_, name) -> new TwitterUserTimeline(name)

extend @Chorus, {Tweet, TwitterTimeline, TwitterUserTimeline}
