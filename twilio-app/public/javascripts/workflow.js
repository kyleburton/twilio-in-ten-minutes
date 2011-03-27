var Workflow = function () {
  var self = {}, imageStates = {};

  self.imageStates = imageStates;

  self.tstamp = function () {
    return (new Date()).getTime();
  };
  self.randomVal = function () {

    return self.tstamp() + "-" + Math.floor(Math.random() * 100000);
  };

  self.callSid = "Sid-" + self.tstamp() 
               + "-" + Math.floor(Math.random() * 100000);
  self.interactionCounter = 0;

  self.initialize = function () {
    console.log("binding to click for the image...");
    $('#workflow-graph').click(self.toggleWorkflowImageSize);
    $('#workflow-form').submit(Workflow.formSubmit);
    $('#input-digits').focus();
    $('#press-digits').click(self.pressDigitsButtonClicked);
    $('#caller').val('(610) 555-1212');
    $('#call-sid').val(self.callSid);
    $('#reset').click(self.resetConversation);
    self.requestCurrentMessage();
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
      url: '/workflow/input/' + self.workflowName() + '?' + self.randomVal(),
      type: "POST",
      data: {
             "Caller":  $('#caller').val(),
             "Digits":  digits,
             "CallSid": $('#call-sid').val()
            },  
      success: Workflow.serverResponse,
      error: Workflow.ajaxError,
    }); 
    return false;
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

  self.serverResponse = function (data) {
    self.lastResponse = data;
    var content = '';
    content += "Step: " + (++self.interactionCounter) + "<br/>";
    if (data.error) {
      content
        += "<div class=\"workflow-error-message\">"
        +  data.error
        +  "</div>";

    }
    content 
      += "<div class=\"server-response\">" 
      +  "<span class=\"workflow-state\">"
      +  "[" + (new Date()).toString() + "]"
      +  data.workflow_name + "/" + data.workflow_state
      +  "</span>"
      +  "<pre class=\"twml\">"
      +  self.formatTwml(data.twml)
      +  "</pre>"
      +  "</div>";
          //:workflow_name  => params[:id],
          //:workflow_state => '*none*',
          //:twml           => '*none*'
    $('#conversation').prepend(content);
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

  self.requestCurrentMessage = function () {
    $.ajax({
      url: '/workflow/input/' + self.workflowName() + '?' + self.randomVal(),
      type: "POST",
      data: {
             "Caller":  $('#caller').val(),
             "Digits":  '',
             "CallSid": $('#call-sid').val()
            },  
      success: Workflow.serverResponse,
      error: Workflow.ajaxError,
    }); 
    return false;
  };

  self.resetConversation = function () {
    $('#input-digits').val('');
    $('#conversation').html('');
    $('#input-digits').focus();
    $.ajax({
      url: '/call_session/delete/' + self.callSid,
      error: Workflow.ajaxError,
      success: Workflow.requestCurrentMessage,
      type: 'DELETE'
    });
    return false;
  };

  return self;
}();

$().ready(Workflow.initialize);
