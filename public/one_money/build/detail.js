function getQueryParams(){var t,e=location.search,a=location.href;t=e?e.slice(1):a.split("?")[1];for(var n={},i=t.split("&"),s=0;s<i.length;s++){var r=i[s].split("="),o=r[0],c=r[1];n[o]=c}return n}function parseResponseData(t){var e=["avatar_urls","cover_urls","image_urls"],a=["start_at","end_at"],n=["created_at","updated_at"];for(var i in t)e.indexOf(i)>-1&&(t[i]=JSON.parse(t[i])),a.indexOf(i)>-1&&(t[i]=Date.parse(t[i])),n.indexOf(i)>-1&&(t[i]*=1e3)}function formatZero(t){return 10>+t?"0"+t:t}function formatDate(t){var e=new Date(t),a=e.getFullYear(),n=e.getMonth()+1,i=e.getDate();e.getHours(),e.getMinutes();return[[a,formatZero(n),formatZero(i)].join("-")].join(" ")}var params=getQueryParams(),one_money_id=params.one_money_id,item_id=params.id,url=["/api/promotions/one_money/",one_money_id,"/items/",item_id].join(""),beforeAjaxTime=(new Date).getTime(),$action=$(".actions");$.ajax({type:"GET",dataType:"json",url:url,data:{u:beforeAjaxTime},success:function(t){var e=(new Date).getTime(),a=t.td,n=(e-beforeAjaxTime)/2;a-=Math.ceil(n),parseResponseData(t);var i=t.image_urls[0],s=t.ori_price,r=t.title,o=t.shop_name,c=t.start_at,l=t.end_at,u=t.total_amount||0,o=t.shop_name,d=t.shop_avatar_url,m=t.status||"wait",p=t.item_status||null,v=$(".countdown-text");if(new CountDown(v,+u,c+a,l+a,function(t){if("always"!==p&&"no-executies"!==p)switch(t){case"started":return $action.html('<button class="purchase-btn">马上抢购</button>');case"end":return $action.html('<div class="end-text">活动已结束</div>')}}),setTimeout(function(){v.parent().show()},1500),$(".ori_price").text(s),$("img.poster").attr("src",i),$(".item-title").text(r),$(".total-amount .inventory").text(u),$(".start-end .time-desc").text(["活动时间",formatDate(c),"至",formatDate(l)].join(" ")),$(".supplier-desc .avatar").attr("src",d),$(".supplier-name").text(o),"wait"===m)return $action.html('<div class="wait-text">请耐心等待</div>');if("end"===m)return $action.html('<div class="end-text">活动已结束</div>');if("always"==p)return url=["/api/promotions/one_money/",one_money_id,"/callback/",item_id].join(""),void $.ajax({type:"GET",dataType:"json",url:url,success:function(t){var e=t.grabs;if(e.length>0){var a=e[0],n=a.status,i=a.callback_url;"pending"===n?$action.html(['<a style="text-decoration:none;" href="',i,'"><div class="always-text">领取奖励</div></a>'].join("")):"created"===n&&$action.html('<div class="always-text">已领取奖品</div>')}else $action.html('<div class="always-text">没有抢购机会了</div>')}});if("no-executies"==p)return $action.html('<div class="always-text">已经不能再抢此商品了</div>');switch(m){case"wait":return $action.html('<div class="wait-text">请耐心等待</div>');case"started":return $action.html('<button class="purchase-btn">马上抢购</button>');case"end":return $action.html('<div class="end-text">活动已结束</div>');case"suspend":return $action.html('<div class="end-text">已售罄</div>');default:return $action.html('<div class="wait-text">请耐心等待</div>')}}}),$action.on("click",".purchase-btn",function(t){t.stopPropagation(),$.ajax({url:"/api/promotions/one_money/"+one_money_id+"/grab/"+item_id,type:"PUT",dataType:"json",success:function(t){"success"==t.status&&($(".actions").html('<div class="always-text">已经参与过活动了 </div>'),AlertDismiss.getAlertDismiss("抢购提示","恭喜您抢购成功！",{buttons:[new ActionButton("领取奖励",t.callback_url,"btn-success")]}))},error:function(t,e,a){var n=t.responseJSON;401==n.status&&$(".error-pannel").fadeIn(300)}})});