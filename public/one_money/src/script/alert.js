;(function() {
  this.AlertDismiss = (function() {
    var globalAlertDismiss;

    function AlertDismiss(title, msg, opt) {
      opt = opt || {};

      this.title = title || '消息';
      this.msg   = msg   || '';
      this.link  = opt.link  || '#';
      this.buttons = opt.buttons || [];

      this.style = {
        container: {

        },

        panel: {
          'border-color': '#f10043',
          'background': '#fff'
        },


        title: {
        },

        close: {
        }
      }

      this.render();
    }

    AlertDismiss.prototype.styleFormat = function(attr_name) {
      var style = "";
      var obj = this['style'][attr_name];

      for (var key in obj) {
        style += [key, ':', obj[key], ';'].join('')
      }

      return style;
    };


    AlertDismiss.prototype.template = function() {
      return [
        '<div class="alert-container" style="', this.styleFormat('container'), '">',
          '<div class="panel-wrap">',
            '<div class="panel" style="', this.styleFormat['panel'], '">',
              '<div class="alert-close-btn" style="', this.styleFormat('close'), '">×</div>',
              '<div class="alert-title" style="', this.styleFormat('title'), '">', this.title, '</div>',
              '<p class="alert-msg">', this.msg, '</p>',
              this.generateButtons(),
            '</div>',
          '</div>',
        '</div>'
      ].join('');
    };

    AlertDismiss.prototype.generateButtons = function() {
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
    };

    AlertDismiss.prototype.bindActionButtonEvents = function() {
      if (this.buttons.length === 0) return;

      this.element.find('.btn').click(function(e) {
        e.preventDefault();

        var action = $(this).attr('action');

        if (action !== '#') {
          window.location.href = action;
        }
      });
    };

    AlertDismiss.prototype.bindCloseEvent = function() {
      var _this = this;

      $('.alert-close-btn').on('click', function() {
        _this.destroy();
      });
    };

    AlertDismiss.prototype.show = function() {
      this.element.fadeIn();
    };

    AlertDismiss.prototype.hide = function() {
      this.element.fadeOut();
    };

    AlertDismiss.prototype.destroy = function() {
      this.element.remove();

      globalAlertDismiss = null;
    };

    AlertDismiss.prototype.render = function() {
      var _this = this;

      this.element = $(this.template()).appendTo($('body'));

      this.bindCloseEvent();
      this.bindActionButtonEvents();
      this.show();
    };

    AlertDismiss.getAlertDismiss = function(title, msg, opt) {
      if (globalAlertDismiss) {
        globalAlertDismiss.destroy();
      }

      globalAlertDismiss = new AlertDismiss(title, msg, opt);

      return globalAlertDismiss;
    };


    return AlertDismiss;
  })();
}).call(this);
