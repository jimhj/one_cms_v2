# = require jquery
# = require jquery_ujs
# = require jquery.sticky-kit
# = require backToTop

$(document).ready ->
  $('.to-top').toTop()
  
  return_to = window.location.href

  $.get '/check_login', { return_to: return_to }, (rsp) ->
    $('.login-state').empty().append(rsp.login_html)
    $('.post-comment-box').empty().append(rsp.post_box)

    if rsp.hongbao_html
      $(rsp.hongbao_html).insertBefore('a.to-top')

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

  # 红包

  $('body').on 'click', '.open-hongbao-btn', ->
    $t = $(this)
    hongbao_id = $t.data('hongbao-id')

    $.post '/hongbaos/open', { hongbao_id: hongbao_id }, (rsp) ->
      if rsp.success
        alert '红包已打开，请在个人中心-我的红包-我的资产查看'

        if $t.is('.user-center')
          $t.text('已打开').removeClass('text-success').removeClass('text-underline')
      else
        alert rsp.error

      $('.hongbao').hide()
    , 'json'

  $('body').on 'click', '.hongbao-close', ->
    $(this).parents('.hongbao').hide()
