{extend, getClass, $append, $fromHTML, $replace, jsonp} = @Chorus

class Embedly
    constructor: (options) ->
        @options = extend {}, @options, options
        @services = {}
        @patterns = []
        @queue = []

    options:
        max_photo_width: Infinity
        make_thumbnails: yes
        request_data: {}

    services: null

    patterns: null

    queue: null

    servicesLoaded: false

    intialized: false

    loadServices: ->
        @initialized = true

        jsonp
            url: "http://api.embed.ly/1/services/javascript"
            callback: (json) =>
                for {regex, name} in json
                    patterns = (RegExp str for str in regex)
                    @services[name] = patterns
                    @patterns.push patterns...

                @onServicesLoaded()

    onServicesLoaded: ->
        @servicesLoaded = yes
        @processQueue()

    processQueue: ->
        for {url, element} in @queue when @supported url
            @__make__(url, element)

        @queue = []

    make: (link) ->
        url = if getClass(link) is "String"
            link
        else
            link.getAttribute "href"

        placeholder = $fromHTML '<div class="embed_placeholder embed" />'

        @loadServices() unless @initialized

        unless @servicesLoaded
            @queue.push url: url, element: placeholder
        else if @supported url
            @__make__ url, placeholder
        else
            placeholder.className += ' unsupported'
            # I feel like I should do something here
            # to label the placeholder as an unsupported url

        placeholder

    @make: (link) ->
        Embedly.default ?= new Embedly()
        Embedly.default.make(link)

    __make__: (url, placeholder) ->
        data = extend {}, @options.request_data, {url: url}

        jsonp
            url: "http://api.embed.ly/v1/api/oembed"
            data: data
            callback: (json) =>
                if el = @fromJSON json
                    $replace placeholder, el

    supported: (url) ->
        throw Error "Services not Loaded" unless @servicesLoaded

        for pattern in @patterns
            return true if pattern.test url

        false

    fromJSON: (json) ->
        return @toThumbnail json if json.thumbnail_url? and @showThumbs

        switch json.type
            when "photo" then @toPhoto json
            when "video", "rich" then @toHtml json
            else false

    toPhoto: (json) ->
        ratio = json.height / json.width
        width = Math.min @options.max_photo_width, json.width
        height = parseInt ratio * width, 10

        """<img class="embed"
                src="#{json.url}"
                width="#{width}"
                height="#{height}" />"""

    toThumbnail: (json) ->
        """<a class="embed"
              href="#{json.url}">
              <img src="#{json.thumbnail_url}"
                   width="#{json.thumbnail_width}"
                   height="#{json.thumbnail_height}" />
           </a>"""

    toHtml: (json) ->
        """<div class="embed"
                style="width: #{json.width}px; height: #{json.height}px; overflow: hidden">
                #{json.html}
           </div>"""

Chorus.Embedly = Embedly
Chorus.extras ?= {}
Chorus.extras.embed_media = (element, body, status) ->
    el = $fromHTML '<div class="embedly_wrapper"/>'

    for link in body.getElementsByTagName 'a'
        $append el, Embedly.make(link)

    return el
