Meteor.publish "orgDetail", (id)->
  if !@userId? || !userInOrg(@userId, id)
    return []
  Orgs.find
    _id: id
