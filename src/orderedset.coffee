_some = (fn) ->
    return true for i in this when fn(i)

    false

some = Array::some ? _some

class OrderedSet
    ## A Set of items ordered so that:
    ##
    ##   greater(item(n + 1), item(n)) 
    ##
    ## and that for no two items `a` and `b`:
    ##    
    ##   equal(a, b)
    constructor: (@items = [], unique = no, sorted = no) ->
        if not unique
            @uniqify()
        else if not sorted
            @sort()

        @length = @items.length

    __constructor__: OrderedSet

    contains: (item) ->
        some.call @items, (a) => @equal a, item

    sort: ->
        @items.sort (a, b) => if @greater(b, a) then 1 else -1
        return this

    uniqify: ->
        # enforce the policy that no two
        # items (a, b) should be @equal(a, b)
        _items = @items
        @items = []

        for item in _items
            @items.push item unless @contains item

        @sort()
        return this

    addOne: (item) ->
        if @contains item
            this
        else
            new @__constructor__ @items.concat([item]), yes

    add: (items...) ->
        set = this

        for item in items
            set = set.addOne item

        return set

    concat: (items) ->
        if items instanceof OrderedSet
            @add items.items...
        else
            @add items...

    item: (n) -> @items[n]

    toArray: -> @items[0..]

    slice: -> @items.slice arguments...

    equal:   (a, b) -> a is b

    greater: (a, b) -> b > a

@Chorus.OrderedSet = OrderedSet
