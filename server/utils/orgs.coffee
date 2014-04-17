@getValidAuth = (userId, type, id)->
  APIAuths.findOne({userid: userId, valid: true, type: type, id: id})

#Check if a user COULD be in a group
@userCanBeInGroup = (userId, group)->
  #Check each delegation to see if it applies
  apiAuths = APIAuths.find({userid: userId}).fetch()
  for del in group
    if del.type is "user"
      return true if del.id is userId
    return true if getValidAuth(userId, del.type, del.id)?
  false

@userInOrg = (userId, orgId)->
  org = Orgs.findOne
    _id: orgId
  return false if !org?
  _.contains org.members, userId

#Check if user is in an organization by API
@userInOrgVerify = (userId, orgId)->
  user = Meteor.users.findOne
    _id: userId
  org = Orgs.findOne
    _id: orgId
  return false if !user? or !org?
  #Check if their API auths fit the requirements
  _.contains(org.owners, userId) || userCanBeInGroup(userId, org.members)
