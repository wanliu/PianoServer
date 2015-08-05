(function(win, $) {
  function NoticeCenter() {
    this.noticeMap = {};
  }

  NoticeCenter.prototype.addNotice = function(senderId, senderUsername, chatId) {
    var noticeContainer = $('.chat-notices'),
        noticeMap = this.noticeMap,
        noticeObj = this._findNoticeObj(senderId),
        notice;

     if (noticeObj) {
        noticeObj['unreadCount'] += 1;
        notice = noticeObj['notice'];

        notice.updateUnreadCount(noticeObj['unreadCount']);
     } else {
        notice = new Notice({
          'senderId': senderId,
          'container': this,
          'chatId': chatId,
          'containment': noticeContainer,
          'senderUsername': senderUsername
        });

        noticeObj = {
          'unreadCount': 1,
          'notice': notice
        };

        noticeMap[senderId] = noticeObj;
     }
   };

  NoticeCenter.prototype.removeNotice = function(senderId, chatId, redirect) {
    var noticeObj = this._findNoticeObj(senderId);

    if (noticeObj) {
      delete this.noticeMap[senderId];

      noticeObj['notice'].destroy();
      noticeObj = null;
    }

    if (redirect) {
      window.location.href = '/chats/' + chatId;
    }
  };

  NoticeCenter.prototype._findNoticeObj = function(senderId) {
    return this.noticeMap[senderId];
  };

  function Notice(options) {
    options = options || {};

    if (!options.senderId || (!options.orderId && !options.chatId) || !options.containment || !options.senderUsername || !options.container) {
      return;
    }

    this.options = options;
    this.init();
  }

  Notice.prototype.init = function() {
    var options = this.options,
        container = options.container,
        containment = options.containment,
        senderId = options.senderId,
        senderUsername = options.senderUsername,
        chatId = options.chatId;

    this.element = $('<div class="chat-notice"><span class="show-notice">您有<span class="unreadCount">1</span>条来自' +
      senderUsername +'的未读聊天消息</span><span class="ignore">忽略</span></div>')
      .appendTo(containment);

    this.element.find('.show-notice').click(function() {
      container.removeNotice(senderId, chatId, true);
    }).end().find('.ignore').click(function() {
      container.removeNotice(senderId, chatId, false);
    });
  }

  Notice.prototype.destroy = function() {
    this.element.remove();
  }

  Notice.prototype.updateUnreadCount = function(unreadCount) {
    this.element.find('.unreadCount').text(unreadCount);
  };

  window.noticeCenter = new NoticeCenter();
})(window, jQuery);
