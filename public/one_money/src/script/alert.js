;(function() {
  this.Alert = (function() {
    var globalAlert;

    Alert.newAlert = function(title, msg, opt) {
      if (globalAlert) {
        globalAlert.destroy();
      }

      globalAlert = new Alert(title, msg, opt);
    };

    function Alert(title, msg, opt) {
      opt = opt || {};

      this.title = title || '消息';
      this.msg   = msg   || '';
      this.link  = opt.link  || '#';
      this.buttons = opt.buttons || [];

      this.style = {
        container: {
          'border-color': '#f10043',
          'background': '#fff'
        },

        panel: {
          'background': '#fff'
        },

        header: {
          'color': '#f10044'
        },

        close: {
          'background': '#999'
        }
      }
    }

    Alert.prototype = {
      styleFormat: function(attr_name) {
        var style = "";
        var obj = this['style'][attr_name];

        for (var key in obj) {
          style += [key, ':', obj[key], ';'].join('')
        }

        return style;
      },
      template: function() {
        return [
          '<div class="alert-container" style="', this.styleFormat('container'), '">',
            '<div class="panel" style="', this.styleFormat['panel'], '">',
              '<div class="alert-close-btn" style="', this.styleFormat('close'), '">×</div>',
              '<div class="alert-header" style="', this.styleFormat('header'), '">', this.title, '</div>',
              '<p class="alert-msg">', this.msg, '</p>',
              this.generateButtons(),
            '</div>',
          '</div>'
        ].join('');
      },
      generateButtons: function() {
        var buttons = this.buttons;

        var buttons_ary = [];

        for (var i=0; i<buttons.length; i++) {
          var button = buttons[i];
          var title = button.getTitle();
          var action = button.getAction();
          var classes = button.getClasses();

          buttons_ary.push(['<button class="', classes, '" action="', action, '">', title,'</button>'].join(''));
        }

        if (buttons_ary.length > 0) {
          return ['<div class="action-buttons">', buttons_ary.join(''),'</div>'].join('');
        }

        return '';
      },

      bindActionButtonEvents: function() {
        if (this.buttons.length === 0) return;

        this.element.find('.btn').click(function(e) {
          e.preventDefault();

          var action = $(this).attr('action');

          if (action !== '#') {
            window.location.href = action;
          }
        });
      },

      bindCloseEvent: function() {
        var _this = this;

        $('.alert-close-btn').on('click', function() {
          _this.destroy();
        });
      },

      show: function() {
        this.element.fadeIn();
      },

      hide: function() {
        this.element.fadeOut();
      },

      destroy: function() {
        this.element.remove();

        globalAlert = null;
      },

      render: function() {
        var _this = this;

        this.element = $(this.template()).appendTo($('body'));

        this.bindCloseEvent();
        this.bindActionButtonEvents();
        this.show();
      }
    }

    return Alert;
  });
}).call(this);
