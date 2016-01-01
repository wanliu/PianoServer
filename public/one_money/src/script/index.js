$(function() {
  $.ajax({
    url:'/api/promotions/one_money/1/items',
    type:'GET',
    success: function(itemsData) {
      alert(itemsData);
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
