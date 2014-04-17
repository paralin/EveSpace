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
    corp = CorpDB.findOne
      namelower: name.toLowerCase()
    if !corp?
      throw new Meteor.Error 404, "Couldn't find that corp. It's a known issue that the EVE API doesn't show some corps in its records."
    corp
  "agAllianceID": (name)->
    if !@userId
      throw new Meteor.Error 403, "You are not logged in."
    all = AllianceDB.findOne
      namelower: name.toLowerCase()
    if !all?
      throw new Meteor.Error 404, "Couldn't find that alliance."
    all
  "agCharacterID": (name)->
    if !@userId
      throw new Meteor.Error 403, "You are not logged in."
    info = charInfoForName name
    if !info?
      throw new Meteor.Error 404, "Couldn't find that character."
    info
