var view;
$(function() {	
    view = new Chorus.View({
        'feeds': ["@sharkbrain"], 
        'count': 10
    });

    view.toElement().appendTo(document.body);
});
