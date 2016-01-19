#= require _common/event

class @EditTemplateToolbarVariable extends @HuEvent

  @defaultOptions = {
    item_link: '.toolbars li>a'
  }

  constructor: (@element, options = {}) ->
    @options = $.extend({}, @.constructor.defaultOptions, options)
    super(@element)


  onItemClick: (e) ->
    @$modal ||= EditVariableModal.getModal()

    @$modal
    # // $(this).find('.modal-body').load(url);


class @EditVariableModal

  @defaultOptions = {
    modal: '#variable_editor_modal',
  }

  constructor: (options = {}) ->
    @options = $.extend({}, @.constructor.defaultOptions, options)

    @$modal = $(@options["modal"])
    @bindModalEvents()

  bindModalEvents: () ->
    @$modal.on('show.bs.modal', @onModalShow.bind(@))
    @$modal.on('hide.bs.modal', @onModalHide.bind(@))

  onModalShow: (e) ->
    $relatedTarget = $(e.relatedTarget)
    url = $relatedTarget.data('link')
    $variableList = $relatedTarget.parents('.variables:first').find('.variable-items')

    klass = $relatedTarget.data('class')
    op = $relatedTarget.data('op')

    loadUrl = "#{url}/new_#{klass}"
    isEdit = false

    if op == 'edit'
      loadUrl = "#{url}/edit"
      isEdit = true

    @$modal.find('.modal-body').load loadUrl, () =>
      switch klass
        when 'promotion_variable'
          if isEdit
            @modal = new PromotionVariableEditModal(@$modal, url, $variableList)
          else
            @modal = new PromotionVariableModal(@$modal, url, $variableList)
        when 'promotion_set_variable'
          if isEdit
            @modal = new PromotionSetVariableEditModal(@$modal, url, $variableList)
          else
            @modal = new PromotionSetVariableModal(@$modal, url, $variableList)
        when 'item_variable'
          if isEdit
            @modal = new ItemVariableEditModal(@$modal, url, $variableList)
          else
            @modal = new ItemVariableModal(@$modal, url, $variableList)
        when 'item_set_variable'
          if isEdit
            @modal = new ItemSetVariableEditModal(@$modal, url, $variableList)
          else
            @modal = new ItemSetVariableModal(@$modal, url, $variableList)


  onModalHide: () ->
    if @modal && @modal.destroy
      @modal.destroy()
      @modal = null

  @getModal: () ->
    @editVariableModal = new EditVariableModal()
