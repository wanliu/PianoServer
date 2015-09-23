#= require _common/event

class @CategoryToolbar extends @Event
  events:
    "click .btn-category": "onClickCategory"


  onClickCategory: (e) ->
    $(".category-panel").slideToggle()
