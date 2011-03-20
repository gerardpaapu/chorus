# This module is a replacement for jquery.timeago
# for the no_query branch of qorus (which doesn't
# depend on, or include, jQuery).
#
# 1. Provide a method `timeago(date)` that
#    returns a string with a friendly description
#    of how long ago that date is.
#
# 2. Track elements with a certain class? and
#    update them periodically to contain the
#    friendly description for the associated date
#
# Unlike jquery.timeago, This doesn't need to be at all
# flexible, e.g. it can use epoch time in milliseconds to
# store dates and can find all its elements with
# document.getElementsByClassName(some_predefined_class),
# I really don't care about internationalization either,
# so let's hope it can stay small.

{getClass} = @Chorus

timeago = @Chorus.timeago = (timestamp) -> inWords distance timestamp

options = timeago.options =
    className: 'chorus_timestamp'

    refreshMillis: 60000

    strings:
        prefixAgo: null
        suffixAgo: "ago"
        seconds: "less than a minute"
        minute: "about a minute"
        minutes: "%d minutes"
        hour: "about an hour"
        hours: "about %d hours"
        day: "a day"
        days: "%d days"
        month: "about a month"
        months: "%d months"
        year: "about a year"
        years: "%d years"
        numbers: []

substitute = (template, number) ->
    string = if getClass(template) is "Function" then template(number) else template
    value = options.strings.numbers?[number] ? number
    string.replace /\%d/, value

inWords = (distanceMillis) ->
    strings = options.strings
    {round, floor} = Math
    seconds = distanceMillis / 1000
    minutes = seconds / 60
    hours = minutes / 60
    days = hours / 24
    years = days / 365

    words =
        if      seconds < 45  then substitute strings.seconds, round seconds
        else if seconds < 90  then substitute strings.minute, 1
        else if minutes < 45  then substitute strings.minutes, round minutes
        else if minutes < 90  then substitute strings.hour, 1
        else if hours   < 24  then substitute strings.hours, round hours
        else if hours   < 48  then substitute strings.day, 1
        else if days    < 30  then substitute strings.days, floor days
        else if days    < 60  then substitute strings.month, 1
        else if days    < 365 then substitute strings.months, floor days / 30
        else if years   < 2   then substitute strings.year, 1
        else substitute strings.years, floor years

    "#{words} #{strings.suffixAgo}"

distance = (date) ->
    switch getClass(date)
        when "Date"   then Date.now() - date.getTime()
        when "Number" then Date.now() - date
        when "String" then Date.now() - Date.parse(date)
        else throw new Error "Unsupported Date"

timer = null

timeago.startUpdating = ->
    unless timer?
        timer = window.setInterval update_timestamps, options.refreshMillis
        update_timestamps()

timeago.stopUpdating = ->
    if timer? then window.clearInterval timer

update_timestamps = timeago.update_timestamps = ->
    elements = document.getElementsByClassName options.className
    i = 0
    while i < elements.length
        element = elements.item i
        ms = element.getAttribute 'data-time'
        if /\d+/.test ms
            date = new Date parseInt ms, 10
            element.innerHTML = timeago date

        i++

trim = (str) ->
    str.replace(/^\s+/, '').replace(/\s+$/, '')
