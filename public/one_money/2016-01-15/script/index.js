function formatTime(e){var e=new Date(e),t=e.getFullYear(),i=e.getMonth()+1,o=e.getDate(),n=e.getHours(),a=e.getMinutes();return{longTime:[t,"年",i,"月",o,"日",n,"时",a,"分"].join(""),shortTime:[i,"月",o,"日",n,"时",a,"分"].join("")}}HIDE_ITEMS=!0;var beforeAjaxTime=(new Date).getTime();$.ajax({url:"/api/promotions/one_money/"+window.one_money_id+"?u="+beforeAjaxTime,dataType:"JSON",success:function(e){var t=(new Date).getTime(),i=e.td,o=(t-beforeAjaxTime)/2;i-=Math.ceil(o);var n=Date.parse(e.start_at),a=Date.parse(e.end_at),s=[formatTime(n).shortTime,"至",formatTime(a).shortTime].join("&nbsp;");$(".start-end-time").html(s);var r=(new Date).getTime(),m=r-i>a;$("a.signup").data("isEnd",m),m&&$(".introduction-bottom").attr("src","./images/sales-end.png")}}),$("a.signup").click(function(){var e=$(this).data("isEnd");return e?AlertDismiss.getAlertDismiss("活动提示","本期活动已结束"):void $.ajax({url:"/api/promotions/one_money/"+window.one_money_id+"/signup",type:"PUT",dataType:"json",success:function(e){location.href="/one_money/2016-01-15/list.html"},error:function(e){var t=e.responseJSON;if(401==e.status){var i=window.authorized_callback_url+"?status="+t.status;location.href=window.signup_url+"?callback="+encodeURIComponent(i)+"&goto_one_money=true"}}})}),HIDE_ITEMS||$.ajax({url:"/api/promotions/one_money/"+window.one_money_id+"/items",type:"GET",success:function(e){console.log(e),e.items.map(function(e){var t=JSON.parse(e.cover_urls)[0],i='<li>                          <a href="list.html#'+e.id+'">                            <img src="'+t+' "/>                            <div class="price-wrap">￥'+e.price+"</div>                          </a>                        </li>";$(".preview-list").append(i)})}});