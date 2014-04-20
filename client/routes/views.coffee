Router.map ->
  @route 'view',
    controller: AuthRequired
    path: '/view/:id'
    waitOn: ->
      Meteor.subscribe "eveMap", "Delve"
    action: ->
      view = Views.findOne
        _id: @params.id
      if !view?
        $.pnotify
          title: "Can't Find View"
          text: "View "+@params.id+" does not exist."
          type: "error"
        @redirect Router.routes['orgs'].path()
        return
      @render 'view'
    data: ->
      @params.id
