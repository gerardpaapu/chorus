/*globals Chorus: false */
new Chorus.View({
    feeds: ["youtu.be"],
    container: "Twitter",
    updatePeriod: 500000, /* 3 Minutes */
    renderOptions: {
        extras: [ Chorus.extras.embed_media ]
    }
});

/*
new Chorus.View({
    feeds: ["GH:sharkbrainguy/qorus"],
    container: "Github"
});

new Chorus.View({
    feeds: ["HN:pg", "FF:paul"],
    container: "HackerNews"
});

new Chorus.View({
    feeds: ["FB:BarackObama"],
    container: "Facebook"
});

new Chorus.View({
    feeds: ["BZ:sharkbrainguy"],
    container: "Buzz"
});
*/
