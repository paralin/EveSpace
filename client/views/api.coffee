Template.api.keys = ->
  APIAuths.find()
Template.api.keyClass = ->
  if @valid then null else "danger" #too much green
Template.api.formatNextCheck = ->
  moment(@gooduntil).fromNow()
Template.api.events
  "click tr .fa-ban": ->
    if !confirm "Are you sure you want to remove API key "+@keyid+"?"
      return
    Meteor.call "deleteKey", @keyid, (err, res)->
      if err?
        $.pnotify
          title: "Can't Delete Key"
          text: err.reason
          type: "error"
  "click tr .fa-refresh": ->
    if !confirm "Are you sure you want to re-check this key?"
      return
    Meteor.call "refreshKey", @keyid, (err, res)->
      if err?
        $.pnotify
          title: "Can't Check Key"
          text: err.reason
          type: "error"
