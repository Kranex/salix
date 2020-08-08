function registerBlockly(salix) {
	
	var workspaces = {};

	salix.Decoders.blocklyChange = function (args) {
		return function (event) {
			if(event.type != "ui"){
				var workspace = Blockly.Workspace.getById(event.workspaceId);
				var xml = Blockly.Xml.workspaceToDom(workspace);
				var text = new XMLSerializer().serializeToString(xml);
				console.log(text);
				return {type: "blocklyChange",
						msg: text
				};
			};
			return;
		};
	};

	
	// Salix
	function myBlockly(attach, id, attrs, props, events, extra){
		
		// Salix
		var resizable = false;
		var width = "100%";
		var height = "450px";
		
		var options = {
			toolbox: '<xml><block type="controls_if"></block></xml>'
		};

		for (var key in props){
			if(props.hasOwnProperty(key)){
				var val = props[key];
				
				switch(key){
					case 'toolbox':
						console.log(val);
						options.toolbox = val;
						break;
					case 'resizable':
					 	resizable = val;
						break;
					case 'width':
					    width = val;
						break;
					case 'height':
	                    height = val;
						break;
					case 'collapse':
	                    options.collapse = val;
						break;
					case 'comments':
	                    options.comments = val;
						break;
					case 'css':
	                    options.css = val;
						break;
					case 'disable':
	                    options.disable = val;
						break;
					case 'grid':
	                    options.grid = val;
						break;
					case 'horizontallayout':
	                    options.horizontallayout = val;
						break;
					case 'maxBlocks':
	                    options.maxBlocks = val;
						break;
					case 'maxInstances':
	                    options.maxInstances = val;
						break;
					case 'media':
	                    options.media = val;
						break;
					case 'move':
	                    options.move = val;
						break;
					case 'oneBasedIndexing':
	                    options.oneBasedIndexing = val;
						break;
					case 'readOnly':
	                    options.readOnly = val;
						break;
					case 'rtl':
	                    options.rtl = val;
						break;
					case 'scrollBars':
	                    options.scrollBars = val;
						break;
					case 'sounds':
	                    options.sounds = val;
						break;
					case 'theme':
	                    options.theme = val;
						break;
					case 'toolbox':
	                    options.toolbox = val;
						break;
					case 'toolboxPosition':
	                    options.toolboxPosition = val;
						break;
					case 'trashcan':
	                    options.trashcan = val;
						break;
					case 'maxTrashcanContents':
	                    options.maxTrashcanContents = val;
						break;
					case 'zoom':
	                    options.zoom = val;
						break;
					case 'renderer':
	                    options.renderer = val;
						break;
					default:
					    break;
				}
			}
		}

		var div = document.createElement('div');
		div.setAttribute("id", "blocklyDiv");
		if(resizable){
			div.setAttribute("style", "position: absolute");
		} else {
			div.setAttribute("style", "height:" + height + "; width:" + width);
		}
		attach(div);

        // Create Blockly		
		var workspace = Blockly.inject('blocklyDiv', options);
		workspaces[id] = workspace;
		
		// Salix
		var myHandlers = {};		
		
		for (var key in events) {
			if (events.hasOwnProperty(key)) {
				var handler = salix.getNativeHandler(events[key]);
				myHandlers[key] = handler;
				workspace.addChangeListener(handler);
			}	
		}

        // Salix
        function patch(edits, attach){
	      edits = edits || [];

		  // Salix
          for (var i = 0; i < edits.length; i++){
		    var edit = edits[i];
		    var type = salix.nodeType(edit);
			
			//Salix	
			switch (type) {
			  default:
			    throw 'unsupported edit: ' + JSON.stringify(edit);
			}
          }
        }
		
		//Salix
		div.salix_native = {patch: patch};
		return div;
	}
	
	//Salix
	salix.registerNative('blockly', myBlockly);
};