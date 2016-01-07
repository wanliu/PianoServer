HIDE_ITEMS = true;

$(function() {
  $('a.signup').click(function() {
    $.ajax({
      url: '/api/promotions/one_money/' + window.one_money_id + '/signup',
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        location.href = '/one_money/list.html';
      },
      error: function(jqXHR) {
        var json = jqXHR.responseJSON;

        if (jqXHR.status == 401) {
          var url = window.authorized_callback_url + '?status=' + json.status;

          location.href = window.signup_url + '?callback=' + encodeURIComponent(url);
        }
      }
    })
  });


  if (HIDE_ITEMS) return;
  $.ajax({
    url:'/api/promotions/one_money/1/items',
    type:'GET',
    success: function(itemsData) {
      itemsData.map(function(itemData) {
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
});
