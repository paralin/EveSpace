Meteor.startup ->
    Orgs.find().observeChanges
        removed: (id)->
            console.log "org "+id+" removed, cleaning up..."
            Views.remove {org: id}
    Views.find().forEach (view)->
        org = Orgs.findOne(_id: view.org)
        if !org?
            Views.remove {_id: view._id}
