Template.navbar.helpers
    "orgViews": ->
        res = []
        for org in Orgs.find().fetch()
            obj =
                views: Views.find({org: org._id}).fetch()
        if obj.views.length > 0
            res.push obj
        return null if res.length is 0
        res
    "activeRoute": (pg)->
        route = Router.current()
        if !route?
            return false
        "active" if _(route.route.name).startsWith pg
    "viewPath": ->
        Router.routes['view'].path({id: @_id})
