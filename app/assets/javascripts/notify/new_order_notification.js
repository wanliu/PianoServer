function new_order_notification (message) {
  if (!message.content.order_id || !message.content.order_url) {
    return;
  }

  show_order_notification(message);
}

function show_order_notification (message) {
  var $container = $('.chat-notices');
  var $node = $('\
    <div class="chat-notice">\
      <a href="' + message.content.order_url + '" style="color: white;">\
        <span class="show-notice">你的商店有新的订单，点击查看</span>\
      </a>\
      <span class="ignore">忽略</span>\
    </div>')

  $node.on('click', '.ignore', function(e) {
    $node.remove();
  })

  $container.append($node)
  return $node;
}

$(function() {
  userSocket.onNotifyMessage(new_order_notification);
});