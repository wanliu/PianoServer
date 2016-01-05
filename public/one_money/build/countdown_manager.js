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
      var callback = callbacks[i];

      if (typeof callback === 'function') {
        callback();
      }
    }
  }, 1000);
};

CountDownManager.prototype.addHandler = function(callback) {
  if (!this.isExisted(callback)) {
    this.callbacks.push(callback);
  }
};

CountDownManager.prototype.isExisted = function(callback) {
  return this.callbacks.indexOf(callback) > -1;
};

CountDownManager.prototype.removeHandler = function(callback) {
  var index = this.callbacks.indexOf(callback);

  if (index > -1) {
    this.callbacks.splice(index, 1);
  }
};

CountDownManager.prototype.destroy = function() {
  clearInterval(this.intervelId);
  this.intervelId = null;

  this.callbacks.length = 0;
  globalCountDownManager = null;
};


