class @AlertDismiss
  constructor: (@title, @message) ->
    # @generatorOverlayer()
    @generateContent()

  generatorOverlayer: () ->
    @$overlayer = $('<div></div>').css({
      width: '100%',
      height: '100%',
      position: 'fixed',
      zIndex: '1050',
      background: '#EEEEEE',
      opacity: '0.8'
    }).appendTo($('body').css('overflow', 'hidden'))

  generateContent: () ->
    template = """
      <div class="modal fade">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h4 class="modal-title">#{@title}</h4>
            </div>
            <div class="modal-body">
              <p>#{@message}</p>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
            </div>
          </div>
        </div>
      </div>
    """

    @$content = $(template).appendTo($('body'))
    @$content.modal()
