{Timeline, Status, jsonp} = Chorus = @Chorus

Chorus.GOOGLE_PLUS_DEV_KEY = "AIzaSyD89SpEJuCNa1KBp14Tesjunno3I-XeROo"

Chorus.setGooglePlusAPIKey = (key) -> GPlusTimeline.api_key = key

class GPlusStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @url, @streamUrl, @attachments) ->
        super id, username, avatar, date, text, raw
   
    toElement: (options = {}) ->
        element = super options

        if @attachments? 
            for attachment in @attachments when attachment?
                element.append(attachment.toElement())

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
        el = $ """<div class="attachment" >
            <h3><a href="#{@url}">#{@title}</a></h3>
        </div>"""

        if @caption?
            el.append "<p>#{@caption}</p>"

        el

    @from: (data) ->
        {image, fullImage, embed, url, id, objectType, displayName, content} = data 
        
        return null unless url? and displayName?
        
        new GPlusAttachment objectType, displayName, url, content 

class GPlusTimeline extends Timeline
    constructor: (@id, options) ->
        super options

    @api_key: null

    fetch: ->
        if GPlusTimeline.api_key?
            jQuery.ajax
                url: "https://www.googleapis.com/plus/v1/people/#{@id}/activities/public"

                dataType: 'jsonp'

                data:
                    alt: 'json'
                    key: GPlusTimeline.api_key

                success: (data) => @update data

    statusesFromData: (data) -> GPlusStatus.from item for item in data.items

Timeline.shorthands.unshift pattern: /^\+(\d+)$/, fun: (_, id) -> new GPlusTimeline(id)
