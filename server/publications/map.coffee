Meteor.publish "eveMap", (region)->
  sys = SysDB.findOne({r: region})
  return [] if !sys?
  rid = sys.ri
  [SysDB.find({ri: rid}), JumpDB.find({r: rid})]
