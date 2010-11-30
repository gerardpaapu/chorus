{Timeline, Status} = Chorus
{extend, clone, indexOf, map} = _

class Tweet extends Status
    constructor: (id, username, avatar, date, @text, @reply) ->
        super id, username, avatar, Tweet.datefix(date), text, reply
        @text = linkify @text

    getUrl: -> "http://twitter.com/#{@username}/statuses/#{@id}"

    getStreamUrl: -> "http://twitter.com/#{@username}"

    renderReply: ->
        $ """
        <a class="reply"
           href="http://twitter.com/#{@username}/statuses/#{@statusID}">
           in reply to @#{@username}
        </a>
        """

    toElement: (options) ->
        element = super options
        if @reply?
            element.append @renderReply()

        element

    @from: (data) ->
        return data if data instanceof Tweet

        data = data.retweeted_status ? data

        reply = if data.in_reply_to_status_id?
            username: data.in_reply_to_screen_name
            userID: data.in_reply_to_user_id
            statusID: data.in_reply_to_status_id

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

class TwitterUserTimeline extends Timeline
    constructor: (username, options) ->
        extend @options, options
        @username = username.toLowerCase()
        @sendData =
            screen_name: @username
            count: @options.count
            include_rts: @options.includeRetweets

        super options

    update: (n) ->
        data = clone @sendData

        if @latest then data['since_id'] = @latest.id

        jQuery.ajax
            url: @queryUrl
            data: data
            success: (data) => @prePublish data

    queryUrl: "http://api.twitter.com/1/statuses/public_timeline.json"

    options: { includeRetweets: yes }

    userData: null

extend Chorus, {
    Tweet,
    TwitterTimeline,
    TwitterUserTimeline,
    TwitterSearchTimeline,
    TwitterAboutTimeline
}
