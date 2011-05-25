Timeline = @Chorus.Timeline
toTimeline = Timeline.from

Timeline.from = (t) ->
    return t if t instanceof Timeline
    
    throw new TypeError() unless $.type t is "string"

    index = t.indexOf '['

    return toTimeline t if index is -1

    timeline = toTimeline t.slice 0, index 
    timeline.options.filter = parseFilter t.slice index

    timeline

parseFilter = (str) ->  
    i = 0
    groups = while i < str.length
        if str[i] != '[' then throw new Error("Unexpected #{str[i]}") 
        start = i + 1
        end = str.indexOf ']'
        i = end + 1 
        if end is -1 then throw new Error("Unmatched '[' from #{str}")

        extractTags str.slice(start, end)
        
    makeFilter groups

extractTags = (str) ->
    trim s for s in str.split(' ') when s.length > 0

matchGroup = (text, group) ->
    for tag in group when text.match tag
        return true

    false

makeFilter = (groups) ->
    (status) ->
        text = status.text

        for g in groups when !matchGroup( text, g )
            return false

        true

trim = (str) ->
    str.replace(/^\s+/, '').replace(/\s+$/, '')
