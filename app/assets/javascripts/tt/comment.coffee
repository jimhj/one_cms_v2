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

  $('body').on 'mouseenter', '.comment', ->
    $(this).find('.reply-btn').show()
  .on 'mouseleave', '.comment', ->
    $(this).find('.reply-btn').hide()

  $('body').on 'click', '.comment .reply-btn', ->
    $rbtn = $(this)

    $('.reply-btn').not($rbtn)
                   .removeClass('cancel-btn')
                   .text('回复')
                   .parents('.comment-content')
                   .find('.reply-box')
                   .hide()

    origin_text = $rbtn.data('origin-text')
    cancel_text = $rbtn.data('cancel-text')
    $rbox = $rbtn.parents('.comment-content').find '.reply-box'

    if $rbtn.hasClass('cancel-btn')
      $rbtn.removeClass('cancel-btn').text origin_text
      $rbox.hide()
    else
      $rbtn.addClass('cancel-btn').text cancel_text
      $rbox.show()

  $('body').on 'click', '.submitComment', ->
    $btn = $(this)

    if $btn.hasClass('submitReply')
      content = $.trim $btn.parent().find('textarea').val()
      to_user_id = $btn.data('to_user_id')
      reply_to_id = $btn.data('reply_to_id')
    else
      content = $.trim $('textarea.post-field').val()
      to_user_id = null
      reply_to_id = null

    if content == ''
      alert('请输入评论内容哦')
      return false

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
        if $btn.hasClass('submitReply')
          $btn.parent().find('textarea').val('')
          $btn.parents('.comment-content').find('.instant-reply-text').text rsp.content
          $btn.parents('.comment-content').find('.instant-reply').show()
        else
          $('textarea.post-field').val('')

        $('.comments-list').append rsp.html

        if rsp.hongbao_html
          $(rsp.hongbao_html).insertBefore('a.to-top')

        if not $btn.hasClass('submitReply') && rsp.has_tag != "none"
          setTimeout ->
            window.location.hash = rsp.hash_tag
          , 100
      else
        alert rsp.error

      $('.comment-loading').hide()
      $btn.removeClass('disabled')

    , 'json'

  # $('body').on 'click', '.reply-btn', ->
  #   $btn = $(this)
  #   to_user_id = $btn.data('to_user_id')
  #   reply_to_id = $btn.data('reply_to_id')
  #   username = $btn.data("username")
  #   $('.submitComment').data('to_user_id', to_user_id)
  #   $('.submitComment').data('reply_to_id', reply_to_id)
  #   $('textarea.post-field').val("回复 #{username}：").focus()
