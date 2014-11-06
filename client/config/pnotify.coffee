Meteor.startup ->
    $.pnotify = (options)->
        new PNotify options
    PNotify.prototype.defaults.history = false
    PNotify.prototype.defaults.stack = {"dir1": "down", "dir2": "left", "firstpos1": 70, "firstpos2": 25}
    PNotify.prototype.defaults.nonblock = true
    PNotify.prototype.defaults.closer = false
    PNotify.prototype.defaults.sticker = false
