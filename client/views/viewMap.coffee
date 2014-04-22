global = @

@shouldRenderMap = ->
  route = Router.current()
  res = !route? || route.route.name isnt "view"
  !res

global.mapDirty = false
Deps.autorun ->
  Session.get("500mstick")
  if global.mapDirty
    global.mapDirty = false
    global.g.render() if global.shouldRenderMap()

generateLabel = (sys)->
  sys.n+"\nMorpheus Deathbrew - Tengu"

updateSys = (sys)->
  node = g.graph.node(sys._id)
  return if !node?
  node.label = generateLabel sys
  global.mapDirty = true
rsys = []
addSys = (sys)->
  id = parseInt sys._id
  g.graph.addNode id, {label:generateLabel(sys)}, true
  global.mapDirty = true
  rsys.push id

addJump = (jump)->
  return if !_.contains(rsys, jump.s) || !_.contains(rsys, jump.t)
  g.graph.addEdge jump._id, jump.s, jump.t, {label: ""}, true
  global.mapDirty = true

setupGraph = ->
  global.g = new ReactiveDagre ".mapContainer"
  SysDB.find().observe
    added: (sys)->
      addSys sys
    changed: (sys)->
      updateSys sys
    removed: (sys)->
      g.delNode sys._id, true
      rsys = _.without rsys, sys._id
      global.mapDirty = true
  JumpDB.find().observe
    added: (jump)->
      addJump jump
      global.mapDirty = true
    removed: (jump)->
      g.delEdge jump._id, true
      global.mapDirty = true

Meteor.startup setupGraph

redrawZ = ->
  d3.select('.mapContainer').attr "transform", "translate("+d3.event.translate+")"+" scale("+d3.event.scale+")"

setupZoom = ->
  d3.select(".zoom").call(d3.behavior.zoom().scaleExtent([0.3, 8]).on("zoom", redrawZ)).append('svg:g').append('svg:rect').attr('width', '100%').attr('height', '100%').attr('fill', 'black')

Template.viewBody.theView = Template.view.theView

Template.viewBody.rendered = ->
  setupZoom()
  g.render()
