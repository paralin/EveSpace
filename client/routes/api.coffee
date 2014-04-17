Router.map ->
  @route 'api',
    path: 'auth'
    template: 'api'
    waitOn: ->
      Meteor.subscribe "authKeys"
  @route 'nkey',
    path: '/auth/new'
    template: 'nkey'
    onRun: ->
      Session.set "checkingKey", false
