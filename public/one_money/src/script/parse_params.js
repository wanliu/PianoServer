function getQueryParams() {
  var search = location.search;
  var href = location.href;
  var hash;

  if (search) {
    hash = search.length === 0 ? search : search.slice(1);
  } else {
    var ary = href.split('?');

    hash = ary.length > 1 ? ary[1] : '';
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
