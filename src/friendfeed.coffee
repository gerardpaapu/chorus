{Status, Timeline} = Chorus = @Chorus
{extend} = $ = jQuery

class FriendfeedStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @url) ->
        super id, username, avatar, date, text, raw

    getAvatar: -> "http://friendfeed-api.com/v2/picture/#{@username}?size=medium"

    getUrl: -> @url

    getStreamUrl: -> "http://friendfeed.com/#{@username}"

    @from: (json) ->
        return json if json instanceof Status

        {id, from, date, body, url} = json

        new FriendfeedStatus id, from.id, null, date, body, json, url


class FriendFeedTimeline extends Timeline
    constructor: (username, options) ->
        @username = username.toLowerCase()
        @sendData =
            num: @options.count
            maxcomments: 0
            maxlikes: 0

        @queryUrl = "http://friendfeed-api.com/v2/feed/#{@username}"

        super options

    update: ->
        $.ajax
            url: @queryUrl
            data: @sendData
            dataType: 'jsonp'
            success: (json) -> @prePublish data

    statusesFromData: (json) ->
        FriendfeedStatus.from entry for entry in json.entries

Timeline.shorthands.unshift {
    pattern: /^FF:(.*)$/,
    fun: (_, name) -> new FriendFeedTimeline name
}

extend Chorus, {FriendfeedStatus, FriendFeedTimeline}
