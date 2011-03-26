var Workflow = function () {
  var self = {}, imageStates = {};

  self.imageStates = imageStates;

  self.initialize = function () {
    console.log("binding to click for the image...");
    $('#workflow-graph').click(self.toggleWorkflowImageSize);
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

  return self;
}();

$().ready(Workflow.initialize);
