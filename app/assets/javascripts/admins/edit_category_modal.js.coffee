#= require _common/event

class @EditCategoryModal extends @HuEvent
  events:
    'click .enter-category': 'showChildCategories',
    'click .edit-category': 'editCategory',
    'click .take-photo': 'takePhoto',
    'click .upload-image': 'uploadImage',
    'click .delete-category': 'deleteCategory'

  constructor: (@element) ->
    super(@element)

  showChildCategories: () ->
    url = @$().data('url')
    Turbolinks.visit(url)

  editCategory: () ->
    url = @$().data('url')
    edit_url = url + '/edit'
    Turbolinks.visit(edit_url)

  takePhoto: () ->

  uploadImage: () ->
    url = @$().data('url')
    edit_url = url + '/edit'
    Turbolinks.visit(edit_url)

  deleteCategory: () ->
    @$().modal('hide')

    url = @$().data('url')

    dataConfirmModal.confirm({
      title: '删除提示',
      text: '确认删除此参数吗?',
      commit: '删除',
      cancel: '取消',
      dataType: 'script',
      onConfirm: () =>
        $.ajax({
          url: url,
          type: 'DELETE',
          success: () =>

          error: (errors) =>
            alert(errors)
        })
    })

