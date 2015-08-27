#= require _common/event

class @EditTemplateToolbarVariable extends @Event

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


class EditVariableModal

  @defaultOptions = {
    modal: '#variable_editor_modal',
  }

  constructor: (options = {}) ->
    @options = $.extend({}, @.constructor.defaultOptions, options)

    @$modal = $(@options["modal"])
    @bindModalEvents()

  bindModalEvents: () ->
    @$modal.on('show.bs.modal', @onModalShow.bind(@))

  onModalShow: (e) ->
    url = $(e.relatedTarget).data('link')

    klass = $(e.relatedTarget).data('class')
    newUrl = "#{url}/new_#{klass}"

    @$modal.find('.modal-body').load newUrl, () =>
      switch klass
        when 'promotion_variable'
          modal = new PromotionVariableModal(@$modal, url);
        when 'promotion_set_variable'
          modal = new PromotionSetVariableModal(@$modal, url)
        else

  @getModal: () ->
    @editVariableModal ||= new EditVariableModal()


$ ->
  EditVariableModal.getModal()
