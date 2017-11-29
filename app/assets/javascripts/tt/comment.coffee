$(document).ready ->
  article_id = window.currentArticleId

  $('.comment-loading').show()
  $.get '/comments', { article_id: article_id }, (rsp) ->
    $('.comments-list').append rsp.html
    $('.comment-loading').hide()
  , 'json'

  $('body').on 'click', '.submitComment', ->
    $btn = $(this)
    content = $.trim $('textarea.post-field').val()

    if content == ''
      alert('请输入评论内容哦')
      rturn false

    params = { article_id, content: content }

    $btn.addClass('disabled')
    $('.comment-loading').show()
    $.post '/comments', params, (rsp) ->
      if rsp.success
        $('textarea.post-field').val('')
        $('.comments-list').prepend rsp.html
      else
        alert rsp.error

      $('.comment-loading').hide()
      $btn.removeClass('disabled')
    , 'json'