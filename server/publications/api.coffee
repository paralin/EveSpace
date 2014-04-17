Meteor.publish "authKeys", ->
  return [] if !@userId?
  APIAuths.find({userid: @userId})
