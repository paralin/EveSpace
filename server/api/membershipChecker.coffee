@updateAll = (orgs)->
  for org in orgs
    updateMemberships org
@updateMemberships = (org)->
  return if !org?
  org = Orgs.findOne({_id: org._id})
  if org.lastChecked > (new Date().getTime())-10000
    return
  members = org.owners
  delReqs = []
  for req in org.memberReqs
    if req.type is "user"
      if Meteor.users.findOne({_id: req.id})?
        members.push(req.id)
      else
        #delReqs.push(req)
        #console.log "deleting user req "+req.id+", user doesn't exist"
        continue
    res = APIAuths.find({valid: true, type: req.type, id: req.id}).fetch()
    for r in res
      members.push r.userid
  #org.memberReqs = _.without.apply(_, org.memberReqs, delReqs)
  members = _.uniq members
  org.members = members
  if members.length > 0
    console.log "re-calculated members for "+org._id+" to "+members.length+" members"
    Orgs.update {_id: org._id}, {$set: {members: org.members, memberReqs: org.memberReqs, lastChecked: new Date().getTime()}}
  else
    console.log "organization "+org._id+" has no members! deleting"
    Orgs.remove {_id: org._id}
  org

@findOrgsForAPI = (auth)->
  Orgs.find({'memberReqs.type': auth.type, 'memberReqs.id': auth.id}).fetch()

#Watch various sources for re-calculation events
Meteor.startup ->
  APIAuths.find({valid: true}).observe
    added: (fields)->
      #console.log "API key added "+fields.keyid+", updating orgs"
      updateAll findOrgsForAPI fields
    updated: (fields)->
      #console.log "API key updated "+fields.keyid+", updating orgs"
      updateAll findOrgsForAPI fields
    removed: (fields)->
      #console.log "API key removed/invalid "+fields.keyid+", updating orgs"
      updateAll findOrgsForAPI fields
  Orgs.find({}, {fields: {memberReqs: 1, owners: 1}}).observe
    added: updateMemberships
    changed: updateMemberships
