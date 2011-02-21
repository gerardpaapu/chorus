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

test("Ordering statuses", function () {
    var ls = new OrderedSet(test_tweets),
        i, j, k, l = ls.length,

        correct_order = true,
        no_dupes = true;

    for (i = 0; i + 1 < l; i++) {
        for (j = 1; i + j < l; j++) {
            k = i + j; // k and i are valid indexes, and k > i
            if (// test that item[k] > item[i] 
                !ls.items[k].__gt__(ls.items[i]) ||
                // test that !(item[i] > item[k])
                ls.items[i].__gt__(ls.items[k])) {
                correct_order = false;
            }

            if (ls.items[i].__eq__(ls.items[k]) || ls.items[k].__eq__(ls.items[i])){
                no_dupes = false;
            }
        }
    }

    ok(correct_order, "Correct order");
    ok(no_dupes, "No duplicates");
});
