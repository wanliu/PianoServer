$(function() {
  $.ajax({
    url: '/api/promotions/one_money/1/status/1?winners=10',
    success: function(res) {
      var completes = res.completes;
      var participant_count = res.participant_count;
      var winner_count = res.winner_count;
      var totle_participant_count = winner_count + participant_count || 0;

      $('.participant-amonut .amount').text(totle_participant_count);
      $('.status-wrap .sold span').text(completes);

      var winners = res.winners || [];
      winners.map(function(winner) {
        new Winner(winner);
      });
    }
  })
});

function Winner(data) {
  for (key in data) {
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
    $('.users-list').append(this.template())
  }

}