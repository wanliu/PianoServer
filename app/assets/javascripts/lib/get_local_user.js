var ID_KEY = 'id_key';
var CHAT_TOKEN_KEY = 'chat_token_key';

function getLocalUser(callback) {
  var id = window.localStorage.getItem(ID_KEY);
  var chat_token = window.localStorage.getItem(CHAT_TOKEN_KEY);

  if (id && chat_token) {
    callback(null, { id: id, chat_token: chat_token });
  } else {
    $.getJSON('/users/anonymous.json')
      .done(function (data, status, xhr) {
        setLocalUser(data);
        callback(null, data);
      })
      .fail(function (xhr, status, error) {
        var err = status + ", " + error;
        callback(err, {});
      })
  }
}

function setLocalUser(options) {
  window.localStorage.setItem(ID_KEY, options.id);
  window.localStorage.setItem(CHAT_TOKEN_KEY, options.chat_token);
}
