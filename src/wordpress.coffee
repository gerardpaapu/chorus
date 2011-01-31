{Timeline, Status, Tweet, TwitterUserTimeline} = Chorus = @Chorus
{extend} = $ = jQuery

class WordpressTimeline extends TwitterUserTimeline
    queryUrl: "http://twitter-api.wordpress.com/statuses/user_timeline.json"
    update: (data) ->
        super (WordpressStatus.from item for item in data)

class WordpressStatus extends Tweet
    getStreamUrl: -> "http://#{@username}"

    getURL: -> "http://#{@username}"

    @from = (json) ->
        return json if json instanceof Tweet

        reply = null
        {id, user, text, created_at} = json
        {screen_name, profile_image_url} = user

        new WordpressStatus id, screen_name, profile_image_url, created_at, text, json, reply

Timeline.shorthands.unshift {
    pattern: /^WP:(.*)$/i,
    fun: (_, name) -> return new WordpressTimeline(name)
}

extend Chorus, {WordpressTimeline, WordpressStatus}
