Router.map ->
  @route 'home',
    path: '/'
    template: 'home'
  @route 'homer',
    path: '/home'
    action: ->
      @redirect '/'
