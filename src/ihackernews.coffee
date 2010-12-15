## The unofficial hackerne.ws api ihackernews.com
{Status, Timeline} = Chorus = @Chorus
{extend} = $ = jQuery

class HNComment extends Status
    constructor: (@id, @username, @date, @text, @raw, @parentID) ->
        @avatar = ""

    getUrl: -> "http://news.ycombinator.com/item?id=#{@id}"

    getStreamUrl: -> "http://news.ycombinator.com/threads?id=#{@username}"

    renderAvatar: -> """
        <a href="#{@getStreamUrl()}" class="avatar">
            #{ smiley @username } 
        </a>"""

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

    update: ->
        jQuery.ajax
            url: "http://api.ihackernews.com/threads/#{@userid}"
            data: { format: 'jsonp'}
            dataType: 'jsonp'
            success: (data) => @prePublish data

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
    now = Date.now()

    minute = 60 * 1000
    hour   = 60 * minute
    day    = 24 * hour

    match = /([0-9]+) ([a-z]+)s? ago/.exec(str)

    return null unless match?

    [_, num, scale] = match

    diff = switch scale
        when "day",    "days"    then num * day
        when "hour",   "hours"   then num * hour
        when "minute", "minutes" then num * hour
        else null

    if diff?
        new Date(now - diff)
    else
        null

smiley = (name) ->
    eyes = "$^*@;TQs><?uveazoO096~"

    name_to_num = (str) ->
        total = 0
        i = str.length

        total += str.charCodeAt(i) while i--

        return total

    num = name_to_num name

    o = eyes[ num % eyes.length ]

    "#{o}_#{o}"
