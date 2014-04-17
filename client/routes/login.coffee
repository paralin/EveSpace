loginNot = null
Meteor.startup ->
  Meteor.autorun ->
    route = Router.current()
    if route?
      path = route.route.name
      if path is "login" && Meteor.user()?
        Router.go Session.get("preLogin")
Router.map ->
  @route 'login',
    path: 'login'
    action:->
      @redirect('/') if Meteor.user()?
      return if loginNot?
      @render "login"
      stack =
        dir1: "down"
        dir2: "left"
        firstpos1: 290
        firstpos2: 15
      loginNot = $.pnotify
        title: "Login Required"
        type: "error"
        text: "Click the above button to sign-in."
        nonblock: false
        hide: false
        stack: stack
    onStop: ->
      if loginNot?
        loginNot.remove()
        loginNot = null
