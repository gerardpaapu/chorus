some = Array::some ?  (fn) ->
    return true for i in this when fn(i)

    false

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
            @__uniqify__()
        else if not sorted
            @__sort__()

        @length = @items.length

    __constructor__: OrderedSet

    __sort__: ->
        @items.sort (a, b) => if @greater(b, a) then 1 else -1

    __uniqify__: ->
        # enforce the policy that no two
        # items (a, b) should be @equal(a, b)
        _items = @items
        @items = []

        for item in _items
            @items.push item unless @contains item

        @__sort__()

    contains: (item) ->
        some.call @items, (a) => @equal a, item

    addOne: (item) ->
        if @contains item
            this
        else
            new @__constructor__ @items.concat([item]), yes

    add: (items...) ->
        # add each of the arguments to the set
        set = this

        for item in items
            set = set.addOne item

        return set

    concat: (ls) ->
        # add a collection of items to the set
        if ls instanceof OrderedSet
            @add ls.items...
        else
            @add ls...

    # set.item(i) -> array[i]
    item: (n) -> @items[n]

    toArray: -> @items[0..]

    slice: -> @items.slice arguments...

    equal: (a, b) -> a is b

    greater: (a, b) -> b > a

@Chorus.OrderedSet = OrderedSet
