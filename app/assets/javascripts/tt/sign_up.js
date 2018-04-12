$(function () {
  var timer;
  var duration = 59;
  var $btn = $('button.sendCode');

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
    if ($('#new_user').is('.email-regist-form')) {
      var email = $.trim($('#user_email').val());
      if (email == '') {
        alert('请输入邮箱');
        return false;
      }

      if(!/^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$/.test(email)) {
        alert('请输入正确的邮箱');
        return false;
      }

      var req_url = "/send_email_code";
      var params = { email: email };

    } else {
      var mobile = $.trim($('#user_mobile').val());
      if (mobile == '') {
        alert('请输入手机号');
        return false;
      }

      if (!/^1[3|4|5|7|8][0-9]{9}$/.test(mobile)) {
        alert('请输入正确的手机号');
        return false;
      }

      var req_url = "/send_active_code";

      if ($('#new_user').is('.wx-bind-form')) {
        var params = { mobile: mobile, type: 'wx_auth' };
      } else  {
        var params = { mobile: mobile };
      }
    }

    disableButton();

    $.post(req_url, params, function (rsp) {
      if (rsp.success) {
        activeCountDown();
      } else {
        alert(rsp.error);
        reableButton().text("发送验证码");
      }
    }, 'json');
  });
});

 
