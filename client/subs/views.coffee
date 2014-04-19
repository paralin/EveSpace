Meteor.startup ->
  Deps.autorun ->
    return if !Meteor.userId()?
    Meteor.subscribe "userViews"
