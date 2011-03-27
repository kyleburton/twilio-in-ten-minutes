var Workflow = function () {
  var self = {}, imageStates = {};

  self.imageStates = imageStates;

  self.tstamp = function () {
    return (new Date()).getTime();
  };

  self.callSid = "Sid-" + self.tstamp() + "-" + Math.floor(Math.random() * 100000);

  self.initialize = function () {
    console.log("binding to click for the image...");
    $('#workflow-graph').click(self.toggleWorkflowImageSize);
    $('#workflow-form').submit(Workflow.formSubmit);
    $('#input-digits').focus();
    $('#press-digits').click(self.pressDigitsButtonClicked);
    $('#caller').val('(610) 555-1212');
    $('#call-sid').val(self.callSid);
    $('#reset').click(self.resetButtonClicked);
  };

  self.toggleWorkflowImageSize = function (event) {
    console.log("toggle the workflow image size");
    self.x = event;
    var img = event.target;
    if ( imageStates[img.src] == null ) {
      console.log("initializing for %s", img.src);
      imageStates[img.src] = {
        state: "min",
        naturalHeight: img.naturalHeight,
        naturalWidth:  img.naturalWidth,
        reducedHeight: img.clientHeight,
        reducedWidth:  img.clientWidth
      };
    }

    if ( imageStates[img.src].state == "min" ) {
      console.log("maximizing");
      imageStates[img.src].state = "max";
      $(img).height(imageStates[img.src].naturalHeight);
      $(img).width(imageStates[img.src].naturalWidth);
    }
    else {
      console.log("restoring");
      imageStates[img.src].state = "min";
      $(img).height(imageStates[img.src].reducedHeight);
      $(img).width(imageStates[img.src].reducedWidth);
    }
  };

  self.workflowName = function () {
    return $('#workflow-name').text();
  };

  self.addUserInput = function(input) {
    var content = "<div>"
      + "<div class=\"timestamp\">"
      + "[" + (new Date()).toString() + "]"
      + "</div>"
      + "<span class=\"user-input\"> You Pressed: " + input + "</span>"
      + "</div>";
    $('#conversation').prepend(content);
  };

  self.sendDigits = function () {
    var digits = $('#input-digits').val();
    if (digits.length == 0) {
      return false;
    }

    self.addUserInput(digits);
    $.ajax({
      url: '/workflow/input/' + self.workflowName(),
      type: "POST",
      data: {
             "Caller":  $('#caller').val(),
             "Digits":  digits,
             "CallSid": $('#call-sid').val(),
             "Random":  (new Date()).getTime()
            },  
      success: Workflow.serverResponse,
      error: Workflow.ajaxError,
    }); 
    return false;
  };

  self.serverResponse = function (data) {
    self.lastResponse = data;
    var content = "<div class=\"server-response\">" 
      + "[" + (new Date()).toString() + "]"
      + data.workflow_name + "/" + data.workflow_state
      + "</div>";
    $('#conversation').prepend(content);
          //:workflow_name  => params[:id],
          //:workflow_state => '*none*',
          //:twml           => '*none*'
  };

  self.ajaxError = function (xhr,textStatus,errThrown) {
    self.err = [xhr,textStatus,errThrown];
    var content = "Error!";
    content += "<p>" + textStatus + "</p>";
    content += "<p>" + xhr.responseText + "</p>";
    $('#conversation').prepend(content);
  };

  self.formSubmit = function () {
    self.sendDigits();
    return false;
  };

  self.resetButtonClicked = function () {
    $('#input-digits').val('');
    $('#conversation').html('');
    $('#input-digits').focus();
    $.ajax({
      url: '/call_session/delete/' + self.callSid,
      error: Workflow.ajaxError,
      type: 'DELETE'
    });
    return false;
  };

  return self;
}();

$().ready(Workflow.initialize);
