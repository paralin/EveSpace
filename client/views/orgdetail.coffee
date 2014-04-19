Template.orgdetail.org = ->
  Orgs.findOne()
Template.orgdetail.isOwner = ->
  org = Orgs.findOne()
  return false if !org?
  isOrgOwner Meteor.userId(), org
Template.orgdetail.events
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
