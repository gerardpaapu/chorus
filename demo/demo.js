$(function () {	
    // Uses the @@username shortcut for ConversationTimeline
    $("#Twitter").chorus("@@boxerhockey");

    // Follows commits to the master branch of *this* project
    $("#Github").chorus("GH:sharkbrainguy/qorus");

    // Paul Graham on HackerNews
    // Paul Bucheit on FriendFeed
    $("#HackerNews").chorus("FF:paul");

    // Barack Obama on Facebook
    $("#Facebook").chorus("FB:BarackObama");

    // Follows me on Buzz... does anyone use buzz?
    $("#Buzz").chorus("BZ:sharkbrainguy");
});
