tool
extends VisualScriptCustomNode

func _get_caption():
	return "Interrupt?"

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
			return "Yes"
		1:
			return "No"

func _step(inputs,outputs,start_mode,working_mem):
	var interrupt:bool = inputs[0].interrupt
	
	if(interrupt):
		inputs[0].interrupt = false
		inputs[0].state_queue = []
		inputs[0].state_queue_locked =  []
		return 0
	else:
		return 1
