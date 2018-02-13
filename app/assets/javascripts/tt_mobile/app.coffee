# = require jquery
# = require jquery_ujs
# = require jquery.sticky-kit

$(document).ready ->
  $(".top-bar").stick_in_parent(parent: 'html')

  $('.mobileProfile').click ->
    $('.user-node-menu').toggleClass('hide')

  return_to = window.location.href
  $.get '/check_login', { return_to: return_to }, (rsp) ->
    $('.login-state').empty().append(rsp.login_html)
    $('.post-comment-box').empty().append(rsp.post_box)

    if rsp.hongbao_html
      $('body').append(rsp.hongbao_html)
      # $(rsp.hongbao_html).insertBefore('a.to-top')

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

  # 红包
  $('body').on 'click', '.open-hongbao-btn', ->
    $t = $(this)
    hongbao_id = $t.data('hongbao-id')

    $.post '/hongbaos/open', { hongbao_id: hongbao_id }, (rsp) ->
      if rsp.success
        alert "恭喜您获得 #{rsp.amount}，请在个人中心-我的红包-我的资产查看"

        if $t.is('.user-center')
          $t.text('已打开').removeClass('text-success').removeClass('text-underline')
      else
        alert rsp.error

      $('.hongbao').hide()
    , 'json'

  $('body').on 'click', '.hongbao-close', ->
    $(this).parents('.hongbao').hide()