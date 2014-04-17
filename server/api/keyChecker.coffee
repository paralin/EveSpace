neow = Meteor.require "neow"

#Automatically check everything every hour
checkPeriod = 60000*60

apiClient = (id, vcode)->
  client = new neow.EveClient
    keyID: id
    vCode: vcode

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
