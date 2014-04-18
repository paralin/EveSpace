Router.map ->
  @route 'orgs',
    controller: AuthRequired
    path: '/orgs'
    waitOn: ->
      Meteor.subscribe "orgList"
  @route 'orgdetail',
    controller: AuthRequired
    path: '/orgs/:id'
    waitOn:->
      Meteor.subscribe "orgDetail", @params.id
    action:->
      org = Orgs.findOne
        _id: @params.id
      if !org?
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
