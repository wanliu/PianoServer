function PromotionItem(t){var s=["avatar_urls","cover_urls","image_urls"],a=["start_at","end_at"];for(var e in t){var n=t[e];s.indexOf(e)>-1&&(n=JSON.parse(n)),a.indexOf(e)>-1&&(n=Date.parse(n)),this[e]=n}this.render(),this.countDownTime()}$(function(){$.ajax({url:"/api/promotions/one_money/1/items",success:function(t){console.log(t),t.map(function(t){new PromotionItem(t)})},error:function(t){$("body").append(t.responseText)}})}),PromotionItem.prototype={getStatus:function(){var t=(new Date).getTime();return"timing"!=this.status?this.status:this.total_amount<1?"shortage":t<this.start_at?"wait":t>this.end_at?"expired":"wait"},changeStatus:function(t){$(".promotion-item[name="+this.id+"] .status-wrap").html(this.statusFlagTemplate(t))},countDownTime:function(){function t(){var n=(new Date).getTime();return n>a.end_at&&"end"!=s?(s="end",e.removeHandler(t),a.changeStatus("end")):n>a.start_at&&"started"!=s?(s="started",a.changeStatus("started")):void 0}var s=this.getStatus();if("end"!=s&&"shortage"!=s){var a=this,e=CountDownManager.getManager();e.addHandler(t)}},statusFlagTemplate:function(t){var t=t||this.getStatus();switch(t){case"wait":return'<span class="status wait">未开始</span>&emsp;参与人数:'+this.total_amount;case"end":return'<span class="status end">已结束</span>&emsp;参与人数:'+this.total_amount;case"shortage":return'<span class="status end">已售罄</span>&emsp;参与人数:'+this.total_amount;case"started":return'<span class="status">抢购中</span>&emsp;库存:'+this.total_amount}},template:function(){return'      <li class="promotion-item" name='+this.id+'>        <a class="item-wrap" href="detail.html?one_money_id='+this.one_money_id+"&id="+this.id+'">          <header>            <img class="one-money-logo" src="images/one_money_log.jpg"/>            <img class="cover" src="'+this.cover_urls[0]+'">            <div class="limit">            </div>          </header>          <main>            <p class="title">'+this.title+'</p>            <div class="price-wrap">              <span class="now-price">￥'+this.price+'</span>              <span class="origin-price">原价<s>￥'+this.ori_price+'&nbsp;</s></span>            </div>            <div class="status-wrap">'+this.statusFlagTemplate()+"</div>          </main>        </a>      </li>"},render:function(t){var t=t||$(".promotions-list");t.append(this.template())}};