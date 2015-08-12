(function(win, $) {
  function NoticeCenter() {
    this.notices = [];
  }

  NoticeCenter.prototype.addNotice = function(senderId, senderLogin, unreadCount) {
    var noticeContainer = $('.chat-notices'),
        senderId = senderId.toString(),
        notice = this._findNotice(senderId);

    if (typeof unreadCount === 'undefined') {
      unreadCount = 1;
    }

    if (notice) {
      notice.increceUnreadCount(unreadCount);
    } else {
      notice = new Notice({
        'container': this,
        'senderId': senderId,
        'unreadCount': unreadCount,
        'containment': noticeContainer,
        'senderLogin': senderLogin
      });
    }
  };

  NoticeCenter.prototype.removeNotice = function(senderId, redirect) {
    var notice = this._findNotice(senderId.toString());

    if (notice) {
      notice.destroy();

      var index = this.notices.indexOf(notice),
          chatId = notice.options.chatId;

      if (index > -1) {
        this.notices.splice(notice, 1);
      }

      if (redirect) {
        userSocket.emit('readChannel', {
          channelId: 'p' + senderId
        }, function(err) {
          if (err) {
            return console.error(err);
          }

          Turbolinks.visit('/chats/' + chatId);
        });
      }
    }
  };

  NoticeCenter.prototype._findNotice = function(senderId) {
    var notices = this.notices;

    if (notices.length === 0) {
      return null;
    }

    for (var i=0; i<notices.length; i++) {
      var notice = notices[i];

      if (notice.options.senderId === senderId) {
        return notice;
      }
    }

    return null;
  }

  function Notice(opts) {
    opts = opts || {};

    if (!opts.senderId || !opts.containment || !opts.container || !opts.senderLogin) {
      return null;
    }

    this.options = opts;
    this._init();
  }

  Notice.prototype._init = function() {
    var _this = this,
        options = this.options,
        senderId = options.senderId,
        channelId = 'p' + senderId;

    userSocket.emit('get', {
      channelId: channelId,
      key: 'chat_id'
    }, function(err, chatId) {
      if (!err && chatId) {
        _this.options.chatId = chatId;

        _this._createElementAndHandler();
      }
    });
  }

  Notice.prototype._createElementAndHandler = function() {
    var options = this.options,
        senderId = options.senderId,
        container = options.container,
        senderLogin = options.senderLogin,
        containment = options.containment,
        unreadCount = options.unreadCount;

    if (+senderId < 0) {
      senderLogin += Math.abs(senderId);
    }

    this.element = $('<div class="chat-notice"><span class="show-notice">您有<span class="unreadCount">' + unreadCount +'</span>条来自' +
      senderLogin +'的未读聊天消息</span><span class="ignore">忽略</span></div>')
      .appendTo(containment);

    this.element.find('.show-notice').click(function() {
      container.removeNotice(senderId, true);
    }).end().find('.ignore').click(function() {
      container.removeNotice(senderId, false);
    });

    container.notices.push(this);
  }

  Notice.prototype._updateUnreadCount = function() {
    var unreadCount = this.options.unreadCount;

    this.element.find('.unreadCount').text(unreadCount);
  };

  Notice.prototype.increceUnreadCount = function(count) {
    this.options.unreadCount += +count;
    this._updateUnreadCount();
  }

  Notice.prototype.decreseUnreadCount = function(count) {
    this.options.unreadCount -= +count;
    this._updateUnreadCount();
  }

  Notice.prototype.destroy = function() {
    this.element.remove();
  }

  window.noticeCenter = new NoticeCenter();
})(window, jQuery);
