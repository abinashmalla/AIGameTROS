tool
extends VisualScriptCustomNode

func _get_caption():
	return "Delayed Queue"

func _get_input_value_port_count():
	return 5

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_INT
		2:
			return TYPE_STRING
		3:
			return TYPE_REAL
		4:
			return TYPE_BOOL

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "State"
		2:
			return "State"
		3:
			return "Timer"
		4:
			return "Stop Action?"

func _has_input_sequence_port():
	return true

func _get_output_value_port_count():
	return 1

func _get_output_value_port_name(idx):
	return "Timer"

func _get_output_value_port_type(idx):
	return TYPE_REAL

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	var qState:int = 0;
	if(inputs[1] != -1):
		qState = inputs[1]
	else:
		for state in inputs[0].STATE_INFO:
			if(inputs[0].STATE_INFO.get(state).animation == inputs[2]):
				qState = state
				break
	inputs[0].delay_state = qState
	inputs[0].set_stop_action = inputs[4]
	outputs[0] = inputs[3]
	return 0
