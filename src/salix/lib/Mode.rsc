module lib::Mode

import Type;
import ParseTree;

data Mode
  = mode(str name, list[State] states, map[str, value] meta = ());
  
data State
  = state(str name, list[Rule] rules)
  ;
  
data Rule
  = rule(str regex, list[str] tokens, str next = "", bool indent=false, bool dedent=false)
  ;
  
str cat2token("StringLiteral") = "string";
str cat2token("Comment") = "comment";
str cat2token("Constant") = "atom";
str cat2token("Variable") = "variable";
str cat2token(str _) = "unknown";


Mode grammar2mode(str name, type[&T <: Tree] sym) {
  defs = sym.definitions;
  
  str reEsc(str c) = c in {"*", "\\", "+", "?", "|"} ? "\\<c>" : c;
  
  set[str] lits = { x | /lit(x:/^[a-zA-Z0-9_]*$/) := defs };
  set[str] ops 
    = { x | /prod(_, [_, _, lit(x:/^[+\-\<\>=!@#%^&*~\/|]*$/), _, _], ts) := defs, !any(\tag("category"("Comment")) <-  ts)}
    + { x | /prod(_, [lit(x:/^[+\-\<\>=!@#%^&*~\/|]*$/), _, _], ts) := defs, !any(\tag("category"("Comment")) <-  ts) }
    + { x | /prod(_, [_, _, lit(x:/^[+\-\<\>=!@#%^&*~\/|]*$/)], ts) := defs, !any(\tag("category"("Comment")) <-  ts) };

  // todo: sort by length, longest first.
  kwRule = rule("(?:<intercalate("|", [ l | l <- lits ])>)\\b", ["keyword"]);   
  opRule = rule("(?:<intercalate("|", [ reEsc(l) | l <- ops ])>)\\b", ["operator"]);
     
  return mode(name, [state("start", [kwRule, opRule])]);
}  
  
  
Mode jsExample() = mode("javascript", [  
  state("start", [
    rule("\"(?:[^\\]|\\.)*?(?:\"|$)", ["string"]),

    rule("(function)(\\s+)([a-z$][\\w$]*)", ["keyword", "", "variable-2"]),

    rule("(?:function|var|return|if|for|while|else|do|this)\\b", ["keyword"]),

    rule("true|false|null|undefined", ["atom"]),

    rule("0x[a-f\\d]+|[-+]?(?:\\.\\d+|\\d+\\.?\\d*)(?:e[-+]?\\d+)?", ["number"]),

    rule("//.*", ["comment"]),

    rule("/(?:[^\\\\]|\\\\.)*?/", ["variable-3"]),

    rule("/\\*", ["comment"], next = "comment"),

    rule("[-+/*=\<\>!]+", ["operator"]),

    rule("[\\{\\[\\(]", [], indent = true),

    rule("[\\)\\]\\)]", [], dedent = true),

    rule("[a-z$][\\w$]*", ["variable"])
  ]),
  state("comment", [
    rule(".*?\\*/", ["comment"], next = "start"),
    rule(".*", ["comment"])
  ])
 ], meta = ("dontIndentStates": ["comment"], "lineComment": "//")
);  