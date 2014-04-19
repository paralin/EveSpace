Template.orgdetail.org = ->
  Orgs.findOne()
Template.orgdetail.orgViews = ->
  org = Orgs.findOne()
  return if !org?
  Views.find
    org: org._id
Template.orgdetail.isOwner = ->
  org = Orgs.findOne()
  return false if !org?
  isOrgOwner Meteor.userId(), org
Template.orgdetail.events
  "click .oView": ->
    Router.go Router.routes['view'].path({id: @_id})
  "click .addView": ->
    org = Orgs.findOne()
    return if !org?
    bootbox.prompt "What would you like to name the new view?", (result)->
      return if !result?
      Meteor.call "createView", result, org._id, (err, res)->
        if err?
          $.pnotify
            title: "Can't Resign"
            text: err.reason
            type: "error"
        else
          $.pnotify
            title: "View Created"
            text: "New view ID: "+res._id+"."
            type: "success"
  "click .delOrg":->
    org = Orgs.findOne()
    return if !org?
    return if !isOrgOwner Meteor.userId(), org
    return if !confirmf "Are you sure you want to delete this organization and ALL of its data?"
    Meteor.call "delOrg", org._id, (err, res)->
      if err?
        $.pnotify
          title: "Can't Delete Organization"
          text: err.reason
          type: "error"
  "click .resignAdmin":->
    org = Orgs.findOne()
    return if !org?
    return if !isOrgOwner Meteor.userId(), org
    return if !confirmf "Are you sure you want to resign as admin?"
    Meteor.call "resignAsAdmin", org._id, Meteor.userId(), (err, res)->
      if err?
        $.pnotify
          title: "Can't Resign"
          text: err.reason
          type: "error"
  "click .addAdmin": ->
    org = Orgs.findOne()
    return if !org?
    return if !isOrgOwner Meteor.userId(), org
    bootbox.prompt "What is the user's name?", (result)->
      return if !result?
      Meteor.call "addOrgAdmin", org._id, result, (err, res)->
        if err?
          $.pnotify
            title: "Can't Add Admin"
            text: err.reason
            type: "error"
  "click .changeName":->
    org = Orgs.findOne()
    return if !org?
    bootbox.prompt "What would you like to name this org?", (result)->
      return if !result?
      Meteor.call "changeOrgName", org._id, result, (err, res)->
        if err?
          $.pnotify
            title: "Can't Change Name"
            text: err.reason
            type: "error"
