tool
extends VisualScriptCustomNode

func _get_caption():
	return "Set Var"

func _get_input_value_port_count():
	return 3

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_STRING
		2:
			return TYPE_NIL

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Destination"
		1:
			return "Var"
		2:
			return "Value"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	inputs[0].set(inputs[1], inputs[2])
	return 0
