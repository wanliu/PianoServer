

class @NewItemPoster
  constructor: (@element, @url) ->
    @$uploader = new qq.FileUploader({
      element: @element.find('.uploader-btn')[0],
      action: @url + "/upload_image",
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      template: """
        <div class="qq-uploader">
          <div class="qq-upload-drop-area"><span>{dragText}</span></div>
          <div class="qq-upload-button">
            <span class="button-icon glyphicon glyphicon-picture"></span>
          </div>
          <ul class="qq-upload-list"></ul>
        </div>
      """,
      onComplete: @onUploader.bind(@)
    })
