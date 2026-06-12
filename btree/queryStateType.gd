tool
extends VisualScriptCustomNode

func _get_caption():
	return "State Type?"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_STRING

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "Type"

func _has_input_sequence_port():
	return true
	
func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "Yes"
		1:
			return "No"

func _step(inputs,outputs,start_mode,working_mem):
	var State:int = inputs[0].get("State")
	var type:String = inputs[1]
	
	if(inputs[0].STATE_INFO.get(State).has(type)):
		return 0
	else:
		return 1
