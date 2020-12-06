module salix::demo::blockix::AST2Text

import salix::demo::blockix::StateMachineAST;

str ast2text(AController machine)
  = events2text(machine.events) + states2text(machine.states);

str events2text(list[AEvent] events)
  = "events
    '<for(event <- events){><event2text(event)>
    '<}>end";
    
str event2text(AEvent event)
  = "<event.name.id> <event.token.id>";
  
str states2text(list[AState] states)
  = "<for(state <- states){>
    '
    '<state2text(state)><}>";

str state2text(AState state)
  = "state <state.name.id>
    '<for(transition <- state.transitions){><transition2text(transition)>
    '<}>end";
    
str transition2text(ATransition transition)
  = "<transition.event.id> =\> <transition.state.id>";
