$(function() {
  $.ajax({
    url:'/api/promotions/one_money/1/items',
    success: function(itemsData) {
      console.log(itemsData);
      itemsData.map(function(itemData) {
        new PromotionItem(itemData);
      });
    },
    error: function (err){
      $('body').append(err.responseText);
    }
  });
});

function PromotionItem(itemData) {
  this.init(itemData);
  this.render();
  this.countDownTime();
}

PromotionItem.prototype = {
  init: function(itemData) {
    var shouldJSONParseArr = ['avatar_urls', 'cover_urls', 'image_urls'];
    var shouldDateParseArr = ['start_at', 'end_at'];
    for (var key in itemData) {
      var data = itemData[key];
      if (shouldJSONParseArr.indexOf(key) > -1) {
        data = JSON.parse(data);
      }
      if (shouldDateParseArr.indexOf(key) > -1) {
        data = Date.parse(data);
      }
      this[key] = data;
    }
  },

  getStatus: function() {
    if (this.status) return this.status;
    if (Date.now() < this.start_at ) return 'wait';
    if (Date.now() > this.end_at) return 'expired';
    if (this.total_amount < 1) return 'shortage';
    return 'sale';
  },

  countDownTime: function() {
    var element = $('.promotion-item[name='+ this.id +'] .count-time');
    new CountDown(element, +this.total_amount, this.start_at, this.end_at);
  },

  changeStatus: function() {

  },

  statusFlagTemplate: function() {
    switch (this.getStatus()) {
      case 'wait':
        return '<span class="status wait">未开始</span>&emsp;参与人数:' + this.total_amount;

      case 'expired':
        return '<span class="status end">已结束</span>&emsp;参与人数:' + this.total_amount;

      case 'shortage':
        return '<span class="status end">已售罄</span>&emsp;参与人数:' + this.total_amount;

      default:
        return '<span class="status">抢购中</span>&emsp;库存:' + this.total_amount;
    } 
  },
  template: function() {
    return '<li class="promotion-item" name='+ this.id +'>\
              <a class="item-wrap" href="detail.html?one_money_id='+ this.one_money_id+'&id='+ this.id +'">\
                <header>\
                  <img class="one-money-logo" src="images/one_money_log.jpg"/>\
                  <img class="cover" src="'+ this.cover_urls[0] +'">\
                  <div class="limit">\
                    <span class="count-time"></span>\
                  </div>\
                </header>\
                <main>\
                  <p class="title">'+ this.title +'</p>\
                  <div class="price-wrap">\
                    <span class="now-price">￥'+ this.price +'</span>\
                    <span class="origin-price">原价<s>￥'+ this.ori_price +'&nbsp;</s></span>\
                  </div>\
                  <div class="status-wrap">'+ this.statusFlagTemplate() +'</div>\
                </main>\
              </a>\
            </li>';
  },
  render: function(target) {
    var target = target || $('.promotions-list');
    target.append(this.template());
  }
}