Template.navbar.activeRoute = (pg)->
  route = Router.current()
  if !route?
    return false
  "active" if _(route.route.name).startsWith pg
