Meteor.methods
  "createOrg": (name, groups)->
    check name, String
    check groups, Array
    if !@userId
      throw new Meteor.Error 403, "You are not logged in."
    #Validate every group
    members = validateGroups groups
    console.log "added new org "+name
    console.log JSON.stringify members
    org =
      name: name
      owners: [@userId]
      lastChecked: 0
      members: []
      memberReqs: members
    Orgs.insert org
    true
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

@validateGroups = (groups)->
  members = []
  for group in groups
    if !group.id? || !group.type?
      throw new Meteor.Error 403, "One of the groups you've added is malformed, probably a bug."
    if group.type is "user"
      if !Meteor.users.findOne({_id: group.id})?
        throw new Meteor.Error 404, "Can't find "+group.name+" in the database."
      members.push
        type: "user"
        id: group.id
        description: group.name
    else if group.type is "character"
      info = charInfoForID(group.id)
      if !info?
        throw new Meteor.Error 500, "Failed to verify "+group.name+" with EVE api."
      members.push
        type: "character"
        id: group.id
        description: group.name
    else if group.type is "corp"
      corp = CorpDB.findOne
        _id: group.id
      if !corp?
        throw new Meteor.Error 404, "Failed to verify "+group.name+" with EVE api."
      members.push
        type: "corp"
        id: corp._id
        description: "Corporation: "+corp.name
    else if group.type is "alliance"
      all = AllianceDB.findOne
        _id: group.id
      if !all?
        throw new Meteor.Error 404, "Couldn't verify "+group.name+" with EVE api."
      members.push
        type: "alliance"
        id: all._id
        description: "Alliance: "+all.name
    else
      throw new Meteor.Error 500, "Specified group "+group.name+" isn't a supported type of group."
  members
