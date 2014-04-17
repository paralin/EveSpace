#Views
#   A view can include objects from whatever
#   Its like a map
#
# Objects you're subscribed to are automatically added
# Objects that no longer exist are automatically deleted
#
# _id: id of the view
# name: name of the map
# owner: organization owning it
# objects:
#   [
#     {
#       type: "system",
#       x: posx
#       y: posy
#       id: object ID
#     }
#   ]
@Views = new Meteor.Collection "views"
