startCheckKeys = ->
  Session.set "checkingKey", true
  id = $("input[name='keyid']").val()
  vcode = $("input[name='vcode']").val()
  Meteor.call "addAPIKey", id, vcode, (err, res)->
    Session.set "checkingKey", false
    if err?
      $.pnotify
        title: "Key Not Verified"
        text: err.reason
        delay: 5000
        type: "error"
    else
      $.pnotify
        title: "Auth Added"
        text: "The key as been added successfully."
        type: "success"
        delay: 3000
      Router.go Router.routes['api'].path()

Template.nkey.checking = ->
  Session.get "checkingKey"

Template.newKeyPanel.rendered = ->
  $("#keyPanel").bootstrapValidator
    message: "Invalid input!"
    feedbackIcons:
      valid: "glyphicon glyphicon-ok"
      invalid: "glyphicon glyphicon-remove"
      validating: "glyphicon glyphicon-refresh"
    submitButtons: 'button[type="submit"]'
    submitHandler: (validator, form, submitButton)->
      startCheckKeys()
    fields:
      keyid:
        message: "Invalid API key format."
        validators:
          notEmpty:
            message: "You need the key ID to add the key."
          stringLength:
            min: 7
            max: 7
            message: "An API key ID is 7 characters, ex: 3279359"
          regexp:
            regexp: /^\d+$/
            message: "An API key ID is an integer, ex: 3279359"
      vcode:
        validators:
          notEmpty:
            message: "You need the verifcation code."
          stringLength:
            min: 64
            max: 64
            message: "The vcode is 64 characters long."
          regexp:
            regexp: /^\w+$/
            message: "An API key contains alphanumeric characters only."
