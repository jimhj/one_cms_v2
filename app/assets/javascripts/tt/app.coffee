# = require jquery
# = require jquery_ujs
# = require jquery.sticky-kit

$(document).ready ->
  return_to = window.location.href

  $.get '/check_login', { return_to: return_to }, (rsp) ->
    $('.login-state').empty().append(rsp.login_html)
    $('.post-comment-box').empty().append(rsp.post_box)
  , 'json'

  $(".header").stick_in_parent(parent: 'html').on "sticky_kit:stick", (e) ->
    $(e.target).addClass('active')
  .on "sticky_kit:unstick", (e) ->
    $(e.target).removeClass('active')

  $('body').on 'mouseenter', '.nav-dropdown-toggle', ->
    $(this).addClass('open')
  .on 'mouseleave', '.nav-dropdown-toggle', ->
    $(this).removeClass('open')

  $('body').on 'mouseenter', '.nav-menu-li', ->
    $(this).addClass('open')
  .on 'mouseleave', '.nav-menu-li', ->
    $(this).removeClass('open')