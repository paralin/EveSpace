@confirmf = (msg)->
  if CCPEVE?
    return true
  else
    return confirm msg
