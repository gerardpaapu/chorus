## The unofficial hackerne.ws api ihackernews.com
{Status, Timeline} = Chorus = @Chorus
{extend} = $ = jQuery

class HNComment extends Status
    constructor: (@id, @username, @date, @text, @raw, @parentID) ->

    getUrl: -> "http://news.ycombinator.com/item?id=#{@id}"

    getStreamUrl: -> "http://news.ycombinator.com/threads?id=#{@username}"

    renderParent: -> """
        <a class="reply"
           href="http://news.ycombinator.com/item?id=#{ @parentID }">
            in reply to &hellip;
        </a>"""

    toElement: (options) ->
        element = super options
        if @parentID? then element.append @renderParent()

        element

    @from: (json) ->
        {comment, id, parentId, postedAgo, postedBy, postId} = json
        date = parse_date(postedAgo) or new Date()
        new HNComment id, postedBy, date, comment, json, parentId

class HNUserComments extends Timeline
    constructor: (@userid, options) ->
        super options

    fetch: ->
        jQuery.ajax
            url: "http://api.ihackernews.com/threads/#{@userid}"
            data: { format: 'jsonp'}
            dataType: 'jsonp'
            success: (data) => @update data

    statusesFromData: (data) ->
        HNComment.from item for item in data.comments

Timeline.shorthands.unshift
    pattern: /^HN:([a-z0-9-_]+)$/i,
    fun: (_, userid) -> new HNUserComments userid

parse_date = (str) ->
    # decodes dates produced by hacker news (from news.arc)
    # 
    # (def text-age (a)
    #  (tostring
    #    (if (>= a 1440) (pr (plural (trunc (/ a 1440)) "day")    " ago")
    #        (>= a   60) (pr (plural (trunc (/ a 60))   "hour")   " ago")
    #                    (pr (plural (trunc a)          "minute") " ago"))))
    match = /([0-9]+) ((day)|(hour)|(minute))s? ago/.exec(str)

    return null unless match?

    [_, num, unit] = match

    units =
        minute:        60 * 1000
        hour:     60 * 60 * 1000
        day: 24 * 60 * 60 * 1000

    new Date Date.now() - (units[unit] * Number(num))
