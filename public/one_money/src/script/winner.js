  function getQueryParams() {
    var search = location.search;
    var href = location.href;
    var hash;

    if (search) {
      hash = search.slice(1);
    } else {
      hash = href.split('?')[1];
    }

    var params = {};
    var ary = hash.split('&');

    for (var i=0; i<ary.length; i++) {
      var entry = ary[i].split('=');
      var key = entry[0];
      var value = entry[1];

      params[key] = value;
    }

    return params;
  }

  var params = getQueryParams();
  $.ajax({
    url: '/api/promotions/one_money/'+params.one_money_id+'/status/'+ params.id +'?winners=10',
    success: function(res) {
      var completes = res.completes;
      var participant_count = res.participant_count;
      var winner_count = res.winner_count;
      var totle_participant_count = winner_count + participant_count || 0;

      $('.participant-amonut .amount').text(totle_participant_count);
      $('.status-wrap .sold span').text(completes);

      var winners = res.winners || [];
    
      if (winners.length) $('.users-list').append('<div class="title">幸运用户</div>');
      winners.map(function(winner) {
        new Winner(winner);
      });
    }
  })


function Winner(data) {
  for (var key in data) {
    this[key] = data[key]
  }
  this.render();
}

Winner.prototype = {
  template: function() {
    return '\
      <img src="'+ this.avatar_url +'"/>\
    ';
  },
  render: function() {
    $('.users-list').append(this.template());
  }
}