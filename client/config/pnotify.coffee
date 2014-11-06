Meteor.startup ->
    $.pnotify = (options)->
        new PNotify options
    PNotify.prototype.options.history = false
    PNotify.prototype.options.stack = {"dir1": "down", "dir2": "left", "firstpos1": 70, "firstpos2": 25}
    PNotify.prototype.options.nonblock = true
    PNotify.prototype.options.closer = false
    PNotify.prototype.options.sticker = false
