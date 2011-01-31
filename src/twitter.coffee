{Timeline, Status, Subscriber} = Chorus = @Chorus
{extend} = $ = jQuery

class Tweet extends Status
    constructor: (id, username, avatar, date, text, raw, @reply) ->
        super id, username, avatar, datefix(date), text, raw

    getUrl: -> "http://twitter.com/#{@username}/statuses/#{@id}"

    getStreamUrl: -> "http://twitter.com/#{@username}"

    renderBody: -> """
        <p class="statusBody">
            #{ linkify(@text).replace '\n', '<br />' }
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

        new Tweet id_str, user_name, avatar, created_at, text, data, reply

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
    fetch: (n) ->
        data = extend {}, @sendData

        if @latest then data.since_id = @latest.id

        jQuery.ajax
            url: @queryUrl
            data: data
            dataType: 'jsonp'
            success: (data) => @update data

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

class TwitterSearchTimeline extends TwitterTimeline
    constructor: (@searchTerm, options) ->
        @options = extend {}, @options, options
        @sendData = q: searchTerm, rpp: @options.count, result_type: "recent"
        super options

    queryUrl: "http://search.twitter.com/search.json"

    update: (data) ->
        if data.results? then super data.results

class TwitterListTimeline extends TwitterTimeline
    constructor: (user, listname, options) ->
        @options = extend {}, @options, options
        @queryUrl = "http://api.twitter.com/1/#{user}/lists/#{listname}/statuses.json"
        @sendData = extend({}, @sendData, {per_page: @options.count})

        super options

class TwitterAboutTimeline extends TwitterTimeline
    constructor: (screenname, options) ->
        @user = new TwitterUserTimeline screenname, options
        @search = new TwitterSearchTimeline "to:" + screenname
        @subscriber = new Chorus.PubSub()
        @subscribe @user
        @subscribe @search

datefix = (str) ->
    # Twitter seems to give some wacky date format
    # that IE can't handle, so I convert it to something more normal.
    str.replace(/^(.+) (\d+:\d+:\d+) ((?:\+|-)\d+) (\d+)$/, "$1 $4 $2 GMT$3")

linkify = (str) ->
    # creates links for hashtags, mentions and urls
    # TODO: replace this BS with some code to read the entities property
    # that twitter delivers from the API
    str .replace(/(\s|^)(mailto\:|(news|(ht|f)tp(s?))\:\/\/\S+)/g, '$1<a href="$2">$2</a>')
        .replace(/(\s|^)@(\w+)/g, '$1<a class="mention" href="http://twitter.com/$2">@$2</a>')
        .replace(/(\s|^)#(\w+)/g, '$1<a class="hashTag" href="http://twitter.com/search?q=%23$2">#$2</a>')

Array::push.apply Timeline.shorthands, [
    {
        pattern: /^@([a-z-_]+)\/([a-z-_]+)/i,
        fun: (_, name, list_name) -> new TwitterListTimeline(name, list_name)
    },
    {
        pattern: /^@\+([a-z-_]+)/i,
        fun: (_, name) -> new TwitterAboutTimeline name
    },
    {
        pattern: /^@([a-z-_]+)/i,
        fun: (_, name) -> new TwitterUserTimeline name
    },
    {
        pattern: /^(.*)$/,
        fun: (_, terms) -> new TwitterSearchTimeline terms
    }
]

extend @Chorus, {
    Tweet,
    TwitterTimeline,
    TwitterUserTimeline,
    TwitterListTimeline,
    TwitterSearchTimeline,
    TwitterAboutTimeline
}
