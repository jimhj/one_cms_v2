$(function () {
  var timer;
  var duration = 59;
  var $btn = $('button.sendSMSCode');

  var disableButton = function () {
    $btn.addClass('disabled').attr('disabled', 'disabled');
    return $btn;
  };

  var reableButton = function () {
    $btn.removeClass('disabled').removeAttr('disabled');
    return $btn;
  };

  var activeCountDown = function () {
    disableButton();

    if (timer != undefined) {
      clearInterval(timer);
    }

    timer = setInterval(function () {
      $btn.text(duration + " 秒");
      duration = duration - 1;

      if (duration == 0) {
        reableButton().text("发送验证码");
        clearInterval(timer);
        duration = 59;
      }
    }, 1000);
  };

  $btn.click(function () {
    var mobile = $.trim($('#user_mobile').val());
    if (mobile == '') {
      alert('请输入手机号');
      return false;
    }

    disableButton();

    $.post('/send_active_code', { mobile: mobile }, function (rsp) {
      if (rsp.success) {
        activeCountDown();
      } else {
        reableButton().text("发送验证码");
      }
    }, 'json');
  });
});

 
