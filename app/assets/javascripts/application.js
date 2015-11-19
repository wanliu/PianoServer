// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require lib/es5-shim
//= require lib/es5-sham
//= require data-confirm-modal
//= require jquery-ui/core
//= require jquery-ui/widget
//= require jquery-ui/mouse
//= require jquery-ui/position
//= require jquery-ui/effect.all
//= require select2
//= *
//= require bootstrap-sprockets
//= require nprogress
//= require turbolinks
//= require nprogress-turbolinks
//= require china_city/jquery.china_city
//= require photoswipe
//*
//= require picturefill.all
//= require best_in_place
//*
//= require lib/best_in_place_form
//= require lib/socketcluster-client
//= require lib/user-socket
//= require lib/underscore
//= require lib/underscore-template
//= require lib/date_iso8601_polyfill
//= require lib/pastemedia
//= require lib/ajax_status
//= require utils/alert-dismiss
//= require _common/fileuploader
//= require _common/qrcode
//= require _common/local-address
//= require _common/hammer
//= require _common/util
//= require _common/image-scale
//= require _common/adjust_container
//= require _common/side_menu
//= require _common/side_menu_manager
//= require_tree ./application
//= require_tree ./chats
//= require_tree ./orders
//= require_tree ./promotions
//= require_tree ./utils
//= require_self


dataConfirmModal.setDefaults({
  title: '确认执行此操作？',
  commit: '删除',
  cancel: '取消'
});
