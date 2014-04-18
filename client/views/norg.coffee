checkIfNull = ->
  group = Session.get("tAccessGroups")
  if !group?
    Session.set "tAccessGroups", []

executeCreate = ->
  name = $("input[name='orgname']").val()
  groups = Session.get("tAccessGroups")
  Meteor.call "createOrg", name, groups, (err, res)->
    if err?
      $.pnotify
        title: "Can't Create Org"
        text: err.reason
        type: "error"
    else
      Router.go Router.routes["orgdetail"].path(id: res)

Template.norg.rendered = ->
  $("#keyPanel").bootstrapValidator
    message: "Invalid input."
    feedbackIcons:
      valid: "glyphicon glyphicon-ok"
      invalid: "glyphicon glyphicon-remove"
      validating: "glyphicon glyphiocn-refresh"
    submitButtons: 'button[type="submit"]'
    submitHandler: (validator, form, submitButton)->
      executeCreate()
    fields:
      orgname:
        message: "Invalid organization name."
        validators:
          notEmpty:
            message: "Please name your organization."
          stringLength:
            min: 4
            max: 30
            message: "Please keep the name within 4-30 characters."
          regexp:
            regexp: /^[\w\-\s]+$/
            message: "Please use alphanumeric characters only."

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
  "click .addAlliance": ->
    bootbox.prompt "What is the alliance's name?", (result)->
      return if !result?
      noti = $.pnotify
        title: "Finding Alliance"
        text: "Adding alliance "+result+"..."
        type: "info"
        hide: false
      Meteor.call "agAllianceID", result, (err, res)->
        noti.remove()
        if err?
          $.pnotify
            title: "Couldn't Find Alliance"
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
          groups.push {type: "alliance", name: "Alliance: "+res.name, id: res._id}
          Session.set("tAccessGroups", groups)
  "click .addChar": ->
    bootbox.prompt "What is the character's name?", (result)->
      return if !result?
      noti = $.pnotify
        title: "Finding Character"
        text: "Adding character "+result+"..."
        type: "info"
        hide: false
      Meteor.call "agCharacterID", result, (err, res)->
        noti.remove()
        if err?
          $.pnotify
            title: "Couldn't Find Character"
            text: err.reason
            type: "error"
        else if res?
          checkIfNull()
          groups = Session.get("tAccessGroups")
          res =
            _id: res.characterID.content
            name: res.characterName.content
          for group in groups
            if group.id is res._id
              $.pnotify
                title: "Duplicate"
                type: "error"
                text: "You've already added "+res.name+"."
              return
          groups.push {type: "character", name: "Character: "+res.name, id: res._id}
          Session.set("tAccessGroups", groups)
