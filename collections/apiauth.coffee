##API Authorizaztions
# Basically just saying if you're associated with something
#
# _id: ID of the authorization
# gooduntil: how long until the API is bad?
# valid: last checked if valid?
# type: "corp", "character", "alliance"
# description: "Character: Morpheus Deathbrew"
# userid: user id
# keyid:
# vcode: 
# id: character id, alliance id, anything

@APIAuths = new Meteor.Collection "authorizations"
