//= require jquery-ui.min
//= require tagit
//= require redactor-rails

(function($) {
  if (!$.curCSS) {
   $.curCSS = $.css;
  }
})(jQuery);

window.init_redactor = function(){
  var csrf_token = $('meta[name=csrf-token]').attr('content');
  var csrf_param = $('meta[name=csrf-param]').attr('content');
  var params;
  if (csrf_param !== undefined && csrf_token !== undefined) {
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
  }
  $('.redactor-editor').redactor({
        // You can specify, which ones plugins you need.
        // If you want to use plugins, you have add plugins to your
        // application.js and application.css files and uncomment the line below:
        // "plugins": ['fontsize', 'fontcolor', 'fontfamily', 'fullscreen', 'textdirection', 'clips'],
        // "buttons": ['html', 'formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule'],
        "imageUpload":"/redactor_rails/pictures?" + params,
        "imageGetJson":"/redactor_rails/pictures",
        "path":"/assets/redactor-rails",
        "css":"style.css",
        "minHeight": 400,
        "maxHeight": 800
      });
}

$(document).on( 'ready page:load', window.init_redactor );

$(document).ready(function () {
  $("#article_seo_keywords").tagit();
});