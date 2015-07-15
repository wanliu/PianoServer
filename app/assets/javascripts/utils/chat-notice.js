(function(win, $) {
  function NoticeCenter() {
    this.noticeMap = {};
  }

  NoticeCenter.prototype.addNotice = function(senderId, senderUsername, promotionId) {
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
          'promotionId': promotionId,
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

  NoticeCenter.prototype.removeNotice = function(senderId, promotionId) {
    var noticeObj = this._findNoticeObj(senderId);

    if (noticeObj) {
      delete this.noticeMap[senderId];

      noticeObj['notice'].destroy();
      noticeObj = null;
    }

    window.location.href = '/promotions/' + promotionId + '/chat';
  };

  NoticeCenter.prototype._findNoticeObj = function(senderId) {
    return this.noticeMap[senderId];
  };

  function Notice(options) {
    options = options || {};

    if (!options.senderId || !options.promotionId || !options.containment || !options.senderUsername || !options.container) {
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
        promotionId = options.promotionId;
        
    this.element = $('<div class="chat-notice">您有<span class="unreadCount">1</span>条来自'+ senderUsername +'的未读聊天消息</div>')
      .click(function() {
        container.removeNotice(senderId, promotionId);
      })
      .appendTo(containment);
  }

  Notice.prototype.destroy = function() {
    this.element.remove();
  }

  Notice.prototype.updateUnreadCount = function(unreadCount) {
    this.element.find('.unreadCount').text(unreadCount);
  };

  window.noticeCenter = new NoticeCenter();
})(window, jQuery);
