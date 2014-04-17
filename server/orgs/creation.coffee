Meteor.methods
  "agUserID": (name)->
    if !@userId
      throw new Meteor.Error 403, "You are not logged in."
    user = Meteor.users.findOne
      username: name
    if !user?
      throw new Meteor.Error 404, "Couldn't find "+name+", it's case sensitive."
    user._id
  "agCorpID": (name)->
    if !@userId
      throw new Meteor.Error 403, "You are not logged in."
    CorpDB.findOne
      namelower: name.toLowerCase()
