@neow = Meteor.npmRequire "neow"
idCache = {}

#Automatically check everything every hour
checkPeriod = 60000*60

anonClient = ->
  new neow.EveClient

apiClient = (id, vcode)->
  client = new neow.EveClient
    keyID: id
    vCode: vcode

@charInfoForID = (id)->
  res = Async.runSync (doned)->
    anonClient().fetch('eve:CharacterInfo', characterID: id)
      .then((result)->
        doned(null, result)
      ).catch((err)->
        console.log "error checking character info "+JSON.stringify err
        doned(err, null)
      ).done()
  if res.error?
    throw new Meteor.Error 500, "EVE API is having trouble completing this request."
  res.result

@charInfoForName = (name)->
  console.log "looking up "+name
  id = idCache[name.toLowerCase()]
  if !id?
    result = Async.runSync (done)->
      anonClient().fetch('eve:CharacterID', names: name)
        .then((result)->
          id = Object.keys(result.characters)[0]
          name = result.characters[id].name
          done(null, [id, name])
        ).catch((err)->
          console.log "error looking up CharacterID"
          console.log err
          done(err, null)
        ).done()
    if result.error?
      throw new Meteor.Error 500, "EVE API is having trouble completing this request."
    [id, name] = result.result
  console.log "id: "+id
  console.log "name: "+name
  return if id is '0'
  idCache[name.toLowerCase()] = id
  charInfoForID id

@generateAuthRecords = (uid, charList, kid, vcode)->
  #Get all character records
  console.log "generating auth records for key id "+kid
  res = []
  corpNames = {}
  corps = []
  characters = []
  characterNames = {}
  alliances = []
  allianceNames = {}
  for id, char of charList
    characters.push(id)
    characterNames[id] = char.characterName || char.name
    if char.corporationID != '0'
      corps.push(char.corporationID)
      corpNames[char.corporationID] = char.corporationName
    if char.allianceID != '0'
      alliances.push(char.allianceID)
      allianceNames[char.allianceID] = char.allianceName
  corps = _.uniq corps
  characters = _.uniq characters
  alliances = _.uniq alliances
  for char in characters
    name = characterNames[char]
    record =
      gooduntil: checkPeriod+(new Date().getTime())
      valid: true
      type: "character"
      description: "Character: "+name
      userid: uid
      keyid: kid
      id: char
      vcode: vcode
    res.push record
  for corp in corps
    name = corpNames[corp]
    record =
      gooduntil: checkPeriod+(new Date().getTime())
      valid: true
      type: "corp"
      description: "Corporation: "+name
      userid: uid
      keyid: kid
      vcode: vcode
      id: corp
    res.push record
  for alliance in alliances
    name = allianceNames[alliance]
    record =
      gooduntil: checkPeriod+(new Date().getTime())
      valid: true
      type: "alliance"
      description: "Alliance: "+name
      userid: uid
      keyid: kid
      vcode: vcode
      id: alliance
    res.push record
  res

@verifyKeyOK = (id, vcode)->
  res = HTTP.get "https://api.eveonline.com/account/APIKeyInfo.xml.aspx",
    params:
      keyID: id
      vcode: vcode
  if res.statusCode isnt 200
    console.log "key invalid, res:"
    console.log res.content
  res.statusCode is 200

#Gets data from a character API key
@getKeyInfo = (id, vcode)->
  client = apiClient id, vcode
  res = null
  Async.runSync (done)->
    client.fetch('account:APIKeyInfo')
      .then((result)->
        res = result
        done()
      ).done()
  res.key
