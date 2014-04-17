Meteor.methods
  "deleteKey": (id)->
    if !@userId?
      throw new Meteor.Error 403, "You aren't logged in yet."
    check id, String
    if id.length isnt 7
      throw new Meteor.Error 403, "That ID is malformed - should be 7 characters."
    old = APIAuths.findOne
      keyid: id
      userid: @userId
    if !old?
      throw new Meteor.Error 404, "Can't find that key for some reason."
    APIAuths.remove {keyid: id}
    true
  "refreshKey": (id)->
    if !@userId?
      throw new Meteor.Error 403, "You aren't logged in yet."
    check id, String
    if id.length isnt 7
      throw new Meteor.Error 403, "That ID is malformed - should be 7 characters."
    old = APIAuths.findOne
      keyid: id
      userid: @userId
    if !old?
      throw new Meteor.Error 404, "Can't find that key for some reason."
    vcode = old.vcode
    APIAuths.remove {keyid: id}
    console.log "user requested key refresh for "+id
    info = getKeyInfo id, vcode
    authRecords = generateAuthRecords @userId, info.characters, id, vcode
    for auth in authRecords
      console.log "  -> "+auth.description
      APIAuths.insert auth
    true
  "addAPIKey": (id, vcode)->
    if !@userId?
      throw new Meteor.Error 403, "You aren't logged in yet."
    check id, String
    check vcode, String
    if id.length isnt 7
      throw new Meteor.Error 403, "ID length must be 7."
    if vcode.length isnt 64
      throw new Meteor.Error 403, "The VCode length must be 64."
    idp = /^\d+$/
    vcodep = /^\w+$/
    if !idp.test id
      throw new Meteor.Error 403, "The ID must be an integer."
    if !vcodep.test vcode
      throw new Meteor.Error 403, "The vcode is alphanumeric."
    #first check if key is valid
    if !verifyKeyOK id, vcode
      throw new Meteor.Error 403, "The API key combo might be invalid."
    #get the given information
    info = getKeyInfo id, vcode
    if info.type isnt "Account" && info.type isnt "Character"
      console.log "key add failed, wrong type of key - "+info.type
      throw new Meteor.Error 403, "Corporation type API keys are not necessary."
    console.log "beginning new key verify for "
    console.log " -> id: "+id
    console.log " -> vcode: "+vcode
    authRecords = generateAuthRecords @userId, info.characters, id, vcode
    console.log "user added API key, generated "+authRecords.length+" auths"
    APIAuths.remove {keyid: id}
    for auth in authRecords
      console.log "  -> "+auth.description
      APIAuths.insert auth
    return true
