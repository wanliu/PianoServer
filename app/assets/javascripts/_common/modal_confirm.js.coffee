@modalConfirm = (text, execute, cancel) ->
  confirmed = false

  modalHtml = """
    <div class="modal fade" tabindex="-1" role="dialog">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">操作警告</h4>
          </div>
          <div class="modal-body">
            <p>#{text}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default cancel" data-dismiss="modal">取消</button>
            <button type="button" class="btn btn-danger execute">确定</button>
          </div>
        </div>
      </div>
    </div>
  """
  $modal = $(modalHtml)
  $('body').append($modal)

  $modal.on 'click', '.execute', (event) ->
    confirmed = true
    execute() if execute
    $modal.modal('hide')

  $modal.on 'click', '.cancel', (event) ->
    cancel() if cancel
    $modal.modal('hide')

  $modal.on 'hidden.bs.modal', (event) ->
    cancel() if !confirmed && cancel
    $modal.remove()

  $modal.modal('show')