#= require _common/event

class @CategoryToolbar extends @HuEvent
  events:
    "click .btn-category": "onClickCategory"
    "click .btn-brand": "onClickBrand"


  onClickCategory: (e) ->
    return if $(".category-panel").is(':animated')

    $(".category-panel").slideToggle()

  onClickBrand: (e) ->
    return if $(".brand-panel").is(':animated')

    $(".brand-panel").slideToggle()
