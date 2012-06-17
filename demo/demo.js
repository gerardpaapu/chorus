new Chorus.View({
    feeds: ["@@boxerhockey"],
    container: "Twitter"
});


new Chorus.View({
    feeds: ["GH:sharkbrainguy/qorus"],
    container: "Github"
});


new Chorus.View({
    feeds: ["FF:paul"],
    container: "HackerNews"
});

Chorus.setGooglePlusAPIKey(Chorus.GOOGLE_PLUS_DEV_KEY);
new Chorus.View({
    feeds: ["+108227062559465276408"],
    container: "GooglePlus",
    count: 3
});
