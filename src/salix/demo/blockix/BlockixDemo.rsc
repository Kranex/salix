@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::blockix::BlockixDemo

import salix::demo::blockix::StateMachineAST;
import salix::demo::blockix::Node2AST;
import salix::demo::blockix::AST2Text;

import salix::App;
import salix::HTML;
import salix::Core;
import lang::xml::DOM;
import salix::lib::Blockix;
import String;
import IO;
import List;

// inits the app
SalixApp[Model] blockixApp(str id = "blockixDemo") = makeApp(id, init, view, update, parser = salix::lib::Blockix::parseMsg);


// inits the app
App[Model] blockixWebApp() 
  = webApp(
      blockixApp(),
      index = |project://salix/src/salix/demo/blockix/index.html|, 
      static = |project://salix/src|
    ); 

// the model for the IDE.
alias Model = tuple[
  str src,
  bool afterTransitions,
  int symbol
];

list[str] symbols = ["=\>", "=?\>"];
  
// init the IDE  
Model init() {
  Model model = <"", false, 0>;
  
  // init the model with the doors state machine.
  model.src = workspace();
  return model;
}


// The doors state machine.
str workspace() = "Start using blockix and your code will be generated here!";

data Msg
  = changeSymbol()
  | toggleAfterTransitions()
  | blockixChange(str text);
  


// update the model with from the msg.
Model update(Msg msg, Model model) {
  
  switch (msg) {
    // update from blockix
    case blockixChange(str text): {
       println(xmlPretty(parseXMLDOM(text)));
       model.src = ast2text(node2ast(parseXMLDOM(text)));
    }
    case changeSymbol():
        model.symbol = (model.symbol + 1) % size(symbols);  
    case toggleAfterTransitions():
        model.afterTransitions = !model.afterTransitions;  
    
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
    div(class("row"), (){
      div(class("col"), (){
        button(onClick(changeSymbol()), "Change Symbol");
      });
      div(class("col"), (){
        button(
          onClick(toggleAfterTransitions()), 
          "After Transitions: <(model.afterTransitions ? "enabled" : "disabled")>"
         );
      });
      div(class("col"), "<model.symbol>");
    });
    div(class("row"), () {
      div(class("col-md-8"), () {
        h4("Edit");
        blockix("myBlockix", salix::lib::Blockix::onChange(Msg::blockixChange), () {
          /*category("my category", hue(120), expanded(true), () {
        	  block("my_block", hue(40), nextStatement(), previousStatement(), () {
        	    message("My Block!");
        	    message("%1", () {
        	      inputStatement("STATEMENT");  
        	    });
        	  });
        	});*/
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
        		block("state_declaration",
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
        				message("%1 <symbols[model.symbol]> %2", () {
        					inputValue("EVENT", check = ["Event"]);
        					inputValue("STATE", check = ["State"]);        					
        				});
        			}
        		);
            if(model.afterTransitions) {
              block("transition_after",
                hue(180),
                nextStatement(),
                previousStatement(),
                inputsInline(true),
                () {
                  message("after %1, %2 <symbols[model.symbol]> %3", (){
                    fieldNumber("AFTER", val = 0);
                    inputValue("EVENT", check = ["Event"]);
                    inputValue("STATE", check = ["State"]);        					
                  });
                }
              );
        		};
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
