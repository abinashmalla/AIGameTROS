tool
extends VisualScriptCustomNode

func _get_caption():
	return "Receive State Info"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	return TYPE_OBJECT

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Source"
		1:
			return "Self"

func _has_input_sequence_port():
	return true

func _step(inputs,outputs,start_mode,working_mem):
	inputs[1].set("STATE_INFO", inputs[0].get("STATE_INFO"))
	return 0
