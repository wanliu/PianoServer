var globalCountDownManager;

function CountDownManager(startOnInit) {
  this.callbacks = [];

  if (startOnInit === undefined) startOnInit = true;

  if (startOnInit) this.start();
}

CountDownManager.getManager = function() {
  if (!globalCountDownManager) {
    globalCountDownManager = new CountDownManager();
  }

  return globalCountDownManager;
};

CountDownManager.prototype.start = function() {
  if(this.started) {
    return;
  }

  this.started = true;

  var callbacks = this.callbacks;

  this.intervelId = setInterval(function() {
    for(var i=0; i < callbacks.length; i++) {
      var item = callbacks[i];
      var callback = item['callback'];
      var context = item['context'];

      if (typeof callback === 'function') {
        callback.call(context ? context : window);
      }
    }
  }, 1000);
};

CountDownManager.prototype.addHandler = function(callback, context) {
  if (!this.isExisted(callback, context)) {
    this.callbacks.push({
      callback: callback,
      context: context
    });
  }
};

CountDownManager.prototype.isExisted = function(callback, context) {
  for (var i=0; i<this.callbacks.length; i++) {
    var item = this.callbacks[i];

    if (item['callback'] === callback && item['context'] === context) {
      return true;
    }
  }

  return false;
};

CountDownManager.prototype.removeHandler = function(callback, context) {
  var toRemoveIndex = -1;

  for (var i=0; i<this.callbacks.length; i++) {
    var item = this.callbacks[i];

    if (item['callback'] === callback && item['context'] === context) {
      toRemoveIndex = i;
    }
  }

  if (toRemoveIndex > -1) {
    this.callbacks.splice(toRemoveIndex, 1);
  }
};

CountDownManager.prototype.destroy = function() {
  clearInterval(this.intervelId);
  this.intervelId = null;

  this.callbacks.length = 0;
  globalCountDownManager = null;
};


