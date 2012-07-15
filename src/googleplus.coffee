{Timeline, Status, jsonp, $append, $fromHTML} = Chorus = @Chorus

Chorus.setGooglePlusAPIKey = (key) -> GPlusTimeline.api_key = key
Chorus.GOOGLE_PLUS_DEV_KEY = "AIzaSyD89SpEJuCNa1KBp14Tesjunno3I-XeROo"

class GPlusStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @url, @streamUrl, @attachments) ->
        super id, username, avatar, date, text, raw
   
    toElement: (options = {}) ->
        element = super options

        if @attachments? 
            for attachment in @attachments when attachment?
                $append element, attachment.toElement()

        element

    getUrl: -> @url

    getStreamUrl: -> @streamUrl
   
    getAvatar: -> QueryParameters.set @avatar, 'sz', 48

    @from: (data) ->
        {actor, url, published, object, id} = data 
        {displayName, image}  = actor

        if object.attachments?
            attachments = (GPlusAttachment.from d for d in object.attachments)

        new GPlusStatus id, displayName, image.url, published, object.content, data, url, actor.url, attachments

class GPlusAttachment
    constructor: (@type, @title, @url, @caption) ->

    toElement: ->
        el = $fromHTML """<div class="attachment" >
            <h3><a href="#{@url}">#{@title}</a></h3>
        </div>"""

        if @caption?
            $append el, $fromHTML("<p>#{@caption}</p>")

        el

    @from: (data) ->
        {image, fullImage, embed, url, id, objectType, displayName, content} = data 
        
        return null unless url? and displayName?
        
        new GPlusAttachment objectType, displayName, url, content 


class GPlusTimeline extends Timeline
    constructor: (@id, options) -> super options

    @api_key: null

    fetch: ->
        if GPlusTimeline.api_key?
            jsonp
                url: "https://www.googleapis.com/plus/v1/people/#{@id}/activities/public"

                data:
                    alt: 'json'
                    key: GPlusTimeline.api_key

                callback: (data) => @update data

    statusesFromData: (data) -> GPlusStatus.from item for item in data.items

Timeline.shorthands.unshift pattern: /^\+(\d+)$/, fun: (_, id) -> new GPlusTimeline(id)

# Read and write key/value pairs from/to query strings
class QueryParameters
    constructor: -> @data = {}

    decode = window.decodeURIComponent
    encode = window.encodeURIComponent

    read: (str) ->
        if str.charAt 0 is '?'
            str = str.slice 1
        
        for pair in str.split '&'
            [key, value] = pair.split '='
            @data[decode(key)] = decode(value)

        this
        
    write: ->
        pairs = []

        for key, value of @data  
            pairs.push(encode(key) + '=' + encode(value))

        if pairs.length is 0
            ''
        else
            '?' + pairs.join('&')

    set: (k, v) ->
        @data[k] = v
        return this

    get: (k, fallback) -> 
        if @data.hasOwnProperty(k)
            @data[k]
        else
            fallback

    @set: (url, k, v) ->
        [base, query] = url.split '?'

        _query = new QueryParameters(query).set(k, v).write()

        return base + _query

    @fromString: (str) ->
        new QueryParameters().read(str)

    @toString: (dict) ->
        q = new QueryParameters()
        q.data = dict
        q.write()
