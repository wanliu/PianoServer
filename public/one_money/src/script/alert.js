;(function() {
  function Alert(opt) {
    this.title = opt.title || '消息';
    this.msg   = opt.msg   || '';
    this.link  = opt.link  || #;
    this.style = {
      container: {
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        display: 'none',
        position: 'absolute',
        background: 'rgba(0, 0, 0, 0.6)',
      },
      panel: {
        top: '30%',
        width: '80%',
        margin: '0 auto',
        overflow: 'hidden',
        background: '#fff',
        position: 'relative',
      },
      header: {
        width: '100%',
        color: '#FFF',
        'line-height': '50px',
        'text-align': 'center',
        background: '#369',
        position: 'relative',
      },
      close: {
        top: 0,
        right: 0,
        width: '50px',
        color: '#FFF',
        background: '#C00',
        position: 'absolute',
        'line-height': '50px',
        'text-align': 'center',
        'font-size': '28px',
      },
      msg: {
        padding: '10px'
      }

    }
  }

  Alert.prototype = {
    styleFormat: function(obj) {
      var style = "";
      for (key in obj) {
        style += key + ':' + obj[key] + ';'
      }
      return style;
    },
    template: function() {
      return '\
        <div class="alert-container" style="'+ this.styleFormat(this.style.container) +'">\
          <div class="panel" style="'+ this.styleFormat(this.style.panel) +'">\
            <header class="alert-header" style="'+ this.styleFormat(this.style.header) +'">'+ this.title +'</header>\
            <span class="alert-close-btn" style="'+ this.styleFormat(this.style.close) +'">×</span>
            <p class="alert-msg" style="'+ this.styleFormat(this.style.msg) +'">\
              <span>'+ this.msg +'</span>
              <a href="'+ this.link +'">link</a>\
            </p>\
          </div>\
        </div>\
      ';
    },
    show: function() {
      $('.alert-container').fadeIn();
    },
    hide: function() {
      $('.alert-container').fadeOut();
    },
    render: function() {
      var _this = this;
      $('body').append(this.template());
      $('.alert-close-btn').on('click', function() {
        _this.hide();
      });
      $('.alert-container').fadeIn();
    }
  }
  window.Alert = Alert;

})();