(function () {
  function UserSocket (options) {
    this.personChannelReady = false;
    this.personCallbacks = [];

    this.eventListeners = [];
    this.emiters = [];
  }

  UserSocket.prototype.getUserChannelId = function () {
    if (this.userId) {
      return 'pw' + this.userId;
    }
  }

  /*
    callback: function(message) {.....}
  */
  UserSocket.prototype.onPersonMessage = function (callback) {
    this.personCallbacks.push(callback);
  }

  UserSocket.prototype.config = function (options) {
    this.socket = options.socket;

    var user = options.user;
    this.userId = user.id;
    this.chatToken = user.chat_token;

    var _this = this;

    if (this.userId && this.chatToken) {
      this.userChannelId = this.getUserChannelId();
      this.loginAndSubscribe();
    } else {
      getLocalUser(function (err, options) {
        if (err) return;

        _this.userId = options.id;
        _this.chatToken = options.chat_token;
        _this.userChannelId = _this.getUserChannelId();

        _this.loginAndSubscribe();
      });
    }
  }

  // publish to other users
  UserSocket.prototype.publish = function (channelId, data, callback) {
    if (this.personChannelReady) {
      this.socket.publish(channelId, data, callback)
    } else {
      var error = 'socket not ready!';
      console.error(error);
      callback(error);
    }
  }

  // listen socket events
  UserSocket.prototype.on = function () {
    if (this.personChannelReady) {
      this.socket.on.apply(this.socket, arguments);
    } else {
      this.eventListeners.push(arguments);
    }
  }

  // emit socket events
  UserSocket.prototype.emit = function () {
    if (this.personChannelReady) {
      this.socket.emit.apply(this.socket, arguments);
    } else {
      this.emiters.push(arguments);
    }
  }

  UserSocket.prototype.getSocket = function () {
    return this.socket;
  }

  UserSocket.prototype.logout = function (callback) {
    callback || (callback = function () {});

    if (this.personChannelReady) {
      this.socket.emit('logout', callback);
    }
  }

  UserSocket.prototype.loginAndSubscribe = function () {
    var _this = this;
    var socket = this.socket;

    socket.emit('login', this.chatToken, function (err) {
      if (err) {
        _this.personChannelReady = false;
        return;
      }

      _this.personChannelReady = true;

      var personalChannel = socket.subscribe(_this.userChannelId);
      personalChannel.watch(function (message) {
        _this.personCallbacks.forEach(function (callback) {
          callback(message);
        })
      });

      _this.eventListeners.forEach(function (args) {
        socket.on.apply(_this.socket, args);
      })

      _this.emiters.forEach(function (args) {
        socket.emit.apply(_this.socket, args);
      })
    });
  }

  window.userSocket = new UserSocket();
})();
