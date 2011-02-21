class Embedly
    constructor: (options) ->
        $.extend @options, options

    options:
        max_photo_width: Infinity
        make_thumbnails: yes

    services: null

    patterns: null

    queue: []

    servicesLoaded: false

    intialized: false

    data: {}

    loadServices: ->
        @initialized = true

        $.ajax
            url: "http://api.embed.ly/1/services/javascript"
            dataType: 'json'
            success: (json) =>
                for {regex, name} in json
                    patterns = Regexp str for str in regex
                    @services[name] = patterns
                    @patterns.push patterns

                @onServicesLoaded()

    onServicesLoaded: ->
        @servicesLoaded = yes
        @processQueue()

    processQueue: ->
        for {url, element} in @queue when @supported url
            @__make__(url, element)

        null

    make: (link) ->
        url = link.attr "href"
        placeholder = $ '<div class="embed embed_placeholder" />'

        @loadServices() unless @initialized

        unless @servicesLoaded
            @queue.push url: url, element: placeholder
        else if @supported url
            @__make__ url, placeholder

        placeholder

    __make__: (url, placeholder) ->
        data = $.merge {url: url}, @data

        $.ajax
            url: "http://api.embed.ly/v1/api/oembed"
            data: data
            success: (json) =>
                if el = @fromJSON json
                    el.replaceAll placeholder

    supported: (url) ->
        throw Error "Services not Loaded" unless @servicesLoaded

        for pattern in @patterns
            return true if pattern.test url

        false

    fromJson: (json) ->
        return @toThumbnail json if json.thumbnail_url? and @showThumbs

        switch json.type
            when "photo" then @toPhoto json
            when "video", "rich" then @toHtml json
            else false

    toPhoto: (json) ->
        ratio = json.height / json.width
        width = Math.max(@options.max_photo_width, json.width)
        height = parseInt(ratio * width, 10)
        img = document.createElement "img"
        img.src = json.url
        img.width = json.width
        img.height = json.height

        return img

    toThumbnail: (json) ->
        link = document.createElement "a"
        link.class = "embed"

        img = document.createElement "img"
        img.src = json.thumbnail_url
        img.width = json.thumbnail_width
        img.height = json.thumbnail_height

        link.appendChild img

        return link

    toHtml: (json) ->
        el = document.createElement "div"
        el.class = "embed"
        el.style.width = json.width
        el.style.height = json.height

        return el
