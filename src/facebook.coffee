{Status, Timeline} = Chorus = @Chorus
{extend} = $ = jQuery

class FacebookStatus extends Status
    constructor: (id, username, avatar, date, text, raw, @userid) ->
        date = new Date().setISO8601(date)

        super id, username, avatar, date, text, raw

    getStreamUrl: -> "http://facebook.com/profile.php?id=#{@userid}"

    getUrl: -> "http://facebook.com/#{@userid}/posts/#{@id}"

    getAvatar: -> "https://graph.facebook.com/#{@userid}/picture"

    toElement: (options) ->
        element = super options

        if options.comment then $.ajax
            url: "https://graph.facebook.com/#{@userid}_#{@id}/comments"
            dataType: "jsonp"
            success: (json) =>
                if json.data.length > 0
                    container = $ '<div class="comments" />'
                    comments = (renderComment item for item in json.data)
                    container.append comments...
                    element.append container

        element

    @from = (data) ->
        return data if data instanceof Status

        match = /_(.*)$/.exec(data.id)
        id = match and match[1]
        link = data.source or data.link
        text = data.message ? ''
        from = data.from ? name: 'anonymous', id: null
        if link? then text += """ <a href="#{link}">#{ data.name or 'link' }</a>"""

        new FacebookStatus id, from.name, null, data.created_time, text, data, from.id

renderComment = (data) ->
    url = FacebookStatus::getStreamUrl.call {userid: data.from.id}
    """
    <p class="comment">
        <a href="#{url}" class="username">#{data.from.name}</a>
        #{ data.message }
    </p>"""

class FacebookTimeline extends Timeline
    constructor: (@username, options) ->
        @queryUrl = "https://graph.facebook.com/#{@username}/feed"
        super options

    update: (n) ->
        jQuery.ajax
            url: @queryUrl
            dataType: 'jsonp'
            success: (data) => @prePublish data

    statusesFromData: (json) -> FacebookStatus.from item for item in json.data

Timeline.shorthands.unshift
    pattern: /^FB:(.*)$/
    fun: (_, name) -> new FacebookTimeline name

`Date.prototype.setISO8601 = function(dString){
    var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/,
        d = dString.match(regexp);

    if (d != null) {
        var offset = 0;
        this.setUTCDate(1);
        this.setUTCFullYear(parseInt(d[1],10));
        this.setUTCMonth(parseInt(d[3],10) - 1);
        this.setUTCDate(parseInt(d[5],10));
        this.setUTCHours(parseInt(d[7],10));
        this.setUTCMinutes(parseInt(d[9],10));
        this.setUTCSeconds(parseInt(d[11],10));

        if (d[12]) {
            this.setUTCMilliseconds(parseFloat(d[12]) * 1000);
        } else {
            this.setUTCMilliseconds(0);
        }

        if (d[13] != 'Z') {
            offset = (d[15] * 60) + parseInt(d[17],10);
            offset *= ((d[14] == '-') ? -1 : 1);
            this.setTime(this.getTime() - offset * 60 * 1000);
        }
    } else {
        this.setTime(Date.parse(dString));
    }

    return this;
};`

extend Chorus, {FacebookStatus, FacebookTimeline}
