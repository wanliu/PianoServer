//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require lib/es5-shim
//= require lib/es5-sham
//= require data-confirm-modal
//= require moment
//= require moment/zh-cn
//= require bootstrap-datetimepicker
//= require bootstrap-sprockets
//= require turbolinks
//= require nprogress
//= require nprogress-turbolinks
//= require china_city/jquery.china_city
//= require ace-rails-ap
//= require ace/mode-liquid
//= require ace/ext-language_tools
//= require best_in_place
//= require select2.full
//= require select2_locale_zh-CN
//= require picturefill.all
//= require _common/fileuploader
//= require _common/hammer
//= require _common/util
//= require _common/save_on_change
//= require _common/image-scale
//= require lib/socketcluster-client
//= require lib/user-socket
//= require lib/underscore
//= require lib/underscore-template
//= require lib/bootstrap-select
//= require lib/ace_editor
//= require lib/ajax_status
//= require lib/fastclick
//= require utils/alert-dismiss
//= require _common/fileuploader
//= require _common/paginate
//= require _common/qrcode
//= require _common/side_menu
//= require _common/side_menu_manager
//= require _common/delivery_area
//= require bootsy
//= require lib/tablesaw
//= require jquery-ui/core
//= require jquery-ui/widget
//= require jquery-ui/mouse
//= require jquery-ui/position
//= require jquery-ui/sortable
//= require jquery-ui/effect.all
//= require_tree ./locales
//= require_tree ./admins
//= require_tree ./utils
//= require_tree ./shop
//= require_tree ./notify
//= require_self

dataConfirmModal.setDefaults({
  title: '确认执行此操作？',
  commit: '确定',
  cancel: '取消'
});

_.templateSettings = {
  interpolate: /\{\{(.+?)\}\}/g
};
// $(function() {
//     FastClick.attach(document.body);
// });
