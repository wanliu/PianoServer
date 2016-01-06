;(function() {
  this.ActionButton = (function() {
    function ActionButton(title, action, classes) {
      this.title = title;
      this.action = action;

      if (Object.prototype.toString.call(classes) === '[object Array]') {
        classes = classes.join(' ');
      }

      var class_str = [ 'btn' ];

      if (classes !== undefined) {
        class_str.push(classes);
      }

      this.classes = class_str.join(' ');
    }

    ActionButton.prototype = {
      getTitle: function() {
        return this.title;
      },

      getAction: function() {
        return this.action;
      },

      getClasses: function() {
        return this.classes;
      }
    }

    return ActionButton;
  })();
}).call(this);
