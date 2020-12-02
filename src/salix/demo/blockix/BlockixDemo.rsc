@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::blockix::BlockixDemo

import salix::App;
import salix::HTML;
import salix::Core;
import lang::xml::DOM;
import salix::lib::Blockix;
import String;
import IO;

// inits the app
SalixApp[Model] blockixApp(str id = "blockixDemo") = makeApp(id, init, view, update, parser = parseMsg);


void main() {
  println(output);
}

// inits the app
App[Model] blockixWebApp() 
  = webApp(
      blockixApp(),
      index = |project://salix-kranex/src/salix/demo/blockix/index.html|, 
      static = |project://salix-kranex/src|
    ); 

// the model for the IDE.
alias Model = tuple[
  str src
];
  
// init the IDE  
Model init() {
  Model model = <"">;
  
  // init the model with the doors state machine.
  model.src = workspace();
  return model;
}


// The doors state machine.
str workspace() = "Start using blockix and your code will be generated here!";

str data2state(Node \data){
	if (charData(txt) := \data) return txt;
	return "ERROR: NOT CHAR DATA";	
}

str event2state(Node event) {
	str name = [nm | charData(nm) <- event.children][0];
	return "<name> <toUpperCase(name)>";	
} 


list[Node] getAttributes(Node element) = [attr | attr <- element.children, attribute(_,_,_) := attr];
list[Node] getElements(Node element) = getElements(element.children);
list[Node] getElements(list[Node] children) = [elm | elm <- children, element(_,_,_) := elm];
list[Node] getElementsByType(str \type, list[Node] children) = [elm | elm <- children, getAttribute("type", elm) == \type];

str getAttribute(str name, Node element) = getAttribute(name, element.children);
str getAttribute(str name, list[Node] children) {
	for (child <- children) {
 		if (attribute(_, name, val) := child) {
 			return val;
 		}
	}
	return "";
} 


Node getElement(str name, Node element) = getElement(name, element.children);
Node getElement(str name, list[Node] children) {
	for (child <- children) {
 		if (element(_, name, _) := child) {
 			return child;
 		}
	}
	return comment("NULL");
} 

str getData(Node element) {
	for (child <- element.children) {
		if (charData(dat) := child) {
			return dat;
		}
	}
	return "NULL";	
}

str getValue(str name, list[Node] children) {
	for(child <- children) {
		switch(child){
			case element(_, "value", block): 
				if (getAttribute("name", child) == name) {
						return getValue(name, block);
				}
			case element(_, "block", _):
				return getData(getElement("field", child));
		}
	}
	return "NULL";
}

str block2state(str name, list[Node] children) {
	switch(name) {
		case "event":
			return "<getData(getElement("field", children))>";	
		case "state_declaration":
			return "state <getValue("STATE", getElements(children))><node2state(getElement("statement", children))>
			       'end";	
		case "state":
			return "<getData(getElement("field", children))>";	
		case "transition":
			return "
				   '  <getValue("EVENT", getElements(children))> =\> <getValue("STATE", getElements(children))><node2state(getElement("next", children))>";	
	}
	return "";
}

str element2state(str name, list[Node] children) {
	switch(name) {
		case "xml": 	return "<for(child <- [c | c <- [getElement("variables", children )] + getElementsByType("state_declaration", children)]){>
							   '<node2state(child)>
							   '<}>";
							   
		case "variables": 	return "events<for(child <- [c | c <- children, any(a <- c.children, attribute(_,"type", "Event") := a)]){>
				   				   '  <event2state(child)><}>
				   				   'end";
		case "block":		return block2state(getAttribute("type", children), getElements(children));
		case "value":		return "";
		case "statement":	return "<for(child <- getElements(children)){><node2state(child)><}>";
		case "field":		return "";
		case "next":		return "<for(child <- getElements(children)){><node2state(child)><}>";

	}
	return "";
}

str node2state(Node \node) {	
	switch(\node) {
		case document(root):
			return node2state(root);
	    case element(_, name, children):
	    	return element2state(name, children);
		case charData(\data):
			return "<\data>";
	}
	
	return "";
}

data Msg
  = blocklyChange(str text);
  
// update the model with from the msg.
Model update(Msg msg, Model model) {

  switch (msg) {
    // update from blockly
    case blocklyChange(str text): model.src = node2state(parseXMLDOM(text));
  }
  return model;
}

// render the IDE.
void view(Model model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple live Blockix IDE demo");
	    });
    });
    
    div(class("row"), () {
      div(class("col-md-8"), () {
        h4("Edit");
        blockly("myBlockix", onChange(Msg::blocklyChange), () {
        	category("Event", hue(0), () {
        		block("event",
        			hue(0),
 					salix::lib::Blockix::output("Event"),
 					inputsInline(true),
        			() {
        				message("%1", () {
        					fieldVariable("ID", variableTypes = ["Event"], defaultType = "Event");
        				});
        			}
        		);
        	});
        	category("State", hue(180), () {
        		block("state_seclaration",
        			hue(180),
        			inputsInline(true),
        			() {
        				message("state %1", () {
        					inputValue("STATE", check = ["State"]);
        				});
        				message("%1", () {
        					inputStatement("TRANSITIONS");
        				});
        			}
        		);
        		block("transition",
        			hue(180),
        			nextStatement(),
        			previousStatement(),
        			inputsInline(true),
        			() {
        				message("%1 =\> %2", () {
        					inputValue("EVENT", check = ["Event"]);
        					inputValue("STATE", check = ["State"]);        					
        				});
        			}
        		);
        		block("state",
        			hue(180),
 					salix::lib::Blockix::output("State"),
 					inputsInline(true),
        			() {
        				message("%1", () {
        					fieldVariable("ID", variableTypes = ["State"], defaultType = "State");
        				});
        			}
        		);
        	});
        });
      });
        
      div(class("col-md-4"), () {
        h4("xml");
      	pre(class("prettyprint"), model.src);
      });
    });
  });
}
