tool
extends VisualScriptCustomNode

func _get_caption():
	return "Queue State"

func _get_input_value_port_count():
	return 4

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_INT
		2:
			return TYPE_STRING
		3:
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
			return "lockedQ"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
		var state_int:int = inputs[1]
		var state_name:String = inputs[2]
		var lockedQ:bool = inputs[3]
		
		var queue:int = 0
		
		if(state_int != -1):
			queue = state_int
		else:
			for state in inputs[0].STATE_INFO:
				if(inputs[0].STATE_INFO.get(state).animation == state_name):
					queue = state
					break
				
		if(lockedQ):
			inputs[0].state_queue_locked.push_back(queue)
		else:
			inputs[0].state_queue.push_back(queue)
		return 0
