{Status, Timeline} = Chorus = @Chorus
{extend} = $ = jQuery

class FriendfeedStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @url) ->
        super id, username, avatar, parseUTC(date), text, raw

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

    fetch: ->
        $.ajax
            url: @queryUrl
            data: @sendData
            dataType: 'jsonp'
            success: (json) => @update json

    statusesFromData: (json) ->
        FriendfeedStatus.from entry for entry in json.entries

Timeline.shorthands.unshift {
    pattern: /^FF:(.*)$/,
    fun: (_, name) -> new FriendFeedTimeline name
}

parseUTC = (str) ->
    pattern = /(\d{4})\-(\d{2})\-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/
    match = pattern.exec str
    return new Date(0) if match is null

    [_, year, month, day, hour, minute, second] = match
    n = (s) -> parseInt s, 10
    date = new Date()
    date.setUTCFullYear n year
    date.setUTCMonth n(month) - 1
    date.setUTCDate n day
    date.setUTCHours n hour
    date.setUTCMinutes n minute
    date.setUTCSeconds n second

    date

extend Chorus, {FriendfeedStatus, FriendFeedTimeline}
