global = @

lastRender = 0
dontRenderMap = ->
  time = new Date().getTime()
  route = Router.current()
  res = time < lastRender+1000 || !route? || route.route.name isnt "view"
  if !res
    lastRender = time
  res

rsys = []
addSys = (sys)->
  id = parseInt sys._id
  g.graph.addNode id, {label: sys.n}
  rsys.push id

addJump = (jump)->
  return if !_.contains(rsys, jump.s) || !_.contains(rsys, jump.t)
  g.graph.addEdge jump._id, jump.s, jump.t, {label: ""}

addAllExisting = ->
  for sys in SysDB.find().fetch()
    addSys sys
  for jmp in JumpDB.find().fetch()
    addJump jmp

setupGraph = ->
  global.g = new ReactiveDagre ".mapContainer"
###
  SysDB.find().observe
    added: (sys)->
      return if dontRenderMap() #wait for the data first
      addSys sys
    removed: (sys)->
      return if dontRenderMap()
      g.delNode sys._id
      renderedSystems = _.without renderedSystems, sys._id
  JumpDB.find().observe
    added: (jump)->
      return if dontRenderMap()
      g.addEdge jump._id, jump.s, jump.t, {label: ""}, dontRenderMap()
###

Meteor.startup setupGraph

redrawZ = ->
  d3.select('.mapContainer').attr "transform", "translate("+d3.event.translate+")"+" scale("+d3.event.scale+")"

setupZoom = ->
  d3.select(".zoom").call(d3.behavior.zoom().scaleExtent([0.3, 8]).on("zoom", redrawZ)).append('svg:g').append('svg:rect').attr('width', '100%').attr('height', '100%').attr('fill', 'black')

Template.viewBody.rendered = ->
  addAllExisting()
  setupZoom()
  g.render()
