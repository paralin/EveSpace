Meteor.startup ->
  if SysDB.find().count() is 0 || JumpDB.find().count() is 0
    SysDB.remove({})
    JumpDB.remove({})
    console.log "building system db from /data/all.json"
    data = JSON.parse Assets.getText 'eve-json/systems/all.json'
    for sys in data.systems
      SysDB.insert sys
    for jump in data.jumps
      JumpDB.insert jump
    console.log "loaded "+data.systems.length+" systems"
    console.log "loaded "+data.jumps.length+" jumps"
