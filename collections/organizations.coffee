# An organization is an owner of a set of data
# Corporations, users, or alliances can be added to organizations
# All data is owned by an organization
#
#   _id: organization ID
#   name: the name
#   owners: [userID]
#   lastChecked: unixtime
#   members: [userID]
#   memberReqs: [
#     user: 
#       type: "user"
#       id: user ID
#       name: text
#     corp:
#       type: "corp"
#       id: corporation ID (API)
#     alliance:
#       type: "alliance"
#       id: alliance ID (API)
#     character:
#       id: character ID (API)
#       type: "character"

@Orgs = new Meteor.Collection "orgs"
