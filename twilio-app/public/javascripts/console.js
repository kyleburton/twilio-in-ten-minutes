/* console.js */

var Console = function () {
  var self = {};

  self.initialize = function () {
    self.fetchActiveSessions();
  };

  self.fetchActiveSessions = function () {
    $.ajax({
      url: '/console/active_sessions',
      data: { },  
      success: self.receiveActiveSessions,
      error: self.ajaxError,
      dataType: 'json'
    }); 
    return false;
  };

  self.ajaxError = function (xhr, err) {
    console.log('err=%s', err);
    console.log('xhr=%s', xhr);
  };

  self.receiveActiveSessions = function (data) {
    console.log('active sessions[len=%s]=%s', data.length, data);
    $.each(data, function(idx,sessionInfo) {
        console.log('data[%s] entry=%s', idx, sessionInfo);
        console.dir(sessionInfo);
        $('#active-sessions').append(
          $('<p>').append(sessionInfo.id + " : ")
                  .append( $('<a>').attr('href','#')
                                   .attr('session-id',sessionInfo.id)
                                   .click(self.clickSessionLink)
                                   .append(sessionInfo.name) )
        );
    });
    return true;
  };

  self.clickSessionLink = function (event) {
    self.last = event;
    console.log('event=%s', event);
    var sessionId = $(event.target).attr("session-id");
    return false;
  }

  return self;
}();

$(document).ready(Console.initialize);
