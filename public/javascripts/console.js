/* console.js */

var Console = function () {
  var self = {};

  self.initialize = function () {
    self.fetchActiveSessions();
  };

  self.fetchActiveSessions = function () {
    $.ajax({
      url: '/console/active_sessions',
      success: self.receiveActiveSessions,
      error: self.ajaxError,
      type: 'GET',
      dataType: 'json'
    }); 
    return false;
  };

  self.ajaxError = function (xhr, err) {
    console.log('err=%s', err);
    console.log('xhr=%s', xhr);
  };

  self.receiveActiveSessions = function (data) {
    self.lastResponse = data;
    console.log('active sessions[len=%s]=%s', data.length, data);
    if (data.length == 0) {
      $('#active-sessions').text("No sessions are active.");
      return true;
    }

    $.each(data, function(idx,sessionInfo) {
        console.log('data[%s] entry=%s', idx, sessionInfo);
        console.dir(sessionInfo);
        var link = $('<a>');
        link.attr('href','/call_session/' + sessionInfo.call_session.id);
        //link.attr('id',sessionInfo.call_session.id);
        //link.click(self.clickSessionLink);
        link.append(sessionInfo.call_session.caller_number);
        $('#active-sessions').append(
          $('<p>').append(sessionInfo.call_session.id + " : ")
                  .append( link )
        );
    });
    return true;
  };

  return self;
}();

$(document).ready(Console.initialize);
