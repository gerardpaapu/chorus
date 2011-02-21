{Timeline, Status} = Chorus = @Chorus
{extend} = $ = jQuery

class BuzzTimeline extends Timeline
    constructor: (userid, options) ->
        @userid = userid
        super options

    queryUrl: "http://ajax.googleapis.com/ajax/services/feed/load"

    fetch: ->
        feed_url = escape "http://buzz.googleapis.com/feeds/#{ @userid }/public/posted"
        data = "q=#{ feed_url }&num=#{ @options.count }&output=json&v=1.0"
        $.ajax
            url: "#{ @queryUrl }?#{ data }",
            dataType: 'jsonp',
            success: (json) => @update json

    statusesFromData: (data) ->
        unless data.responseStatus is 200 and data.responseData
            return []

        for entry in data.responseData.feed.entries
            BuzzStatus.from entry, @userid

class BuzzStatus extends Status
    renderAvatar: ->
        link = $ """<a href="#{ @getStreamUrl() }" class="avatar" />"""
        link.append buzzAvatar @username
        return link

    getStreamUrl: -> "http://www.google.com/profiles/#{@username}#buzz"

    getUrl: -> @id

    @from: (data, userid) ->
        new BuzzStatus data.link, userid || data.author, null, data.publishedDate, data.content

extend Chorus, {BuzzStatus, BuzzTimeline}

shorthands = [{
    pattern: /^BZ:(.*)$/,
    fun: (_, name) -> new BuzzTimeline name
}]

Timeline.shorthands = shorthands.concat Timeline.shorthands

cache = {}

buzzAvatar = (name) ->
    cached = cache[name]

    unless cached?
        init name
    else if cached.image?
        cached.image.clone()
    else
        placeholder name

init = (name) ->
    getGoogleAvatar name, removePlaceholders
    cache[name] = image: null, placeholders: []

    placeholder name

placeholder = (name) ->
    el = $ '<div class="placeholder" />'
    cache[name].placeholders.push el
    return el

removePlaceholders = (name, src) ->
    item = cache[name]
    item.image = $ """<img src="#{ src }" class="avatar" />"""
    item.image.clone().replaceAll(item.placeholders)

getGoogleAvatar = (name, callback) ->
    $.ajax
        url: "http://socialgraph.apis.google.com/otherme"
        data: { q: "#{name}@gmail.com" }
        dataType: "jsonp"
        jsonp: "jscb"
        success: (json) ->
            user = json["http://www.google.com/profiles/#{name}"]
            src  = user and user.attributes.photo

            callback name, src if src
