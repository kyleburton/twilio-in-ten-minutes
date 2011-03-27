var CallSession = function() {
  var self = {};

  self.initialize = function () {
    self.getSessionInfo();
  };

  self.getSessionInfo = function () {
    $.ajax({
      url:      '/call_session/' + self.id,
      type:     'GET',
      dataType: 'json',
      success:  self.receiveSessionInfo,
      error:    self.serverError,
    });
  };

  self.receiveSessionInfo = function (data) {
    self.lastResponse = data;
    $('#session-history').html('');
    $.each(data.workflow_history,function(idx,hist) {
        var content = '';
        content += '<div class="workflow-state">' + hist.state + '</div>';
        content += '<div class="workflow-message">' + hist.message + '</div>';
        $('#session-history').append(content);
    });

    setTimeout( self.getSessionInfo, 1000 );
  };

  self.serverError = function (xhr,errStatus,err) {
    // alert("Error retreiving session info from server: " + errStatus);
    setTimeout( self.getSessionInfo, 1000 );
  };

  return self;
}();

$().ready(CallSession.initialize);
