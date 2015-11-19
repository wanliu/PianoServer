TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'
ANIMATION_ENDS  = 'webkitAnimationEnd oanimationend oAnimationEnd msAnimationEnd Animation'

# 进入效果
class ShopAnimationEnter
  constructor:(className,color) ->
    @$ = $(className)
    @color = color || '#fff'
    @bindClickEvent()

  bindClickEvent: ->
    @$.on 'click', (e) =>
      e.preventDefault()
      if !@isAnimate
        @getStyleFormTarget(e)

  getStyleFormTarget: (e) ->
    @target = $(e.currentTarget)
    @position = {
      'left'      : @target.offset().left + parseInt(@target.css('paddingLeft'))
      'top'       : @target.offset().top + parseInt(@target.css('paddingTop'))
      'width'     : @target.width()
      'height'    : @target.height()
      'position'  : 'absolute'
      'background': @color
      'opacity'   : 0
      'transform':'scale(0.5)'
    }
    @mask = $('<div class="animate-mask"></div>').appendTo($('body')).css(@position)
    @isAnimate = true
    @scaleMask()

  scaleMask: ->
  # 隐藏原容器
    @target.css({
      'opacity':0
      'transition': 'all 0.3s'
      'transform': 'scale(0.5)'
    })
    $window = $(window)
    @target.one TRANSITION_ENDS, ()=>
      @mask.css({
        'opacity'  : 0.8
        'left'     : 0
        'top'      : $window.scrollTop()
        'width'    : $window.width()
        'height'   : $window.height()
        'transition': 'all 0.3s'
        'transform':'scale(1)'
      })

    @mask.one TRANSITION_ENDS, ()=>
      @linkTo()

  linkTo: ->
    @target.addClass('animationed')
    url = @$.children().attr('href')
    @isAnimate = false
    Turbolinks.visit(url)

# 返回效果
class ShopAnimationBack
  constructor: ->
    $(document).on 'page:change', @back
  back: ->
    @$ = $('.animationed')
    if @$.length
      @$.css({'transform': 'scale(1)'})
      @mask = $('.animate-mask')
      @position = {
        'left'      : @$.offset().left + parseInt(@$.css('paddingLeft'))
        'top'       : @$.offset().top + parseInt(@$.css('paddingTop'))
        'width'     : @$.width()
        'height'    : @$.height()
        'transform' : 'scale(0.5)'
        'opacity'   : 0.5
      }
      # 缩小
      @mask.css(@position).one TRANSITION_ENDS, ()=>
        @mask.remove()
        @$.css({'opacity':1}).removeClass('animationed')

$ ->
  enter = new ShopAnimationEnter('.cate')
  back = new ShopAnimationBack()