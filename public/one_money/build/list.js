function PromotionItem(t){this.init(t),this.render(),this.countDownTime()}$(function(){$.ajax({url:"/api/promotions/one_money/2/items",data:{},success:function(t){console.log(t),t.map(function(t){new PromotionItem(t)})}})}),PromotionItem.prototype={init:function(t){var n=["avatar_urls","cover_urls","image_urls"],a=["start_at","end_at"];for(var s in t){var i=t[s];n.indexOf(s)>-1&&(i=JSON.parse(i)),a.indexOf(s)>-1&&(i=Date.parse(i)),this[s]=i}},state:function(){return Date.now()<this.start_at?"wait":Date.now()>this.end_at?"expired":this.total_amount<1?"shortage":"sale"},countDownTime:function(){var t=$(".count-time[data-id="+this.id+"]");new CountDown(t,+this.total_amount,this.start_at,this.end_at)},renderStateFlag:function(){switch(this.state()){case"wait":return'<span class="state end">未开始</span>';case"expired":return'<span class="state end">已结束</span>';case"shortage":return'<span class="state end">已售罄</span>';default:return'<span class="state">进行中</span>'}},template:function(){return'<li>\n              <a class="item-wrap" href="detail.html?one_money_id='+this.one_money_id+"&id="+this.id+'" data-id="'+this.id+'">                <header>\n                  '+this.renderStateFlag()+'\n                  <img src="'+this.cover_urls[0]+'">\n                  <div class="limit">\n                    <span>活动数量: '+this.total_amount+' 件</span><br />\n                    <span class="count-time" data-id='+this.id+'></span>\n                  </div>\n                </header>\n                <main>\n                  <p class="title">'+this.title+'</p>\n                  <hr>\n                  <div class="price-wrap">\n                    <span class="now-price">￥'+this.price+'</span>\n                    &emsp;<s class="origin-price">￥'+this.ori_price+"</s>\n                  </div>\n                </main>\n              </a>\n            </li>"},render:function(t){var t=t||$(".promotions-list");t.append(this.template())}};