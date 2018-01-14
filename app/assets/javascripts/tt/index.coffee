#= require jquery.slideBox

$(document).ready ->
  $('.load-more-btn').click ->
    $el = $(this)
    
    return if $el.hasClass('disabled')

    $el_text = $el.find('.load-text')
    page = parseInt($el.data('page')) + 1

    $el_text.hide()
    $('.loading-box').show()

    $.get "/more?page=#{page}", (rsp) ->
      if rsp.html && $.trim(rsp.html) != ''
        $el.before rsp.html
        $el_text.show()
      else
        $el_text.show().text('没有更多了')
        $el.addClass('disabled')

      $el.data('page', page)
      $('.loading-box').hide()
    , 'json'

# view = {}
# view.onLoading = false
# view.scrollTop = 0
# view.page = 1
# view.canLoad = true

# $(window).on 'scroll', (e) ->
#   return if window.disableAutoLoading == true
#   return if not view.canLoad 
#   return if view.onLoading

#   top = $(this).scrollTop()
#   h = $(this).height()
#   d = $(document).height()
#   is_down_scroll = top > view.scrollTop
#   reach_bottom = top + h >= d - 300

#   if is_down_scroll && reach_bottom
#     view.onLoading = true
#     page = view.page + 1

#     $('.loading-box').show()

#     $.get "/more?page=#{page}", (rsp) ->
#       if rsp.html && $.trim(rsp.html) != ''
#         $('.loading-box').hide()
#         $('.loading-box').before rsp.html
#         view.onLoading = false
#         view.page = page
#       else
#         $('.loading-box').text('没有更多了')
#         view.canLoad = false

#       view.scrollTop = top
#     , 'json'


