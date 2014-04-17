Router.map ->
  @route 'orgs',
    controller: AuthRequired
    path: '/orgs'
  @route 'orgdetail',
    controller: AuthRequired
    path: '/orgs/:id'
    waitOn:->
      Meteor.subscribe "orgDetail", @params.id
    action:->
      orgs = Orgs.findOne
        _id: @params.id
      if !args?
        @redirect Router.routes['orgs'].path()
        return
    data:->
      Orgs.findOne
        _id: @params.id
  @route 'norg',
    controller: AuthRequired
    path: '/org/new'
    template: 'norg'
    waitOn:->
      Meteor.subscribe "authKeys"
    onStart: ->
      Session.set "tAccessGroups", []
