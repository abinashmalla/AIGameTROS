tool
extends VisualScriptCustomNode

func _get_caption():
	return "State Finished?"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_BOOL

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "Skip?"

func _has_input_sequence_port():
	return true
	
func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "Unfinished"
		1:
			return "Finished"

func _step(inputs,outputs,start_mode,working_mem):
	var finished:bool = inputs[0].get("action_end")
	var stop_action:bool = inputs[0].get("stop_action")
	var State:int = inputs[0].get("State")
	var skip:bool = inputs[1]
	
	var is_except_State:bool = false
	if(skip && inputs[0].STATE_INFO.get(State).has("skip")):
		is_except_State = true
	
	if(stop_action):
		inputs[0].set("stop_action",false)
		return 1
	elif(finished || is_except_State):
		return 1
	else:
		return 0
