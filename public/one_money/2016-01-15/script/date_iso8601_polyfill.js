!function(){var r=window.Date,e=/^(\d{4}|\+\d{6})(?:-(\d{2})(?:-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2})\.(\d{1,3})(?:Z|([\-+])(\d{2}):(\d{2}))?)?)?)?$/;(1322581950500!==r.parse("2011-11-29T15:52:30.5")||1322581950520!==r.parse("2011-11-29T15:52:30.52")||1322581938867!==r.parse("2011-11-29T15:52:18.867")||1322581938867!==r.parse("2011-11-29T15:52:18.867Z")||1322594538867!==r.parse("2011-11-29T15:52:18.867-03:30")||13225248e5!==r.parse("2011-11-29")||13201056e5!==r.parse("2011-11")||129384e7!==r.parse("2011"))&&(r.__parse=r.parse,r.parse=function(a){var s=e.exec(a);return s?Date.UTC(s[1],(s[2]||1)-1,s[3]||1,s[4]-(s[8]?s[8]+s[9]:0)||0,s[5]-(s[8]?s[8]+s[10]:0)||0,s[6]||0,((s[7]||0)+"00").substr(0,3)):r.__parse.apply(this,arguments)}),r.__fromString=r.fromString,r.fromString=function(a){return!r.__fromString||e.test(a)?new r(r.parse(a)):r.__fromString.apply(this,arguments)}}();