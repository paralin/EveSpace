checkIfNull = ->
  group = Session.get("tAccessGroups")
  if !group?
    Session.set "tAccessGroups", []

Template.norg.agroups = ->
  Session.get "tAccessGroups"

Template.norg.events
  "click td .fa-ban": ->
    arr = Session.get "tAccessGroups"
    Session.set "tAccessGroups", _.without(arr, _.findWhere(arr, {id: @id}))
  "click .addUser": ->
    bootbox.prompt "What is the user's name?", (result)->
      return if !result?
      noti = $.pnotify
        title: "Adding User"
        text: "Adding user "+result+"..."
        type: "info"
        hide: false
      Meteor.call "agUserID", result, (err, res)->
        noti.remove()
        if err?
          $.pnotify
            title: "Couldn't Find User"
            text: err.reason
            type: "error"
        else if res?
          checkIfNull()
          groups = Session.get("tAccessGroups")
          for group in groups
            if group.id is res
              $.pnotify
                title: "Duplicate"
                type: "error"
                text: "You've already added "+result+"."
              return
          groups.push {type: "user", name: "User: "+result, id: res}
          Session.set("tAccessGroups", groups)
  "click .addCorp": ->
    bootbox.prompt "What is the corporation's name?", (result)->
      return if !result?
      noti = $.pnotify
        title: "Finding Corp"
        text: "Adding corp "+result+"..."
        type: "info"
        hide: false
      Meteor.call "agCorpID", result, (err, res)->
        noti.remove()
        if err?
          $.pnotify
            title: "Couldn't Find Corporation"
            text: err.reason
            type: "error"
        else if res?
          checkIfNull()
          groups = Session.get("tAccessGroups")
          for group in groups
            if group.id is res._id
              $.pnotify
                title: "Duplicate"
                type: "error"
                text: "You've already added "+res.name+"."
              return
          groups.push {type: "corp", name: "Corporation: "+res.name, id: res._id}
          Session.set("tAccessGroups", groups)
