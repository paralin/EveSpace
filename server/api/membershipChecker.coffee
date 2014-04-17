@updateAll = (orgs)->
  for org in orgs
    updateMemberships org
@updateMemberships = (org)->
  return if !org?
  members = []
  delReqs = []
  for req in org.memberReqs
    if req.type is "user"
      if Meteor.users.findOne({_id: req.id})?
        members.push(req.id)
      else
        delReqs.push(req)
      continue
    res = APIAuths.find({valid: true, type: req.type, id: req.id}).fetch()
    for r in res
      members.push r.userid
  org.memberReqs = _.without.apply(_, org.memberReqs, delReqs)
  members = _.uniq members
  org.members = members
  console.log "re-calculated members for "+orgId+" to "+members.length+" members"
  Orgs.update {_id: orgId}, {$set: {members: org.members, memberReqs: org.memberReqs, lastChecked: new Date().getTime()}}
  org

@findOrgsForAPI = (auth)->
  Orgs.find
    'memberReqs.type': auth.type
    'memberReqs.id': auth.id

#Watch various sources for re-calculation events
Meteor.startup ->
  APIAuths.find({valid: true}).observe
    added: (fields)->
      updateAll findOrgsForAPI fields
    removed: (fields)->
      updateAll findOrgsForAPI fields

  Orgs.find({}, {fields: {memberReqs: 1, owners: 1}}).observe
    added: updateMemberships
    changed: updateMemberships
