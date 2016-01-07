
function getQueryParams() {
  var search = location.search;
  var href = location.href;
  var hash;

  if (search) {
    hash = search.slice(1);
  } else {
    hash = href.split('?')[1];
  }

  var params = {};
  var ary = hash.split('&');

  for (var i=0; i<ary.length; i++) {
    var entry = ary[i].split('=');
    var key = entry[0];
    var value = entry[1];

    params[key] = value;
  }

  return params;
}

function parseResponseData(json) {
  var to_parsed_json_keys = [ 'avatar_urls', 'cover_urls', 'image_urls' ];
  var to_parsed_date_keys = [ 'start_at', 'end_at' ];
  var to_parsed_time_keys = [ 'created_at', 'updated_at' ];

  for (var key in json) {
    if (to_parsed_json_keys.indexOf(key) > -1) {
      json[key] = JSON.parse(json[key]);
    }

    if (to_parsed_date_keys.indexOf(key) > -1) {
      json[key] = Date.parse(json[key]);
    }

    if (to_parsed_time_keys.indexOf(key) > -1) {
      json[key] *= 1000;
    }
  }
}

function formatZero(val) {
  return +val < 10 ? '0' + val : val;
}

function formatDate(time) {
  var date = new Date(time);

  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var day = date.getDate();
  var hour = date.getHours();
  var minute = date.getMinutes();

  return [[year, formatZero(month), formatZero(day)].join('-')].join(' ');
}

var params = getQueryParams();
var one_money_id = params['one_money_id'];
var item_id = params['id'];
var url = ['/api/promotions/one_money/', one_money_id, '/items/', item_id].join('');
var beforeAjaxTime = new Date().getTime();
var $action = $('.actions');

$.ajax({
  type: 'GET',
  dataType: 'json',
  url: url,
  data: { u: beforeAjaxTime },
  success: function(json) {
    var afterAjaxTime = new Date().getTime();
    var diff = json.td;
    var sub = (afterAjaxTime - beforeAjaxTime) / 2;

    diff -= Math.ceil(sub);

    parseResponseData(json);

    var poster = json['image_urls'][0];
    var ori_price = json['ori_price'];
    var title = json['title'];
    var shop_name = json['shop_name'];
    var start_at = json['start_at'];
    var end_at = json['end_at'];
    var total_amount = json['total_amount'] || 0;
    var shop_name = json['shop_name'];
    var shop_avatar_url = json['shop_avatar_url'];
    var status = json['status'] || 'wait';
    var item_status = json['item_status'] || null;
    var element = $('.countdown-text');

    new CountDown(element, +total_amount, start_at+diff, end_at+diff, status, function(current_state) {
      if (item_status === 'always' || item_status === 'no-executies') return;

      switch(current_state) {
      case 'started':
        return $action.html('<button class="purchase-btn">马上抢购</button>');
      case 'end':
        return $action.html('<div class="end-text">活动已结束</div>');
      }
    });

    setTimeout(function() {
      element.parent().show();
    }, 1500);

    $('.ori_price').text(ori_price);
    $('img.poster').attr('src', poster);
    $('.item-title').text(title);
    $('.total-amount .inventory').text(total_amount);
    $('.start-end .time-desc').text(['活动时间', formatDate(start_at), '至', formatDate(end_at)].join(' '));

    $('.supplier-desc .avatar').attr('src', shop_avatar_url);
    $('.supplier-name').text(shop_name);

    // 如果存在抢购成功状态,判断是否是当前商品
    if (item_status == "always" || item_status == "no-executies") {
      url = [ '/api/promotions/one_money/', one_money_id, '/callback/', item_id ].join('');
      $.ajax({
        type: 'GET',
        dataType: 'json',
        url: url,
        success: function(json) {
          var grabs = json['grabs'];

          if (grabs.length > 0) {
            var grab = grabs[0];
            var grab_status = grab['status'];
            var callback_url = grab['callback_url'];

            if (grab_status === 'pending') {
              $action.html(['<a style="text-decoration:none;" href="', callback_url, '"><div class="always-text">领取奖励</div></a>'].join(''));
            } else if (grab_status === 'created') {
              $action.html('<div class="always-text">已领取奖品</div>');
            }
          } else {
            $action.html('<div class="always-text">没有抢购机会了</div>');
          }
          return;
        },
        error: function(res) {
          console.log(res);
        }
      });

      return;
    }

    switch(status) {
      case 'wait':
        return $action.html('<div class="wait-text">请耐心等待</div>');

      case 'started':
        return $action.html('<button class="purchase-btn">马上抢购</button>');

      case 'end':
        return $action.html('<div class="end-text">活动已结束</div>');

      case 'suspend':
        return $action.html('<div class="end-text">已售罄</div>');

      case 'no-executies':
        return $action.html('<div class="always-text">已经不能再抢此商品了</div>');

      default:
        return $action.html('<div class="wait-text">请耐心等待</div>');
    }
  },
  error: function(jqXHR, textStatus, errorThrown) {
    console.log(textStatus);
  }
});

// 抢购按钮
$action.on('click', '.purchase-btn', function(e) {
  e.stopPropagation();
  $.ajax({
    url: '/api/promotions/one_money/'+ one_money_id +'/grab/' + item_id,
    type: 'PUT',
    dataType: 'json',
    success: function(res) {
      if (res.status == 'success') {
        var callback_url = res.callback_url;
        $('.actions').html(['<a style="text-decoration:none;" href="', callback_url, '"><div class="always-text">领取奖励</div></a>'].join(''));

        AlertDismiss.getAlertDismiss('抢购提示', '恭喜您抢购成功！', {
          buttons: [ new ActionButton('领取奖励', res.callback_url, 'btn-success')]
        });
      }
    },
    error: function(res) {
      console.log(res);
      switch (res.status) {
        case 401: return AlertDismiss.getAlertDismiss('抢购提示', '您尚未 登陆/注册.', {buttons: [ new ActionButton('前往 登陆/注册 页面', '/authorize/weixin', 'btn')]});
        default: return AlertDismiss.getAlertDismiss('抢购提示', '抢购失败, 请稍后再试.');
      }
    }
  });
});
