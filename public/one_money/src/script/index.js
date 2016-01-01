$(function() {
  $.ajax({
    url:'/api/promotions/one_money/1/items',
    data: {},
    success: function(itemsData) {
      console.log(itemsData);
      itemsData.map(function(itemData) {
        console.log(itemData);
        var imgUrl = JSON.parse(itemData.cover_urls)[0];
        var template = '<li>
                          <a href="list.html#'+ itemData.id +'">
                            <img src="'+ imgUrl+' "/>
                            <div class="price-wrap">￥'+ itemData.price +'</div>
                          </a>
                        </li>'
        $('.preview-list').append(template)
      });
    }
  });
});
