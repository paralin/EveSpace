Template.orgs.helpers
    "organizations": ->
        Orgs.find()
Template.orgs.events
  "click .organization":->
    Router.go Router.routes["orgdetail"].path({id: @_id})
