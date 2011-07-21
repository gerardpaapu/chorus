{Timeline, Status, extend, jsonp} = Chorus = @Chorus

class BuzzTimeline extends Timeline
    constructor: (userid, options) ->
        @userid = userid
        super options

    queryUrl: "http://ajax.googleapis.com/ajax/services/feed/load"

    fetch: ->
        feed_url = escape "http://buzz.googleapis.com/feeds/#{ @userid }/public/posted"

        jsonp
            data:
                q: feed_url
                num: @options.count
                output: "json"
                v: "1.0"
            url: @queryUrl
            callback: (json) => @update json

    statusesFromData: (data) ->
        unless data.responseStatus is 200 and data.responseData
            return []

        for entry in data.responseData.feed.entries
            BuzzStatus.from entry, @userid

class BuzzStatus extends Status
    renderAvatar: ->
        link = Chorus.$fromHTML """<a href="#{ @getStreamUrl() }" class="avatar" />"""
        Chorus.$append link, buzzAvatar @username
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
    el = Chorus.$fromHTML '<div class="placeholder" />'
    cache[name].placeholders.push el
    return el

removePlaceholders = (name, src) ->
    item = cache[name]
    item.image = Chorus.$fromHTML """<img src="#{ src }" class="avatar" />"""
    for p in item.placeholders
        p.parentNode.replaceChild item.image.cloneNode(true), p

getGoogleAvatar = (name, callback) ->
    jsonp
        url: "http://socialgraph.apis.google.com/otherme"
        data: { q: "#{name}@gmail.com" }
        padding: "jscb"
        callback: (json) ->
            user = json["http://profiles.google.com/#{name}"]
            src  = user and user.attributes.photo

            callback name, src if src
