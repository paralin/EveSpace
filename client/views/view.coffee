Template.view.theView = ->
  route = Router.current()
  return if !route?
  Views.findOne({_id: route.params.id})
