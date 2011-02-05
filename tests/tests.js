var OrderedSet = Chorus.OrderedSet;

test("Initialized with an ordered, uniquified Array", function () {
    var set = new OrderedSet([1, 2, 3, 4, 5]);

    same( set.toArray(), [1, 2, 3, 4, 5], "OrderedSet::toArray");
    equals( set.item(0), 1, "OrderedSet::item");
    ok( set.contains(1),   "OrderedSet::contains");
    equals( set.length, 5,  "OrderedSet::length");
});

test("Initialized with an unsorted Array", function () {
    var set = new OrderedSet([1, 4, 3, 2, 5]);

    same( set.toArray(), [1, 2, 3, 4, 5], "OrderedSet::toArray");
    equals( set.item(0), 1, "OrderedSet::item");
    ok( set.contains(1),   "OrderedSet::contains");
    equals( set.length, 5,  "OrderedSet::length");
});

test("Initialized with an Array containing duplicates", function () {
    var set = new OrderedSet([1, 2, 2, 2, 3, 4, 5, 5, 5, 5]);

    same( set.toArray(), [1, 2, 3, 4, 5], "OrderedSet::toArray");
    equals( set.item(0), 1, "OrderedSet::item");
    ok( set.contains(1),   "OrderedSet::contains");
    equals( set.length, 5,  "OrderedSet::length");
});

test("Initialized with an unordered Array containing duplicates", function () {
    var set = new OrderedSet([3, 1, 2, 4, 5, 2, 5, 2, 5, 5]);

    same( set.toArray(), [1, 2, 3, 4, 5], "OrderedSet::toArray");
    equals( set.item(0), 1, "OrderedSet::item");
    ok( set.contains(1),   "OrderedSet::contains");
    equals( set.length, 5,  "OrderedSet::length");
});


test("Initialized with and Array, and called OrderedSet::concat", function () {
    var set = new OrderedSet([1, 2, 3]).concat([4, 5]);

    same( set.toArray(), [1, 2, 3, 4, 5], "OrderedSet::toArray");
    equals( set.item(0), 1, "OrderedSet::item");
    ok( set.contains(1),    "OrderedSet::contains");
    equals( set.length, 5,  "OrderedSet::length");

    ok( set.concat([5])  === set,  "OrderedSet::concat() will return identity");
    ok( set.concat([11]) !== set, "OrderedSet::concat() will return identity");
});
