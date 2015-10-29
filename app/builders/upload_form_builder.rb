class UploadFormBuilder < ActionView::Helpers::FormBuilder

  def upload_field(field, title = nil, options = {})
    title = title || @object.send(field)
    url = options[:url] || File.join(@options[:url], "upload")
    upload_object_id = caller.object_id

    output = <<-HTML
      <div class="image-uploader">
        #{@template.image_tag @object.send(field), class: "upload-image-#{upload_object_id}"}
        <div class="image-uploader-button upload-#{upload_object_id}">
        </div>
      </div>
      <script type="text/javascript">

        var shopId = "<%= @shop.id %>";

        var $element = $(".upload-#{upload_object_id}")[0];
        var actionUrl = "#{url}"
        var token = $('meta[name=csrf-token]').attr('content');

        new qq.FileUploader({
          element: $element,
          customHeaders: { "X-CSRF-TOKEN": token },
          action:  actionUrl + "?authenticity_token=" + encodeURIComponent(token),
          multiple: false,
          // template: $(".file-uploader-template").html(),
          onComplete: function (id, filename, responseJSON) {
            var url = responseJSON.url;
            $(".upload-image-#{upload_object_id}").attr('src', url);
          }
        });
      </script>
    HTML
    output.html_safe
  end
end
