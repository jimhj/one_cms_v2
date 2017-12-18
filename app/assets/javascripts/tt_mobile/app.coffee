# = require jquery
# = require jquery_ujs
# = require iscroll.min
# = require drawer.min

$(document).ready ->
  $('.drawer').drawer()

  return_to = window.location.href
  $.get '/check_login', { return_to: return_to }, (rsp) ->
    $('.login-state').empty().append(rsp.login_html)
  , 'json'