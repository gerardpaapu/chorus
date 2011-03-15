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
        return data if data instanceof Status

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

        key       = "" + id
        cached    = __tweet_cache__[ key ] ? null
        callbacks = (__callbacks__[ key ] ?= [])
        fresh     = cached is null and callbacks.length is 0

        if cached?
            callback cached
        else
            callbacks.push callback

        if fresh
            $.ajax
                url: "http://api.twitter.com/1/statuses/show/#{id}.json"
                dataType: "jsonp"
                success: (json) ->
                    status = Tweet.from(json)

                    __tweet_cache__[ key ] = status

                    for callback in __callbacks__[ key ]
                        try callback status

                    null

        return placeholder || null

__tweet_cache__ = {}
__callbacks__ = {}

class TwitterTimeline extends Timeline
    fetch: (n) ->
        data = extend {}, @sendData

        if @statuses.length > 0
            data.since_id = @statuses.item(0).id

        jQuery.ajax
            url: @queryUrl
            data: data
            dataType: "jsonp"
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
        @subscribe @user
        @subscribe @search

class TwitterConversationTimeline extends TwitterTimeline
    # Subscribes to a User timeline and a Reply timeline
    # for that user
    constructor: (username, options) ->
        @user = new TwitterUserTimeline username, options
        @replies = new ReplyTimeline @user

        @subscribe @replies
        @subscribe @user

class TwitterListConversationTimeline extends TwitterTimeline
    constructor: (username, listname, options) ->
        @list = new TwitterListTimeline username, listname, options
        @replies = new ReplyTimeline @list

        @subscribe @list
        @subscribe @replies

class ReplyTimeline extends Timeline
    # This subscribes to another timeline and publishes
    # all the tweets that it is replying to
    constructor: (@timeline) -> @subscribe @timeline

    update: (statuses) ->
        for status in statuses when status.reply?
            Tweet.fromID status.reply.statusID, (tweet) =>
                @statuses = @statuses.concat([ tweet ])
                @latest = @statuses.item 0
                @publish @statuses.toArray()

        null

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

[].push.apply Timeline.shorthands, [
    {
        pattern: /^@([a-z-_]+)\/([a-z-_]+)/i,
        fun: (_, name, list_name) -> new TwitterListTimeline(name, list_name)
    },
    {
        pattern: /^@@([a-z-_]+)\/([a-z-_]+)/i,
        fun: (_, name, list_name) -> new TwitterListConversationTimeline(name, list_name)
    },
    {
        pattern: /^@@([a-z0-9-_]+)$/i
        fun: (_, name) -> new TwitterConversationTimeline name
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
    TwitterAboutTimeline,
    TwitterConversationTimeline
}
