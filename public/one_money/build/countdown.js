

(function() {
  if (!Function.prototype.bind) {
    Function.prototype.bind = function(oThis) {
      if (typeof this !== 'function') {
        // closest thing possible to the ECMAScript 5
        // internal IsCallable function
        throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable');
      }

      var aArgs   = Array.prototype.slice.call(arguments, 1),
          fToBind = this,
          fNOP    = function() {},
          fBound  = function() {
            return fToBind.apply(this instanceof fNOP
                   ? this
                   : oThis,
                   aArgs.concat(Array.prototype.slice.call(arguments)));
          };

      if (this.prototype) {
        // native functions don't have a prototype
        fNOP.prototype = this.prototype;
      }
      fBound.prototype = new fNOP();

      return fBound;
    };
  }

  this.CountDown = (function() {
    CountDown.DATE_UNIT = {
      DAY: 24 * 60 * 60 * 1000,
      HOUR: 60 * 60 * 1000,
      MINUTE: 60 * 1000,
      SECOND: 1000
    };

    function CountDown(element, inventory, startTime, endTime) {
      this.element = element;
      this.inventory = inventory;
      this.startTime = startTime;
      this.endTime = endTime;

      if (+inventory > 0) {
        this._addCountdownHandler();
      }
    }

    CountDown.prototype.$ = function() {
      return $(this.element);
    };

    CountDown.prototype._applyClass = function(toAddClass) {
      return this.$().parent().removeClass('not-started started finished').addClass(toAddClass);
    };

    CountDown.prototype._addCountdownHandler = function() {
      var intervalHandler = this._countdownHandler.bind(this);

      return this._intervalMark = setInterval(intervalHandler, 1000);
    };

    CountDown.prototype._removeCountdownHander = function() {
      if (this._intervalMark) {
        clearInterval(this._intervalMark);
        return this._intervalMark = null;
      }
    };

    CountDown.prototype._diff = function(date1, date2) {
      return date2 - date1;
    };

    CountDown.prototype.duration = function(date1, date2) {
      var days, duration, hours, minutes, seconds, sub;
      duration = this._diff(date1, date2);
      days = Math.floor(duration / CountDown.DATE_UNIT.DAY);
      sub = duration - days * CountDown.DATE_UNIT.DAY;
      hours = Math.floor(sub / CountDown.DATE_UNIT.HOUR);
      sub -= hours * CountDown.DATE_UNIT.HOUR;
      minutes = Math.floor(sub / CountDown.DATE_UNIT.MINUTE);
      sub -= minutes * CountDown.DATE_UNIT.MINUTE;
      seconds = Math.floor(sub / CountDown.DATE_UNIT.SECOND);
      return {
        'days': days,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'times': duration
      };
    };

    CountDown.prototype._countdownHandler = function() {
      var diffEnd, diffStart, duration, isEnd, isStarted, now, prefix;
      now = new Date();
      diffStart = this._diff(this.startTime, now);
      diffEnd = this._diff(now, this.endTime);
      isStarted = diffStart > 0;
      isEnd = diffEnd < 0;
      prefix = null;
      duration = null;

      if (diffStart === 0 || diffEnd === 0) {
        this._changeClass();
      }

      if (isEnd) {
        if (this.status && this.status != 'Finish') this.statusChanged('Finish').bind(this);
        this.status = 'Finish';
        this._showFinishText();
        return this._removeCountdownHander();
      }

      if (isStarted) {
        if (this.status && this.status != 'Start') this.statusChanged('Start').bind(this);
        this.status = 'Start';

        prefix = '距活动结束还有';
        duration = this.duration(now, this.endTime);
        return this._updateCountdownText(prefix, duration);
      } else {
        prefix = '距活动开始还有';
        duration = this.duration(now, this.startTime);

        if (duration.times > 5 * CountDown.DATE_UNIT.MINUTE) {
          return this._showStartText();
        } else {
          return this._updateCountdownText(prefix, duration);
        }
      }
    };

    CountDown.prototype.statusChanged = function(status) {

    }

    CountDown.prototype._updateCountdownText = function(prefix, duration) {
      var text = this._formatShortTime(duration);

      return this.$().text(prefix + text);
    };

    CountDown.prototype._showStartText = function() {
      if (this._hasShown) {
        return;
      }

      this._hasShown = true;
      this.$().text('活动开始时间: ' + this._formatFullyTime(this.startTime));

      return this._applyClass('not-started');
    };

    CountDown.prototype._showFinishText = function() {
      this.$().text('活动已结束');

      return this._applyClass('finished');
    };

    CountDown.prototype._showInventoryText = function() {
      this.$().text('库存剩余' + this.inventory + '件');

      return this._applyClass('started');
    };

    CountDown.prototype._formatFullyTime = function(date) {
      var days, hours, minutes, months, years;
      date = new Date(date);
      years = date.getFullYear();
      months = this._formatValue(date.getMonth() + 1);
      days = this._formatValue(date.getDate());
      hours = this._formatValue(date.getHours());
      minutes = this._formatValue(date.getMinutes());

      return [[years, months, days].join('/'), [hours, minutes].join(':')].join(' ');
    };

    CountDown.prototype._formatShortTime = function(duration) {
      var days, hours, minutes, seconds;
      days = this._format(duration, 'days');
      hours = this._format(duration, 'hours');
      minutes = this._format(duration, 'minutes');
      seconds = this._format(duration, 'seconds');

      return [days, '天', [hours, minutes, seconds].join(':')].join('');
    };

    CountDown.prototype._format = function(duration, key) {
      var value;
      value = duration[key];

      return this._formatValue(value);
    };

    CountDown.prototype._formatValue = function(value) {
      if (value < 10) {
        return '0' + value;
      } else {
        return value;
      }
    };

    return CountDown;
  })();

}).call(this);
