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

    getAvatar: -> "#{@avatar}?sz=48"

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
