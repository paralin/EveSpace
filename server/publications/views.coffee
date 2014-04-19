Meteor.publish "userViews", ->
  return [] if !@userId?
  sel = []
  for org in Orgs.find({members: @userId}, {fields: {_id: 1}}).fetch()
    sel.push org._id
  Views.find
    org: {$in: sel}
