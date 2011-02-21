{Tweet, Timeline, TwitterTimeline, TwitterUserTimeline} = Chorus = @Chorus

class ConversationTimeline extends TwitterTimeline
    constructor: (username, options) ->
        @user = new TwitterUserTimeline username, options
        @replies = new ReplyTimeline @user

        @subscribe @replies
        @subscribe @user

class ReplyTimeline extends Timeline
    constructor: (@timeline) ->
        @subscribe @timeline

    update: (statuses) ->
        for status in statuses when status.reply?
            Tweet.fromID status.reply.statusID, (tweet) =>
                @statuses = @statuses.concat([ tweet ])
                @latest = @statuses.item 0
                @publish @statuses.toArray()

        this

Timeline.shorthands.unshift
    pattern: /^@@([a-z0-9-_]+)$/i
    fun: (_, name) -> new ConversationTimeline name

@Chorus.ReplyTimeline = ReplyTimeline
@Chorus.ConversationTimeline = ConversationTimeline
