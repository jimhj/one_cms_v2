# = require jquery
# = require jquery_ujs
# = require twbs-admin/bootstrap.min
# = require twbs-admin/sb-admin-2
# = require twbs-admin/menu
# = require redactor-rails
# = require redactor-rails/config
# = require bootstrap-select

$(document).ready ->
  $('.selectpicker').selectpicker()
  $('[data-toggle="tooltip"]').tooltip()