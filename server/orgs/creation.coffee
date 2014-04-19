Meteor.methods
  "delOrg": (orgid)->
    if !@userId?
      throw new Meteor.Error 403, "You are not logged in."
    org = Orgs.findOne(_id: orgid)
    if !org?
      throw new Meteor.Error 404, "Can't find that org."
    if !isOrgOwner @userId, org
      throw new Meteor.Error 403, "You are not an owner of this org."
    Orgs.remove {_id: orgid}
  "resignAsAdmin": (orgid, name)->
    if !@userId?
      throw new Meteor.Error 403, "You are not logged in."
    org = Orgs.findOne(_id: orgid)
    if !org?
      throw new Meteor.Error 404, "Can't find that org."
    if !isOrgOwner @userId, org
      throw new Meteor.Error 403, "You are not an owner of this org."
    if org.owners.length is 1
      throw new Meteor.Error 403, "You're the last admin, you can't resign."
    org.owners = _.without org.owners, _.findWhere org.owners, {id: @userId}
    Orgs.update {_id: orgid}, {$set: {owners: org.owners}}
  "addOrgAdmin": (orgid, name)->
    if !@userId?
      throw new Meteor.Error 403, "You are not logged in."
    org = Orgs.findOne(_id: orgid)
    if !org?
      throw new Meteor.Error 404, "Can't find that org."
    if !isOrgOwner @userId, org
      throw new Meteor.Error 403, "You are not an owner of this org."
    usera = Meteor.users.findOne
      username: name
    if !usera?
      throw new Meteor.Error 404, "Couldn't find "+name+", it's case sensitive."
    if isOrgOwner usera._id, org
      throw new Meteor.Error 403, "That user already is an admin of this group."
    org.owners.push
      id: usera._id
      name: usera.username
    Orgs.update {_id: orgid}, {$set: {owners: org.owners}}
  "orgRemReq": (orgid, reqid)->
    if !@userId?
      throw new Meteor.Error 403, "You are not logged in."
    org = Orgs.findOne(_id: orgid)
    if !org?
      throw new Meteor.Error 404, "Can't find that org."
    if !isOrgOwner @userId, org
      throw new Meteor.Error 403, "You are not an owner of this org."
    console.log "remove requirement "+reqid
    org.memberReqs = _.without org.memberReqs, _.findWhere org.memberReqs, {id: reqid}
    Orgs.update {_id: orgid}, {$set: {memberReqs: org.memberReqs}}
  "orgAddReq": (orgid, req)->
    if !@userId?
      throw new Meteor.Error 403, "You are not logged in."
    org = Orgs.findOne(_id: orgid)
    if !org?
      throw new Meteor.Error 404, "Can't find that org."
    if !isOrgOwner @userId, org
      throw new Meteor.Error 403, "You are not an owner of this org."
    console.log "add requirement "+JSON.stringify req
    [newReq] = validateGroups [req]
    org.memberReqs.push newReq
    Orgs.update {_id: orgid}, {$set: {memberReqs: org.memberReqs}}
  "changeOrgName": (id, name)->
    #check id, String
    #check name, String
    console.log id
    console.log name
    if !@userId?
      throw new Meteor.Error 403, "You are not logged in."
    org = Orgs.findOne(_id: id)
    if !org?
      throw new Meteor.Error 404, "Org "+id+" not found."
    if name.length > 30 || name.length < 4
      throw new Meteor.Error 403, "Org name must be within 4 and 30 characters."
    if !isOrgOwner @userId, org
      throw new Meteor.Error 403, "You are not an owner of this org."
    Orgs.update {_id: org._id}, {$set: {name: name}}
  "createOrg": (name, groups)->
    check name, String
    check groups, Array
    if !@userId
      throw new Meteor.Error 403, "You are not logged in."
    #Validate every group
    members = validateGroups groups
    console.log "added new org "+name
    console.log JSON.stringify members
    user = Meteor.users.findOne({_id: @userId})
    org =
      name: name
      owners: [{id: @userId, name: user.username}]
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
        description: group.description
    else if group.type is "character"
      info = charInfoForID(group.id)
      if !info?
        throw new Meteor.Error 500, "Failed to verify "+group.name+" with EVE api."
      members.push
        type: "character"
        id: group.id
        description: group.description
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
