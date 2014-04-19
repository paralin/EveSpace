Router.map ->
  @route 'view',
    controller: AuthRequired
    path: '/view/:id'
    action: ->
      #@render 'view'
      view = Views.findOne
        _id: @params.id
      if !view?
        $.pnotify
          title: "Can't Find View"
          text: "View "+@params.id+" does not exist."
          type: "error"
        @redirect Router.routes['orgs'].path()
        return
    data: ->
      @params.id
