module UploadHelper

  def form_for(*args, &block)
    options = args.extract_options!
    options[:builder] = UploadFormBuilder

    super(*args, options, &block)
  end

  def upload_button(object_name, field, *args)
    options = args.extract_options!
    object = self.instance_variable_get("@#{object_name}")
    title = object.send(field)
    url = options[:url]
    upload_object_id = caller.object_id
    image_options = options.delete(:image) || {}
    image_options[:class] = [image_options[:class]] + ["upload-image-#{upload_object_id}"]

    output = <<-HTML
      <div class="image-uploader">
        <div class="image-handle">
          #{image_tag object.send(field), image_options}
        </div>
        <div class="upload-#{upload_object_id}">
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
          onComplete: function (id, filename, responseJSON) {
            var url = responseJSON.url;
            $(".upload-image-#{upload_object_id}").attr('src', url);
          }
        });
      </script>
    HTML
    output.html_safe
  end

  def image_upload_button(object_name, field, *args)
    options = args.extract_options!
    object = self.instance_variable_get("@#{object_name}")
    title = object.send(field)
    url = options[:url]
    upload_object_id = caller.object_id

    disable_text = options.delete(:disable_text)

    image_options = options.delete(:image) || {}
    image_options[:class] = [image_options[:class]] + ["upload-image-#{upload_object_id}"]

    template = <<-HTML
      <div class="qq-uploader">
        <div class="qq-upload-drop-area"><span>{dragText}</span></div>
        <div class="qq-upload-button">
          #{image_tag object.send(field), image_options}
          #{disable_text ? '' : "<span>{uploadButtonText}</span>"}
          #{hidden_field_tag "#{object_name}[#{field}]", object.read_attribute(field), data: {"input-id" => upload_object_id }}
        </div>
        <ul class="qq-upload-list"></ul>
      </div>
    HTML

    output = <<-HTML
      <div class="image-uploader-button upload-#{upload_object_id}">
      </div>
      <script type="text/javascript">

        var shopId = "<%= @shop.id %>";

        var $element = $(".upload-#{upload_object_id}")[0];
        var actionUrl = "#{url}"
        var token = $('meta[name=csrf-token]').attr('content');

        new qq.FileUploader({
          element: $element,
          customHeaders: { "X-CSRF-TOKEN": token },
          template: #{template.inspect},
          action:  actionUrl + "?authenticity_token=" + encodeURIComponent(token),
          multiple: false,
          onComplete: function (id, filename, responseJSON) {
            var url = responseJSON.url;
            $(".upload-image-#{upload_object_id}").attr('src', url);
            $("[data-input-id=\\"#{upload_object_id}\\"]").val(responseJSON.filename);
          }
        });
      </script>
    HTML
    output.html_safe
  end
end
