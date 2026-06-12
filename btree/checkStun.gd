tool
extends VisualScriptCustomNode

func _get_caption():
	return "Stun?"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
	return TYPE_OBJECT

func _get_input_value_port_name(idx):
	return "Self"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "No"
		1:
			return "Yes"

func _step(inputs,outputs,start_mode,working_mem):
	var stun_opp:float = inputs[0].get("stun_opp")
	if(stun_opp > 0):
		return 1
	else:
		return 0
