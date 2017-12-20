$(document).ready ->
  article_id = window.currentArticleId

  $('.comment-loading').show()
  $.get '/comments', { article_id: article_id }, (rsp) ->
    $('.comments-list').append rsp.html
    $('.articleHits').text "阅读 #{rsp.hits}"
    $('.articleComments').text "评论 #{rsp.count}"
    $('.articlePartition').text "#{rsp.count}"
    $('.comment-loading').hide()
  , 'json'

  $('body').on 'click', '.submitComment', ->
    $btn = $(this)
    content = $.trim $('textarea.post-field').val()

    if content == ''
      alert('请输入评论内容哦')
      rturn false

    to_user_id = $btn.data('to_user_id')
    reply_to_id = $btn.data('reply_to_id')

    params = { 
      article_id: article_id, 
      content: content, 
      to_user_id: to_user_id, 
      reply_to_id: reply_to_id 
    }

    $btn.addClass('disabled')
    $('.comment-loading').show()
    $.post '/comments', params, (rsp) ->
      if rsp.success
        $('textarea.post-field').val('')
        $('.comments-list').append rsp.html
        $btn.data('to_user_id', '')
        $btn.data('reply_to_id', '')
      else
        alert rsp.error

      $('.comment-loading').hide()
      $btn.removeClass('disabled')
    , 'json'

  $('body').on 'click', '.reply-btn', ->
    $btn = $(this)
    to_user_id = $btn.data('to_user_id')
    reply_to_id = $btn.data('reply_to_id')
    username = $btn.data("username")
    $('.submitComment').data('to_user_id', to_user_id)
    $('.submitComment').data('reply_to_id', reply_to_id)
    $('textarea.post-field').val("回复 #{username}：").focus()
