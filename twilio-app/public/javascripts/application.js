// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Ivr = function() {
  var self = {};

  self.initialize = function () {
  };

  self.formatTwml = function(twml) {
    twml = twml.replace(/<!--.+?-->[\r\n]?/g,"");
    twml = twml.replace(/<\?.+?\?>[\r\n]?/g,"");
    twml = twml.replace(/&/g,"&amp;");
    twml = twml.replace(/>/g,"&gt;");
    twml = twml.replace(/</g,"&lt;");
    twml = twml.replace(/&lt;Say&gt;(.+?)&lt;\/Say&gt;/g,"&lt;Say&gt;<span class=\"twml-say\">$1</span>&lt;/Say&gt;");
    return twml;
  };

  return self;
}();

$().ready(Ivr.initialize);

