BestInPlaceEditor.forms['image'] = {
  activateForm: function () {
    'use strict';
    // grab width and height of text
    var width = this.element.find('img').css('width');
    var height = this.element.find('img').css('height');

    // construct form
    var output = jQuery(document.createElement('form'))
      .addClass('form_in_place')
      .attr('action', 'javascript:void(0);')
      .attr('style', 'display:inline');

    var img_elt = jQuery(document.createElement('img'))
      .attr('name', this.attributeName)
      .attr('src', this.display_value)
      .width(width)
      .height(height);



    var upload_btn = jQuery(document.createElement('button'))
      .attr('name', this.attributeName)
      .addClass('btn btn-default')
      .val('upload')

    var token = $('meta[name="csrf-token"]').attr('content');

    if (this.inner_class !== null) {
      img_elt.addClass(this.inner_class);
    }

    output.append(img_elt);
    output.append(upload_btn);

    this.placeButtons(output, this);

    this.element.html(output);
    this.setHtmlAttributes();

    var _this = this;
    this.uploader = new qq.FileUploader({
      element: this.element.find('button')[0],
      action: this.url + "/upload_image",
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: function(id, filename, responseJSON) {
        img_elt.attr('src', responseJSON.url);
        $(_this.uploader._listElement).empty()
      }
    });

    // set width and height of textarea
    // jQuery(this.element.find("textarea")[0]).css({'min-width': width, 'min-height': height});
    // jQuery(this.element.find("textarea")[0]).autosize();

    // this.element.find("textarea")[0].focus();
    this.element.find("form").bind('submit', {editor: this}, BestInPlaceEditor.forms.textarea.submitHandler);

    if (this.cancelButton) {
      this.element.find("input[type='button']").bind('click', {editor: this}, BestInPlaceEditor.forms.textarea.cancelButtonHandler);
    }

    if (!this.skipBlur) {
      this.element.find("textarea").bind('blur', {editor: this}, BestInPlaceEditor.forms.textarea.blurHandler);
    }
    this.element.find("textarea").bind('keyup', {editor: this}, BestInPlaceEditor.forms.textarea.keyupHandler);
    this.blurTimer = null;
    this.userClicked = false;
  },

  getValue: function () {
    'use strict';
    return this.sanitizeValue(this.element.find("textarea").val());
  },

  // When buttons are present, use a timer on the blur event to give precedence to clicks
  blurHandler: function (event) {
    'use strict';
    if (event.data.editor.okButton) {
      event.data.editor.blurTimer = setTimeout(function () {
        if (!event.data.editor.userClicked) {
          event.data.editor.abortIfConfirm();
        }
      }, 500);
    } else {
      if (event.data.editor.cancelButton) {
        event.data.editor.blurTimer = setTimeout(function () {
          if (!event.data.editor.userClicked) {
            event.data.editor.update();
          }
        }, 500);
      } else {
        event.data.editor.update();
      }
    }
  },

  submitHandler: function (event) {
    'use strict';
    event.data.editor.userClicked = true;
    clearTimeout(event.data.editor.blurTimer);
    event.data.editor.update();
  },

  cancelButtonHandler: function (event) {
    'use strict';
    event.data.editor.userClicked = true;
    clearTimeout(event.data.editor.blurTimer);
    event.data.editor.abortIfConfirm();
    event.stopPropagation(); // Without this, click isn't handled
  },

  keyupHandler: function (event) {
    'use strict';
    if (event.keyCode === 27) {
      event.data.editor.abortIfConfirm();
    }
  }
};


