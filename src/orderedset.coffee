_some = (fn) ->
    return true for i in this when fn(i)

    false

some = Array::some ? _some

class OrderedSet extends Events
    constructor: (@equal, @greater) ->
        @equal   ?= (a, b) -> a is b
        @greater ?= (a, b) -> b > a
        @items = []

    add: (items...) ->
        new_items = []
        equal   = @equal
        greater = @greater

        contains = (arr, item) ->
            some.call arr, (a) -> equal a, item

        is_new = (item) ->
            !( contains(new_items, item) or contains(@items, item) )

        for item in items when is_new item
            new_items.push item

        if new_items.length > 0
            items = @items.concat [new_items]

            items.sort (a, b) ->
                if greater(b, a) then -1 else 1

            @items = items

            @trigger 'update', this, new_items

    item: (n) -> @items[n]

    take: (n = @items.length - 1) -> @items[..n]

    drop: (n = 0) -> @items[n..]

    slice: (a, b) -> @items[a..b]
