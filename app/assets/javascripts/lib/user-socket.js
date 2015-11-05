(function() {
  function UserSocket(options) {
    this.personChannelReady = false;
    this.anonymous = false;
    this.personCallbacks = [];

    this.eventListeners = [];
    this.emiters = [];
  }

  UserSocket.prototype.getUserChannelId = function() {
    if (this.userId) {
      return 'p' + this.userId;
    }
  }

  /*
    callback: function(message) {.....}
  */
  UserSocket.prototype.onPersonMessage = function(callback) {
    this.personCallbacks.push(callback);
  }

  UserSocket.prototype.offPersonMessage = function(callback) {
    var callbacks = this.personCallbacks,
      index = callbacks.indexOf(callback);

    if (index > -1) {
      callbacks.splice(index, 1);
    }
  }

  UserSocket.prototype.config = function(options) {
    this.socket = options.socket;

    var user = this.user = options.user;

    this.userId = user.id;
    this.chatToken = user.chatToken;

    this.loginAndSubscribe();
  }

  UserSocket.prototype.isAnonymousUser = function(userOptions) {
    return userOptions.id && ~userOptions.id.indexOf('-');
  }

  // publish to other users
  UserSocket.prototype.publish = function(channelId, data, callback) {
    var _this = this;

    if (this.personChannelReady) {
      this.socket.publish(channelId, data, function(err) {
        if (err && 'need login' == err) {
          _this.loginAndSubscribe(function() {
            _this.socket.publish(channelId, data, callback);
          });
        } else {
          callback(err);
        }
      });
    } else {
      var error = 'socket not ready!';
      console.error(error);
      callback(error);
    }
  }

  // listen socket events
  UserSocket.prototype.on = function() {
    if (this.personChannelReady) {
      this.socket.on.apply(this.socket, arguments);
    } else {
      this.eventListeners.push(arguments);
    }
  }

  // emit socket events
  UserSocket.prototype.emit = function() {
    if (this.personChannelReady) {
      this.socket.emit.apply(this.socket, arguments);
    } else {
      this.emiters.push(arguments);
    }
  }

  UserSocket.prototype.getSocket = function() {
    return this.socket;
  }

  UserSocket.prototype.logout = function(callback) {
    callback || (callback = function() {});

    if (this.personChannelReady) {
      this.socket.emit('logout', callback);
    }
  }

  UserSocket.prototype.loginAndSubscribe = function(callback) {
    var _this = this;
    var socket = this.socket;

    callback || (callback = function() {});

    socket.emit('login', this.chatToken, function(err) {
      if (err) {
        _this.personChannelReady = false;
        console.error('login fails!');

        return;
      }

      _this.readyAndSubscribe();
      callback();
    });
  }

  UserSocket.prototype.readyAndSubscribe = function() {
    var _this = this,
      socket = this.socket;

    if (this.personChannelReady) {
      socket.subscribe(this.userChannelId);
      return;
    }

    this.userChannelId = this.getUserChannelId();
    this.personChannelReady = true;

    var personalChannel = socket.subscribe(this.userChannelId);
    personalChannel.watch(function(message) {
      _this.personCallbacks.forEach(function(callback) {
        callback(message);
      })
    });

    this.eventListeners.forEach(function(args) {
      socket.on.apply(socket, args);
    });

    this.emiters.forEach(function(args) {
      socket.emit.apply(socket, args);
    });
  }

  window.UserSocket = UserSocket;
})();
