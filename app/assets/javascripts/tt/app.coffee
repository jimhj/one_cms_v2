# = require jquery
# = require jquery_ujs
# = require jquery.sticky-kit

$(document).ready ->
  # $('.node-sidebar').sticky({ topSpacing: 16 })
  # $('.ad-fixed').sticky({ topSpacing: 16 })
  $(".header").stick_in_parent(parent: 'body').on "sticky_kit:stick", (e) ->
    $(e.target).addClass('active')
  .on "sticky_kit:unstick", (e) ->
    $(e.target).removeClass('active')

  # $('.ad-fixed').stick_in_parent(parent: 'html', offset_top: 16)

  # $('.more-node').mouseenter ->
  #   $('.h-dropdown').show()
  # .mouseleave ->
  #   $('.h-dropdown').hide()
