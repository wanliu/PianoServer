function UserSocket (options) {
  this.socket = options.socket;

  var user = options.user;
  this.userId = user.id;
  this.chatToken = user.chat_token;

  this.personChannelReady = false;
  this.personCallbacks = [];

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

UserSocket.prototype.getUserChannelId = function () {
  if (this.userId) {
    return 'p' + this.userId;
  }
}

UserSocket.prototype.onPersonMessage = function (callback) {
  this.personCallbacks.push(callback);
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
  });
}


// function bindUserToSocket(user, socket) {
//   var userId = user.id;
//   var chatToken = user.chat_token;
//   var channelId;

//   if (userId && chatToken) {
//     channelId = personChannelId(userId);

//     socket.emit('login', chatToken, loginListener);
//   } else {
//     getLocalUser(function (err, options) {
//       if (err) return;

//       userId = options.id;
//       chatToken = options.chat_token;
//       channelId = personChannelId(userId);

//       socket.emit('login', chatToken, loginListener);
//     });
//   }

//   function loginListener(err) {
//     if (err) return console.log('login fails', err);

//     var personalChannel = socket.subscribe(channelId);
//     personalChannel.watch(function (message) {
//       console.log('Message:', message);
//     });
//   }
// }

// function personChannelId (userId) {
//   return 'p' + userId;
// }