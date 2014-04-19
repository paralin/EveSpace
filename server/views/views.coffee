@createView = (name, orgid)->
  view =
    name: name
    org: orgid
    objects: []
  view._id = Views.insert view
  view

Meteor.methods
  "createView": (name, orgid)->
    if !@userId?
      throw new Meteor.Error 503, "You're not logged in."
    if name.length > 25 || name.length < 4
      throw new Meteor.Error 503, "The name must be between 25 and 4 characters."
    org = Orgs.findOne(_id: orgid)
    if !org?
      throw new Meteor.Error 404, "Can't find that organization."
    createView name, orgid
