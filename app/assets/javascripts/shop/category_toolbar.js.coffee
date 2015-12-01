#= require _common/event

class @CategoryToolbar extends @HuEvent
  events:
    "click .btn-category": "onClickCategory"
    "click .btn-brand": "onClickBrand"


  onClickCategory: (e) ->
    $(".category-panel").slideToggle()

  onClickBrand: (e) ->
    $(".brand-panel").slideToggle()
