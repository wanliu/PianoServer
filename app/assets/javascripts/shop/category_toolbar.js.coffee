#= require _common/event

class @CategoryToolbar extends @HuEvent
  events:
    "click .btn-category": "onClickCategory"


  onClickCategory: (e) ->
    $(".category-panel").slideToggle()
