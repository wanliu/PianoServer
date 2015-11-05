#= require _common/event

class @EditCategoryModal extends @HuEvent
  events:
    'click .enter-category': 'showChildCategories',
    'click .edit-category': 'editCategory',
    'click .take-photo': 'takePhoto',
    'click .upload-image': 'uploadImage',
    'click .show-category': 'showCategory',
    'click .hide-category': 'hideCategory',
    'click .delete-category': 'deleteCategory'

  constructor: (@element) ->
    super(@element)

    @$().on('show.bs.modal', (e) =>
      status = @$().data('status')
      $menu = @$().find('.list-group')

      if status
        $menu.addClass('category-shown')
      else
        $menu.removeClass('category-shown')
    )

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
      text: '确认删除此分类吗?',
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

  hideCategory: () ->
    url =  @$().data('url')

    $.ajax({
      url: url + '/update_status',
      type: 'PUT',
      dateType: 'json',
      data: {
        shop_category: {
          status: false
        }
      },
      success: () =>
        @$().modal('hide')

        related = @$().data('related')
        $toggle = related.$().find('.toggle-button')
        related.status = false

        if $toggle.length > 0
          $toggle.addClass('closed')
    })

  showCategory: () ->
    url =  @$().data('url')

    $.ajax({
      url: url + '/update_status',
      type: 'PUT',
      dateType: 'json',
      data: {
        shop_category: {
          status: true
        }
      },
      success: () =>
        @$().modal('hide')

        related = @$().data('related')
        $toggle = related.$().find('.toggle-button')
        related.status = true

        if $toggle.length > 0
          $toggle.removeClass('closed')
    })
