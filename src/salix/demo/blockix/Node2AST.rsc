module salix::demo::blockix::Node2AST

import salix::demo::blockix::StateMachineAST;
import salix::demo::blockix::StateMachine;

import lang::xml::DOM;
import String;
import List;

list[Node] getAttributes(Node element) = [attr | attr <- element.children, attribute(_,_,_) := attr];

str getAttribute(str name, Node element) = getAttribute(name, element.children);
str getAttribute(str name, list[Node] children) {
  for (child <- children) {
    if (attribute(_, name, val) := child) {
      return val;
    }
  }
  return "";
} 

list[Node] getElements(Node element) = getElements(element.children);
list[Node] getElements(list[Node] children) = [elm | elm <- children, element(_,_,_) := elm];
list[Node] getElementsByType(str \type, Node element) = getElementsByType(\type, element.children);
list[Node] getElementsByType(str \type, list[Node] children) = [elm | elm <- children, getAttribute("type", elm) == \type];

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

AController node2ast(Node \node) {
  switch (\node) {
    case document(root):
      return node2ast(root);
    case element(_, "xml", children):
      return controller(
               events2ast(children),
               resets2ast(children),
               commands2ast(children),
               states2ast(children)
             );
  }
  return controller([],[],[], []);
}

list[AEvent] events2ast(list[Node] children)
  = [event2ast(event) | event <- getElementsByType("Event", getElement("variables", children))];

AEvent event2ast(Node evnt) {
 str name = [nm | charData(nm) <- evnt.children][0];
 return event(id(name), id(toUpperCase(name)));
}

list[AId] resets2ast(list[Node] children) {
   // we're only working with a basic state machine, so we're skipping resets.
   return [];
}

list[ACommand] commands2ast(list[Node] children) {
   // we're only working with a basic state machine, so we're skipping commands.
   return [];
}

list[AState] states2ast (list[Node] children)
   = [state2ast(state) | state <- getElementsByType("state_declaration", children)];

/*
  block stateDeclaration:
    statement:
      block transition:
        next:
          block transition:
           next: ...
*/
 
AState state2ast(Node stateDeclaration) {
  str name = getValue("STATE", getElements(stateDeclaration));
  list[Node] transitions = getElementsByType("transition", getElement("statement", stateDeclaration));
 
  return state(id("<name>"), [], transitions2ast(transitions));
} 

list[ATransition] transitions2ast(list[Node] transition) {
  list[ATransition] transitions = [transition2ast(t) | t <- transition];
  
  for(t <- transition) {
    transitions += transitions2ast(getElementsByType("transition", getElement("next", t)));
  }
  
  return transitions;
}

ATransition transition2ast(Node transition) {
    str event = getValue("EVENT", transition.children);
    str state = getValue("State", transition.children);
    return salix::demo::blockix::StateMachineAST::transition(id(event), id(state));
}


