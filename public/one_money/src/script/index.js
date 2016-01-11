HIDE_ITEMS = true;

// 获取活动时间用于显示在 index.html
$.ajax({
  url: '/api/promotions/one_money/'+ window.one_money_id,
  dataType: 'JSON',
  success: function(res) {
    var start_at = Date.parse(res.start_at)
      , start_at = Date.parse(res.end_at)
      , startEndTime = [formatTime(start_at).shortTime,'至',formatTime(start_at).shortTime].join('&nbsp;')

    $('.start-end-time').html(startEndTime);
  }
});

function formatTime(t) {
  var t       = new Date(t)
    , year    = t.getFullYear()
    , month   = t.getMonth()+1
    , day     = t.getDate()
    , hours   = t.getHours()
    , minutes = t.getMinutes();

  return {
    longTime:  [year, '年', month,'月', day, '日', hours, '时', minutes, '分'].join(''),
    shortTime: [month,'月', day, '日', hours, '时', minutes, '分'].join(''),
  }
}

$('a.signup').click(function() {
  $.ajax({
    url: '/api/promotions/one_money/' + window.one_money_id + '/signup',
    type: 'PUT',
    dataType: 'json',
    success: function(data) {
      location.href = '/one_money/list.html';
    },
    error: function(jqXHR) {
      var json = jqXHR.responseJSON;

      if (jqXHR.status == 401) {
        var url = window.authorized_callback_url + '?status=' + json.status;

        location.href = window.signup_url + '?callback=' + encodeURIComponent(url) + '&goto_one_money=true';
      }
    }
  })
});

if (!HIDE_ITEMS) {  // 如果需要在首页显示列表
  $.ajax({
    url:'/api/promotions/one_money/' + window.one_money_id + '/items',
    type:'GET',
    success: function(res) {
      console.log(res)
      res.items.map(function(itemData) {
        var imgUrl = JSON.parse(itemData.cover_urls)[0];
        var template = '<li>\
                          <a href="list.html#'+ itemData.id +'">\
                            <img src="'+ imgUrl+' "/>\
                            <div class="price-wrap">￥'+ itemData.price +'</div>\
                          </a>\
                        </li>'
        $('.preview-list').append(template)
      });
    }
  });
}
