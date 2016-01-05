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
  this.render();
  this.countDownTime();
}

PromotionItem.prototype = {
  getStatus: function() {
    var now = new Date().getTime();
    if (this.status != "timing") return this.status;
    if (this.total_amount < 1)   return 'shortage';
    if (now < this.start_at )    return 'wait';
    if (now > this.end_at)       return 'expired';
    return 'wait';
  },
  changeStatus: function(status) {
    $('.promotion-item[name='+this.id+'] .status-wrap').html(this.statusFlagTemplate(status));
  },
  countDownTime: function() {
    var status = this.getStatus();
    if (status == 'end' || status == 'shortage') return;

    var _this = this;
    var timeManager = CountDownManager.getManager();
    timeManager.addHandler(handler); // 添加定时器

    function handler() {
      var now = new Date().getTime();
      if (now > _this.end_at && status != 'end'){
        status = 'end';
        timeManager.removeHandler(handler); // 移除定时器
        return _this.changeStatus('end');
      }
      if (now > _this.start_at && status != 'started') {
        status = 'started';
        return _this.changeStatus('started');
      }
    }
  },
  statusFlagTemplate: function(status) {
    var status = status || this.getStatus();
    switch (status) {
      case 'wait':
        return '<span class="status wait">未开始</span>&emsp;参与人数:' + this.total_amount;

      case 'end':
        return '<span class="status end">已结束</span>&emsp;参与人数:' + this.total_amount;

      case 'shortage':
        return '<span class="status end">已售罄</span>&emsp;参与人数:' + this.total_amount;

      case 'started':
        return '<span class="status">抢购中</span>&emsp;库存:' + this.total_amount;
    } 
  },
  template: function() {
    return '\
      <li class="promotion-item" name='+ this.id +'>\
        <a class="item-wrap" href="detail.html?one_money_id='+ this.one_money_id+'&id='+ this.id +'">\
          <header>\
            <img class="one-money-logo" src="images/one_money_log.jpg"/>\
            <img class="cover" src="'+ this.cover_urls[0] +'">\
            <div class="limit">\
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