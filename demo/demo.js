$(function () {	
    // Uses the @@username shortcut for ConversationTimeline
    $("#Twitter").chorus("@@Ditzy_M/kiwifruit ");

    // Follows commits to the master branch of *this* project
    $("#Github").chorus("GH:sharkbrainguy/qorus");

    // Paul Graham on HackerNews
    // Paul Bucheit on FriendFeed
    $("#HackerNews").chorus("HN:pg", "HN:patio11", "FF:paul");

    // Follows me on Buzz... does anyone use buzz?
    $("#Buzz").chorus("BZ:sharkbrainguy");

    $("#GooglePlus").chorus("+108227062559465276408");
});
