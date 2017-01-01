

function registerCodeMirror(elmer) {
	
	function dec2handler(decoder) {
		switch (elmer.nodeType(decoder)) {
		
		case 'codeMirrorChange':
			return function (editor, change) {
				elmer.scheduleEvent(decoder.codeMirrorChange.handle.handle,  {
					type: 'codeMirrorChange', 
					fromLine: change.from.line, fromCol: change.from.ch,
					toLine: change.to.line, toCol: change.to.ch,
					text: change.text.join('\n'),
					removed: change.removed.join("\n")
				});
			};
			
		case 'cusorActivity':
			return function (editor) {
				var position = editor.getCursor();
				var line = position.line;
				var token = editor.getTokenAt(position);
				elmer.scheduleEvent(decoder.cursorActivity.handle.handle, 
					{type: 'cursorActivity', line: line, start: token.start, 
					end: token.end, string: token.string, tokenType: token.type});
			};
		
		}
	}
	
	function codeMirror(parent, props, events) {
		var cm = CodeMirror(parent, {});
		// for remove event.
		var myHandlers = {};
		

		for (var key in props) {
			// todo: this logic is shared with setProp
			if (props.hasOwnProperty(key)) {
				var val = props[key];
				
				if (key === 'value') {
					cm.getDoc().setValue(val);
				}
				if (key == 'width') {
					cm.setSize(val, null);
				}
				else if (key === 'height') {
					cm.setSize(null, val);
				}
				else if (key === 'style') {
					cm.getWrapperElement().style = val;
				}
				else if (key === 'simpleMode') {
					// do defineSimpleMode
				}
				else {
					cm.setOption(key, val);
				}
			}
		}
		
		for (var key in events) {
			// TODO: shared with setEvent
			if (events.hasOwnProperty(key)) {
				var handler = dec2handler(events[key]);
				myHandlers[key] = handler;
				cm.on(key, handler);
			}
		}

		setTimeout(function() {
            cm.refresh();
        }, 100);
		
		
		function patch(edits) {
			edits = edits || [];

			for (var i = 0; i < edits.length; i++) {
				var edit = edits[i];
				var type = elmer.nodeType(edit);

				switch (type) {
				
				case 'replace':
					return elmer.build(edit[type].html);

				case 'setProp': 
					var key = edit[type].name;
					var val = edit[type].val;
					if (key === 'value') {
						if (cm.getValue() !== val) {
							var hasChange = myHandlers.hasOwnProperty('change');
							if (hasChange) { 
								cm.off('change', myHandlers.change);	
							}
							cm.setValue(val);
							if (hasChange) {
								cm.on('change', myHandlers.change);
							}
						}
					}
					else if (key === 'width') {
						cm.setSize(val, null);
					}
					else if (key === 'height') {
						cm.setSize(null, val);
					}
					else if (key === 'style') {
						cm.getWrapperElement().style = val;
					}
					else {
						cm.setOption(key, val);
					}
					break;
					
				case 'setEvent': 
					var key = edit[type].name;
					var handler = dec2handler(edit[type].handler);
					myHandlers[key] = handler;
					cm.on(key, handler);
					break
				
				case 'removeProp':
					var key = edit[type].name;
					if (key === 'width' || key === 'height') {
						// doesn't actually revert it.
						cm.setSize(null, null);
					}
					else if (key === 'style') {
						cm.getWrapperElement().style = '';
					}
					else {
						cm.setOption(key, CodeMirror.defaults[key]);
					}
					break;
					
				case 'removeEvent':
					var key = edit[type].name
					cm.off(key, myHandlers[key]);
					delete myHandlers[key];
					break;
					
				default: 
					throw 'unsupported edit: ' + JSON.stringify(edit);
					
				}
			}
		}
		
		var dom = cm.getWrapperElement();
		dom.elmer_native = {patch: patch};
		return dom;
	}
	
	elmer.registerNative('codeMirror', codeMirror);
};