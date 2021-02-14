@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::blockix::BlockixPatchDemo

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
  Node src,
  bool showC
];

  
// init the IDE  
Model init() {
  Model model = < document(comment("none")), false>;
  
  // init the model with the doors state machine.
  return model;
}


// The doors state machine.
str workspace() = "Start using blockix and your code will be generated here!";

data Msg
  = toggleShow()
  | atob()
  | blockixChange(str text);
  

Node replaceAwithB(Node nd) {
  switch(nd){
    case document(root):
      return document(replaceAwithB(root));
    case element(ns, name, children):
      return element(ns, name, [replaceAwithB(child) | child <- children]);
    case attribute(ns, "type", "A"):
      return attribute(ns, "type", "B");
    default:
      return nd;
  };
}

Node store = document(comment("none"));

// update the model with from the msg.
Model update(Msg msg, Model model) {
  
  switch (msg) {
    // update from blockix
    case blockixChange(str text): {
       store = parseXMLDOM(text);
       println(xmlPretty(store));
    }
    case toggleShow(): {
      model.showC = !model.showC;
      print("show: " + (model.showC ? "true" : "false"));
    }
    case atob(): {
      model.src = replaceAwithB(store);
      println(xmlPretty(model.src));
    }
  }
  return model;
}

// render the IDE.
void view(Model model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple Patch Blockix IDE demo");
	    });
    });
    div(class("row"), (){
      div(class("col"), (){
        button(onClick(toggleShow()), model.showC ? "Hide C" : "Show C");
      });
      div(class("col"), (){
        button(onClick(atob()), "replace As with Bs");
      });
    });
    div(class("row"), () {
      div(class("col-md-8"), () {
        h4("Edit");
        blockix("myBlockix", workspace(model.src), salix::lib::Blockix::onChange(Msg::blockixChange), () {
        	category("Blocks", hue(0), () {
            block("A", salix::lib::Blockix::output("A"), () {
                message("A");
            });
            block("B", salix::lib::Blockix::output("B"), () {
                message("B");
            });
            if(model.showC) {
              block("C", salix::lib::Blockix::output("C"), () {
                  message("C");
              });
            };
          });
        });
      });
    });
  });
}
