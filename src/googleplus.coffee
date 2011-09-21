{Timeline, Status, Subscriber, extend, jsonp} = Chorus = @Chorus

Chorus.setGooglePlusAPIKey = (key) ->
    GPlusTimeline.api_key = key ? "AIzaSyD89SpEJuCNa1KBp14Tesjunno3I-XeROo"

class PlusStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @url, @streamUrl) ->
        super id, username, avatar, date, text, raw

    getUrl: -> @url

    getStreamUrl: -> @streamUrl

    @from: (data) ->
        {actor, url, published, object, id} = data 
        {displayName, image, stream}  = actor
        new PlusStatus id, displayName, image.url, published, object.content, data, url, stream

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

    statusesFromData: (data) -> PlusStatus.from item for item in  data.items

Timeline.shorthands.unshift pattern: /^\+(\d+)$/, fun: (_, id) -> new GPlusTimeline(id)