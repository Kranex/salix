module salix::lib::Blockix

import salix::Node;
import lang::xml::DOM;
import salix::Core;
import IO;
import Map;
import List;
import String;


Attr onChange(Msg(str) msg) = event("change", handler("blockixChange", encode(msg)));

Msg parseMsg(str id, "blockixChange", Handle h, map[str, str] p) 
 = applyMaps(id, h, decode(id, h.id, #Msg(str))(p["msg"]));

Attr resizable(bool val) = prop("resizable", "<val>");
Attr width(str val) = prop("width", "<val>");
Attr height(str val) = prop("height", "<val>");


// Blockly injection options. See: https://developers.google.com/blockly/guides/configure/web/configuration_struct
Attr collapse(bool val) = prop("collapse", "<val>");
Attr comments(bool val) = prop("comments", "<val>");
Attr css(bool val) = prop("css", "<val>");
Attr disable(bool val) = prop("disable", "<val>");
//Attr grid(Object obj) = prop("grid", "<obj>");
Attr horizontalLayout(bool val) = prop("horizontalLayout", "<val>");
Attr maxBlocks(int val) = prop("maxBlocks", "<val>");
//Attr maxInstances(Object obj) = prop("maxInstances", "<obj>");
Attr media(str val) = prop("media", "<val>");
//Attr move(Object obj) = prop("move", "<obj>");
Attr oneBasedIndex(bool val) = prop("oneBasedIndex", "<val>");
Attr readOnly(bool val) = prop("readOnly", "<val>");
Attr rtl(bool val) = prop("rtl", "<val>");
Attr scrollbars(bool val) = prop("scrollbars", "<val>");
Attr sounds(bool val) = prop("sounds", "<val>");
Attr toolboxPosition(str val) = prop("toolboxPosition", "<val>");
Attr trashcan(bool val) = prop("trashcan", "<val>");
Attr maxTrashcanContents(int val) = prop("maxTrashcanContents", "<val>");
//Attr zoom(Object obj) = prop("zoom", "<obj>");
Attr renderer(str val) = prop("renderer", "<val>");

// ---- 

// definition

// Definition for the internal Toolbox/Workspace/Block representation (the omnibox).
private data _Element
	// TOOLBOX
	= _toolbox(list[_Element] elements = [])
	| _category(map[str, str] attrs, list[_Element] elements = [])
	| _separator(map[str, str] attrs)
	| _block(map[str,str] attrs , list[_Element] messages = [], list[_Element] elements = [])
	| _shadow(map[str,str] attrs, list[_Element] messages = [], list[_Element] elements = [])
	| _value(map[str,str] attrs, list[_Element] elements = [])
	| _field(map[str,str] attrs)
	| _button(map[str,str] attrs)
	| _label(map[str,str] attrs)
	// BLOCK DEF
	| _message(str msg, list[_Element] elements = []) // elements are arguments
	| _argument(str \type, map[str,value] params); // elements are special arguments for the field/value
	
data Param = param(str name, value val);

Param angle(int val) = param("angle", val);
Param checked(bool val) = param("checked", val);
Param color(str val) = param("colour", val); // Not gonna use colour. See Attr hue().
Param colorOptions(list[str] val) = param("colorOptions", val);
Param colorTitles(list[str] val) = param("colorTitles", val);
Param columns(int val) = param("columns", val);
Param check(list[str] val) = param("check", val);
Param options(lrel[str, str] val) = param("options", val);
// TODO IMAGES FOR OPTIONS. 
Param src(str val) = param("src", val);
Param width(int val) = param("width", val);
Param height(int val) = param("height", val);
Param alt(str val) = param("alt", val);
Param text(str val) = param("text", val);
Param \value(int val) = param("value", val);
Param date(datetime val) = param("date", val.justDate);
Param text(str val) = param("text", val);
Param spellcheck(bool val) = param("spellcheck", val);

data Option = item(str name, str text)
			| image(str name, str src, int width, int height, str alt = "");
data Nothing = none(); 

// Attributes for the configuration of the internal omnibox.
// Toolbox def
Attr \type(str val) = attr("type", val);
Attr disabled(bool val) = attr("disabled", "<( val ? val : "")>");
Attr expanded(bool val) = attr("expanded", "<(!val ? val : "")>");
Attr hue(int val) = attr("colour", "<((val >= 0 && val <= 360) ? val : "")>"); // I may be English but I hate the use of 'colour' and other British English in computing science. I will use the word hue because that's the only thing the "colour" attribute can set.  
Attr custom(str val) = attr("custom", val);
Attr categoryStyle(str val) = attr("categorystyle", val);
Attr gap(int val) = attr("gap", "<((val >= 0 && val <= 360) ? val : "")>");
Attr id(str val) = attr("id", val);
// Block def
Attr tooltip(str val) = attr("tooltip", val);
Attr helpUrl(str val) = attr("helpUrl", val);
Attr webClass(str val) = attr("web-class", val);
Attr nextStatement(str val = "") = attr("nextStatement", val);
Attr previousStatement(str val = "") = attr("previousStatement", val);
Attr output(str val) = attr("output", val);
Attr inputsInline(bool val) = attr("inputsInline", "<val>");

// compile

// Conversion of the attr map to attributes, but only for the ones that we want. 
list[Node] attrs2xml(list[str] keys, map[str, str] attrs) {
	list[Node] ats = [];
	
	for (k <- keys){
		if ( k in attrs && attrs[k] != "" ){
			ats += [attribute(k, attrs[k])];
		};
	};
	
	return ats;
} 

// Conversion of an Omnibox element to an XML element for the toolbox.
list[Node] element2xml(_Element elmnt) {
	switch(elmnt) {
		case _category(map[str, str] attrs):
			return [element("category", attrs2xml(["name", "colour", "custom", "categoryStyle", "expanded"], attrs) + [ w | [w] <- [element2xml(e) | e <-elmnt.elements]])];
		case _separator(map[str, str] attrs):
			return [element("sep", attrs2xml(["gap"], attrs))];
		case _block(map[str, str] attrs):
			return [element("block", attrs2xml(["type", "colour", "disabled"], attrs) + [ w | [w] <- [element2xml(e) | e <-elmnt.elements]])];
		case _shadow(map[str, str] attrs):
			return [element("shadow", attrs2xml(["name", "type", "colour", "disabled"], attrs) + [ w | [w] <- [element2xml(e) | e <-elmnt.elements]])];
		case _value(map[str, str] attrs):
			return [element("value", attrs2xml(["name"], attrs) + [ w | [w] <- [element2xml(e) | e <-elmnt.elements]])];
		case _field(map[str, str] attrs):
			return [element("field", attrs2xml(["name", "value", "id", "type"], attrs))];
		case _button(map[str, str] attrs):
			return [element("button", attrs2xml(["name", "callbackKey", "web-class"], attrs))];
		case _label(map[str, str] attrs):
			return [element("label", attrs2xml(["name", "web-class"], attrs))];
		default:
			return [];
	}
}

// Conversion of an Omnibox to an XML DOM for the toolbox.
Node toolbox2xml(_Element tbox) =
	document(element("xml", [w | [w] <- [element2xml(e) | e <- tbox.elements]]));

map[str, value] attrs2json(list[str] keys, map[str, str] attrs) = (key:key | key <- keys) o attrs;

list[map[str, value]] args2json(list[_Element] args) = [("type": arg.\type) + arg.params | arg <- args] ;

map[str, value] block2json(_Element block) {
	map[str, value] def = ();
	int msgCount = 0;
	
	def += attrs2json(["type", "colour", "helpUrl", "tooltip", "nextStatement", "previousStatement", "output", "inputsInline"], block.attrs);
	
	for( msg <- block.messages) {
		def += ("message<msgCount>": "<msg.msg>");
		if(size(msg.elements) > 0){
			def += ("args<msgCount>": args2json(msg.elements));
		};
		msgCount += 1;
	};
	return def;
}

list[map[str,value]] toolbox2json(_Element tbox) {
	list[map[str, value]] blocks = [];
	for(_Element e <- tbox.elements){
		switch(e){
			case _category(_):
				blocks += toolbox2json(e);
			case _block(_):
				blocks += [block2json(e)];
		}
	};
	return blocks;
}	
// --

// construct

// The stack of the omnibox.
private list[_Element] stack = [_toolbox()];

// The top of the stack.
private _Element top() = stack[-1];

// push to the stack.
private void push(_Element e) {
	stack += [e];
}

// pop off the stack.
private _Element pop() {
	_Element e = top();
	stack = stack[0..-1];
	return e;
}

// Add all the children in the sub-closure (if there is one).
private _Element addChildren(_Element cur, list[value] vals){
	if(vals != [], void () blk := vals[-1]){
		push(cur);
		blk();
		cur = pop();
	}
	
	return cur;
}

// Add the element to it's parent. 
private void addToParent(_Element element) {
	if(_message(_) := element){
		stack = stack[0..-1] + stack [-1][messages = stack[-1].messages + [element]];	
	} else {
		stack = stack[0..-1] + stack [-1][elements = stack[-1].elements + [element]];	
	}
}

private map[str,str] getAttrs(list[value] vals) = (k: v | attr(str k, str v) <- vals);
private map[str,value] getParams(list[value] vals) = (k: v | param(str k, value v) <- vals);

// the closure for a category.
void category(str name, value vals...){
	_Element cur = addChildren(_category(getAttrs(vals)), vals);
	cur.attrs["name"] = name;
	addToParent(cur);	
}

// the closure for a separator.
void separator(value vals...) = addToParent(_separator(getAttrs(vals)));

// the closure for a block.
void block(str \type, value vals...){
	_Element cur = addChildren(_block(getAttrs(vals)), vals);
	cur.attrs["type"] = \type;
	addToParent(cur);
}

// the closure for a shadow block.
void shadow(str name, value vals...){
	_Element cur = addChildren(_shadow(getAttrs(vals)), vals);
	cur.attrs["name"] = name;
	addToParent(cur);
}

void message(str msg, value vals...) = addToParent(addChildren(_message(msg), vals));

void argument(str name, str \type, value vals...) = addToParent(_argument(\type, ("name": name) + getParams(vals)));

void inputValue(str name, list[str] check = []) = addToParent(_argument("input_value", ("name" : name) + (check == [] ? () : ("check": check))));
void inputStatement(str name, list[str] check = []) = addToParent(_argument("input_statement", ("name": name, "check": check)));
void inputDummy() = addToParent(_argument("input_dummy", ()));

void fieldInput(str name, str text = "", bool spellcheck = false)
	= addToParent(_argument("field_input", ("name": name, "text": text, "spellcheck": spellcheck)));
	
void fieldDropdown(str name, list[Option] options){
	lrel[value, str] opts = [];
	for(opt <-options){
		switch(opt){
			case item(str name, str text):
				opts += <text, name>;
			case image(str name, str src, int width, int height):
				opts += <("src": src, "width": width, "height": height, "alt": opt.alt), name>;
		};
	};
	println(name);
	addToParent(_argument("field_dropdown", ("name": name, "options": opts)));
}

void fieldCheckbox(str name, bool checked = false)
	= addToParent(_argument("field_checkbox", ("name": name, "checked": checked)));
	
void fieldColor(str name, str color = "", list[str] colorOptions = [], list[str] colorTitles = [], int columns = 0)
	= addToParent(_argument("field_colour", ("name": name, "colour": color, "colourOptions": colorOptions, "colourTitles": colorTitles, "columns": columns)));
	
void fieldNumber(str name, num val = 0, value min = none(), value max = none(), value precision = none()) {
	map[str, value] params = ("name": name, "value": val);
	
	if(num val := min){
		params += ("min": val);
	}	
	
	if(num val := max){
		params += ("max": val);
	}
	
	if(num val := precision){
		params += ("precision": val);
	}
	
	addToParent(_argument("field_number", params));
}

void fieldAngle(str name, num angle = 0)
	= addToParent(_argument("field_angle", ("name": name, "angle": angle)));
	
void fieldVariable(str name, str variable = "", list[str] variableTypes = [], str defaultType = "") {
	map[str, value] params = ("name": name);
	
	if(variable != "") {
		params += ("variable": variable);
	}
	if(variableTypes != []) {
		params += ("variableTypes": variableTypes);
	}
	if(defaultType != "") {
		params += ("defaultType": defaultType);
	}
	
	addToParent(_argument("field_variable", params));
}

void fieldDate(str name, value date = none())
	= addToParent(_argument("field_date", ("name": name) + ("date": d.justDate | datetime d := date)));

void fieldLabel(str text)
	= addToParent(_argument("field_label", ("text": text)));
	
void fieldLabelSerializable(str name, str text)
	= addToParent(_argument("field_label_serializable", ("name": name, "text": text)));
	
void fieldImage(str src, int width, int height, str alt = "")
	= addToParent(_argument("field_image", ("src": src, "width": width, "height": height, "alt": alt)));

// the closure for a value.
void \value(str name, value vals...) = addToParent(addChildren(_value(("name": name)), vals));

// the closure for a field.
void field(str name, value val, value vals...){
	_Element cur = _field(getAttrs(vals));
	cur.attrs["name"] = name;
	cur.attrs["value"] = val;
	addToParent(cur);
}

// the closure for a button.
void button(str text, str callbackKey, value vals...){
	_Element cur = _button(getAttrs(vals));
	cur.attrs["name"] = text;
	cur.attrs["callbackKey"] = callbackKey;
	addToParent(cur);
}

// the closure for a label.
void label(str text, value vals...){
	_Element cur = _label(getAttrs(vals));
	cur.attrs["name"] = text;
	addToParent(cur);
}

void blockix(str id, value vals...){

	// if a omnibox is supplied as a closure, construct the omnibox using black magic.	
	if( vals != [], void() T := vals[-1]) {
		stack = [_toolbox()];
		T();
	}
  
  	build(vals[0..-1], Node(list[Node] _, list[Attr] attrs){
    	return native("blockix", id, attrsOf(attrs), propsOf(attrs), eventsOf(attrs), extra = ("toolbox": xmlPretty(toolbox2xml(stack[0])), "blocks" : toolbox2json(stack[0])));
  	});
}