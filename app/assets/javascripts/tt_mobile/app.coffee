# = require jquery
# = require jquery_ujs
# = require iscroll.min

$(document).ready ->
  $('.mobileProfile').click ->
    $('.user-node-menu').toggleClass('hide')

  return_to = window.location.href
  $.get '/check_login', { return_to: return_to }, (rsp) ->
    $('.login-state').empty().append(rsp.login_html)
    $('.post-comment-box').empty().append(rsp.post_box)
  , 'json'

  $('.toggle-nodes-btn').click ->
    if $('body').hasClass('open-nodes-list')
      $('body').removeClass('open-nodes-list')
      $('.site-nodes-list').hide()
    else
      $('body').addClass('open-nodes-list')
      $('.site-nodes-list').show()

  $('.close-nodes-list').click ->
    if $('body').hasClass('open-nodes-list')
      $('body').removeClass('open-nodes-list')
      $('.site-nodes-list').hide()