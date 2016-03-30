tableHtml = '''
  <div class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <h4 class="modal-title">选择范围</h4>
        </div>
        <div class="modal-body">
          <table class="table setting-code">
            <thead>
              <tr>
                <th width="30%">范围</th>
                <th width="70%">选择</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>默认全部</td>
                <td>
                  <button class="btn btn-default" data-type="province" data-id="default">默认全部</button>
                </td>
              </tr>
              <tr>
                <td>
                  华北
                </td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="110000">北京市</button>
                    <button class="btn btn-default" data-type="province" data-id="120000">天津市</button>
                    <button class="btn btn-default" data-type="province" data-id="130000">河北省</button>
                    <button class="btn btn-default" data-type="province" data-id="140000">山西省</button>
                    <button class="btn btn-default" data-type="province" data-id="150000">内蒙古自治区</button>
                </td>
              </tr>
              <tr>
                <td>东北</td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="210000">辽宁省</button>
                    <button class="btn btn-default" data-type="province" data-id="220000">吉林省</button>
                    <button class="btn btn-default" data-type="province" data-id="230000">黑龙江省</button>
                </td>
              </tr>
              <tr>
                <td>
                  华中
                </td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="410000">河南省</button>
                    <button class="btn btn-default" data-type="province" data-id="420000">湖北省</button>
                    <button class="btn btn-default" data-type="province" data-id="430000">湖南省</button>
                </td>
              </tr>
              <tr>
                <td>华东</td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="310000">上海市</button>
                    <button class="btn btn-default" data-type="province" data-id="320000">江苏省</button>
                    <button class="btn btn-default" data-type="province" data-id="330000">浙江省</button>
                    <button class="btn btn-default" data-type="province" data-id="340000">安徽省</button>
                    <button class="btn btn-default" data-type="province" data-id="350000">福建省</button>
                    <button class="btn btn-default" data-type="province" data-id="360000">江西省</button>
                    <button class="btn btn-default" data-type="province" data-id="370000">山东省</button>
                </td>
              </tr>
              <tr>
                <td>华南</td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="440000">广东省</button>
                    <button class="btn btn-default" data-type="province" data-id="450000">广西壮族自治区</button>
                    <button class="btn btn-default" data-type="province" data-id="460000">海南省</button>
                </td>
              </tr>
              <tr>
                <td>西南</td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="500000">重庆市</button>
                    <button class="btn btn-default" data-type="province" data-id="510000">四川省</button>
                    <button class="btn btn-default" data-type="province" data-id="520000">贵州省</button>
                    <button class="btn btn-default" data-type="province" data-id="530000">云南省</button>
                    <button class="btn btn-default" data-type="province" data-id="540000">西藏自治区</button>
                </td>
              </tr>
              <tr>
                <td>西北</td>
                <td>
                    <button class="btn btn-default" data-type="province" data-id="610000">陕西省</button>
                    <button class="btn btn-default" data-type="province" data-id="620000">甘肃省</button>
                    <button class="btn btn-default" data-type="province" data-id="630000">青海省</button>
                    <button class="btn btn-default" data-type="province" data-id="640000">宁夏回族自治区</button>
                    <button class="btn btn-default" data-type="province" data-id="650000">新疆维吾尔自治区</button>
                </td>
              </tr>
            </tbody>
          </table>
          <div style="display: none;" class="setting-fee">
            地区：<span class="chose-area"></span></br>
            运送费用：<input class="fee" type="number" step=0.01>  
          </div>
        </div>
        <div class="modal-footer">
          <div class="setting-code">
            <div class="notify pull-left">
              已选定：<span class="select-notify">暂无选定地区，请在上方选定一个地区</span>
            </div>
            <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
            <button type="button" class="btn btn-primary chose" disabled="disabled">选定</button>
            <button type="button" class="btn btn-default next-button" disabled="disabled">下一级</button>
          </div>
          <div class="setting-fee" style="display: none;">
            <button class="btn btn-default return-previous">重选地区</button>
            <button class="btn btn-primary submit" disabled="disabled">确定</button>
          </div>
        </div>
      </div>
    </div>
  </div>''';

class @DeliveryArea
  constructor: ($element) ->
    if $element instanceof jQuery
      @$element = $element
    else 
      @$element = $($element)

    @$modal = $(tableHtml)
    @postUrl = @$element.data('url')
    @$element.closest('body').append(@$modal)

    @$modal.on 'click', 'td button', @clickArea
    @$modal.on 'click', '.chose', @choseArea
    @$modal.on 'keyup', '.fee', @enableSubmit
    @$modal.on 'click', '.submit', @submitFee

    @$element.on 'click', @showModal

  showModal: (e) =>
    @$modal.modal('show')

  clickArea: (e) =>
    $target = $(e.target || e.srcElement)

    @type = $target.data('type')
    @text = $target.text()
    @id = $target.data('id')

    @showSelectNotify(@text)
    $target.addClass('active')

    if "province" == @type || "city" == @type
      @showNextButton()

    @$modal.find('.chose').removeAttr('disabled')

  showSelectNotify: (text) ->
    @$modal.find('.select-notify').text(text)
    @$modal.find('.chose-area').text(text)

  showNextButton: () ->
    @$modal.find('.next-button')
      .removeAttr('disabled')

  choseArea: (e) =>
    # @showFeeModal()
    # @clearStatus()
    @$modal.find('.setting-code').hide()
    @$modal.find('.setting-fee').show()
  
  submitFee: (e) =>
    fee = @$modal.find('.fee').val()
    $.post(@postUrl, {code: @id, fee: fee})
      .done (data, status, xhr) ->
        debugger
      .fail (data, status, xhr) ->
        debugger

  enableSubmit: (e) =>
    $target = $(e.target || e.srcElement)
    fee = $target.val()

    if fee.match(/^\d+(\.\d+)?$/)
      @$modal.find('.submit').removeAttr('disabled')
    else
      @$modal.find('.submit').attr('disabled', 'disabled')