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
