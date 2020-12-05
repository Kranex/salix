module salix::demo::blockix::StateMachineAST

data AId(loc src = |tmp:///|)
  = id(str name);
  
data ANat(loc src = |tmp:///|)
  = nat(int i);

data AController(loc src = |tmp:///|)
  = controller(
      list[AEvent] events,
      list[AId] resetEvents,
      list[ACommand] commands,
      list[AState] states);


data ACommand(loc src = |tmp:///|)
  = ACommand(AId name, AId token); 

data AEvent(loc src = |tmp:///|)
  = event(AId name, AId token); 

data AState(loc src = |tmp:///|)
  = state(AId name, list[AAction] actions, list[ATransition] transitions);
  
 data AAction(loc src = |tmp:///|)
  = action(AId id);

 data ATransition(loc src = |tmp:///|)
  = transition(AId event, AId state)
  | transitionAfter(ANat number, AId event, AId state);