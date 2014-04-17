FetchMetrics = new Meteor.Collection "corpdbm"
parseString = Meteor.require('xml2js').parseString

#Update once per every hour
updateCorpDB = ->
  console.log "beginning corporation fetch"
  res = HTTP.get "http://www.eve-icsc.com/xml/corporationlist/corporations.xml"
  if res.statusCode != 200
    console.log "failed to fetch corps, status code is "+res.statusCode
    return
  parseString res.content, (err, res)->
    if err?
      console.log "error parsing corp list"
      console.log err
    else
      corps = res.content.corporations[0].corporation
      console.log "downloaded "+corps.length+" corporations"
      CorpDB.remove({})
      for corp in corps
        CorpDB.insert
          _id: corp.$.corporationID
          name: corp.$.corporationName
          namelower: corp.$.corporationName.toLowerCase()
      FetchMetrics.remove({})
      FetchMetrics.insert time: new Date().getTime()

Meteor.startup ->
  Meteor.setInterval updateCorpDB, 60000*60
  lastFetch = FetchMetrics.findOne()
  if lastFetch? and lastFetch.time > (new Date().getTime()-(60000*45))
    console.log "skipping corp db fetch, last fetch < 45 min ago"
    return
  updateCorpDB()
