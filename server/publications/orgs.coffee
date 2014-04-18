Meteor.publish "orgList", ->
  if !@userId?
    return []
  Orgs.find
    members: @userId

Meteor.publish "orgDetail", (id)->
  if !@userId? || !userInOrg(@userId, id)
    return []
  Orgs.find
    _id: id
