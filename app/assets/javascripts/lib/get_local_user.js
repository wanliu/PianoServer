// 保存匿名用户信息，使得匿名用户不会每次刷新都更换
(function () {
  var ID_KEY = 'id_key';
  var CHAT_TOKEN_KEY = 'chat_token_key';

  window.setLocalUser = function (options) {
    window.localStorage.setItem(ID_KEY, options.id);
    window.localStorage.setItem(CHAT_TOKEN_KEY, options.chatToken);
  }

  window.getLocalUser = function (newAnonymousUser) {
    var id = window.localStorage.getItem(ID_KEY);
    var chatToken = window.localStorage.getItem(CHAT_TOKEN_KEY);

    if (id && chatToken) {
      return { id: id, chatToken: chatToken };
    } else {
      setLocalUser(newAnonymousUser);
      return newAnonymousUser;
    }
  }
})();

