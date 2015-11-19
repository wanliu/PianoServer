(function (win) {
  var DATE_UNIT = {
    YEAR: 365 * 24 * 60 * 60 * 1000,
    MONTH: 30 * 24 * 60 * 60 * 1000,
    DAY: 24 * 60 * 60 * 1000,
    HOUR: 60 * 60 * 1000,
    MINUTE: 60 * 1000,
    SECOND: 1000
  };

  function time_ago (time) {
    now = new Date().getTime()

    diff = Math.abs(time - now);

    if (diff > DATE_UNIT.YEAR) {
      return Math.floor(diff / DATE_UNIT.YEAR) + '年前';
    }

    if (diff > DATE_UNIT.MONTH) {
      return Math.floor(diff / DATE_UNIT.MONTH) + '月前';
    }

    if (diff > DATE_UNIT.DAY) {
      return Math.floor(diff / DATE_UNIT.DAY) + '天前';
    }

    if (diff > DATE_UNIT.HOUR) {
      return Math.floor(diff / DATE_UNIT.HOUR) + '小时前';
    }

    if (diff > DATE_UNIT.MINUTE) {
      return Math.floor(diff / DATE_UNIT.MINUTE) + '分钟前';
    }

    if (diff > DATE_UNIT.SECOND) {
      return Math.floor(diff / DATE_UNIT.SECOND) + '秒前';
    }

    return '刚刚';
  }

  win.fromNow = function (time) {
    if (time) {
      typeStr = Object.prototype.toString.call(time);

      switch (typeStr) {
        case '[object String]':
          time = Date.parse(time);
          break;
        case '[object Date]':
          time = time.getTime();
          break;
        case '[object Number]':
          break;
        default:
          time = new Date.getTime();
          break;
      }
    } else {
      time = new Date().getTime()
    }

    return time_ago(time);
  }
})(window);





