FetchMetrics = new Meteor.Collection "alliancedbm"
client = null
Fiber = Meteor.npmRequire 'fibers'
#Every 2 hours
fetchAlliances = ->
  alls = []
  console.log "starting fetch alliances"
  client.fetch('eve:AllianceList').then((result)->
    for id, alliance of result.alliances
      all =
        _id: id
        name: alliance.name
        executorCorpID: alliance.executorCorpID
        shortName: alliance.shortName
        namelower: alliance.name.toLowerCase()
        memberCount: parseInt alliance.memberCount
        memberCorps: []
      for id, corp of alliance.memberCorporations
        all.memberCorps.push id
      alls.push all
    new Fiber(->
      AllianceDB.remove({})
      for all in alls
        AllianceDB.insert all
      FetchMetrics.remove({})
      FetchMetrics.insert time: new Date().getTime()
    ).run()
    console.log "fetched "+alls.length+" alliances"
  ).done()

Meteor.startup ->
  client = new neow.EveClient({
    keyID: '1234',
    vCode: 'notapplicable'
  })
  Meteor.setInterval fetchAlliances, 60000*60*2
  lastFetch = FetchMetrics.findOne()
  if lastFetch? and lastFetch.time > (new Date().getTime()-(60000*50*2))
    console.log "skipping alliance db fetch"
    return
  fetchAlliances()
