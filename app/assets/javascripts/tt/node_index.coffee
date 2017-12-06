view = {}
view.onLoading = false
view.scrollTop = 0
view.page = 1
view.canLoad = true

$(window).on 'scroll', (e) ->
  return if not view.canLoad 
  return if view.onLoading

  top = $(this).scrollTop()
  h = $(this).height()
  d = $(document).height()
  is_down_scroll = top > view.scrollTop
  reach_bottom = top + h >= d - 300

  if is_down_scroll && reach_bottom
    view.onLoading = true
    page = view.page + 1

    url = "/fetch_articles/#{window.currentNode}?page=#{page}"
    $('.loading-box').show()

    $.get url, (rsp) ->
      if rsp.html && $.trim(rsp.html) != ''
        $('.node-articles .articles-section').append rsp.html
        view.onLoading = false
        view.page = page
      else
        view.canLoad = false

      $('.loading-box').hide()
      view.scrollTop = top
    , 'json'

$(document).ready ->
  $('.navNode').click (e) ->
    e.preventDefault && e.preventDefault()

    $link = $(e.currentTarget)
    $('.navNode').not($link).parent().removeClass('active')
    $link.parent().addClass('active')

    slug = $link.data('slug')
    url = "/fetch_articles/#{slug}"
    window.currentNode = slug

    $('.loading-box').show()
    $.get url, (rsp) ->
      $('.loading-box').hide()
      $('.node-articles .articles-section').empty().append rsp.html
      view.onLoading = false
      view.scrollTop = 0
      view.page = 1
      view.canLoad = true
    , 'json'

    return false


