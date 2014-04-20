global = @

lastRender = 0
shouldRenderMap = ->
  time = new Date().getTime()
  route = Router.current()
  res = time < lastRender+1000 || !route? || route.route.name isnt "view"
  if !res
    lastRender = time
  !res

generateLabel = (sys)->
  sys.n+"\nMorpheus Deathbrew - Tengu"

addSys = (sys)->
  id = parseInt sys._id
  g.graph.addNode id, {label:generateLabel(sys)}

addJump = (jump)->
  return if !_.contains(rsys, jump.s) || !_.contains(rsys, jump.t)
  g.graph.addEdge jump._id, jump.s, jump.t, {label: ""}

setupGraph = ->
  global.g = new ReactiveDagre ".mapContainer"
  SysDB.find().observe
    added: (sys)->
      addSys sys
      g.render() if shouldRenderMap()
    changed: (sys)->
      node = g.graph.node(sys._id)
      return if !node?
      node.label = generateLabel sys
      g.render() if shouldRenderMap()
    removed: (sys)->
      g.graph.delNode sys._id
      g.render() if shouldRenderMap()
  JumpDB.find().observe
    added: (jump)->
      addJump jump
      g.render() if shouldRenderMap()
    removed: (jump)->
      g.graph.delEdge jump._id
      g.render() if shouldRenderMap()

Meteor.startup setupGraph

redrawZ = ->
  d3.select('.mapContainer').attr "transform", "translate("+d3.event.translate+")"+" scale("+d3.event.scale+")"

setupZoom = ->
  d3.select(".zoom").call(d3.behavior.zoom().scaleExtent([0.3, 8]).on("zoom", redrawZ)).append('svg:g').append('svg:rect').attr('width', '100%').attr('height', '100%').attr('fill', 'black')

Template.viewBody.rendered = ->
  setupZoom()
  g.render()
