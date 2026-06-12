tool
extends VisualScriptCustomNode

func _get_caption():
	return "Change State"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_INT

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "State"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	inputs[0].set("new_state", inputs[1])
	return 0
