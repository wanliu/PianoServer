class UserTable < TableCloth::Base
  # Define columns with the #column method
  column :id, :username, :email, :mobile, :nickname, :current_sign_in_ip, :sign_in_count, :created_at, :updated_at

  UPLOAD_HELPER = Proc.new do |user|
    <<-HTML
      <img src='#{user.image.url(:cover)}' height='50' width='50' class='upload-image' data-user-id='#{user.id}'>
      <div type="button" class="uploader-btn" data-user-id='#{user.id}'>upload</div>
      <script type="text/javascript">
        (function() {
          var token = $("meta[name=csrf-token]").attr('content');
          var action = "/admins/accounts/upload_user_avatar?user_id=#{user.id}";
          var $button = $(".uploader-btn[data-user-id=#{user.id}]");
          var $img = $("img[data-user-id=#{user.id}]");

          function uploadSucc(data, status, xhr) {
            var url = xhr.url;
            $img.attr('src', url);
          }
          
          $uploader = new qq.FileUploader({
            element: $button[0],
            action: action,
            customHeaders: { "X-CSRF-Token": token },
            multiple: false,
            onComplete: uploadSucc
          });
        })();
      </script>
    HTML
  end

  # Columns can be provided a block
  #
  # column :name do |object|
  #   object.downcase
  # end
  #
  # Columns can also have conditionals if you want.
  # The conditions are checked against the table's methods.
  # As a convenience, the table has a #view method which will return the current view context.
  # This gives you access to current user, params, etc...
  #
  # column :email, if: :admin?
  #
  # def admin?
  #   view.current_user.admin?
  # end
  #
  # Actions give you the ability to create a column for any actions you'd like to provide.
  # Pass a block with an arity of 2, (object, view context).
  # You can add as many actions as you want.
  # Make sure you include the actions extension.
  #
  actions do
    action { |user| UPLOAD_HELPER.call(user).html_safe }
  end
  #
  # If action provides an "if:" option, it will call that method on the object. It can also take a block with an arity of 1.
end
