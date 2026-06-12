tool
extends VisualScriptCustomNode

var info:Dictionary = {}
var energy:int = 0

func _get_caption():
	return "Select Movement"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
	return TYPE_OBJECT

func _get_input_value_port_name(idx):
	return "Self"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	info = inputs[0].STATE_INFO
	energy = inputs[0].energy
	
	var type:String = "movement"

	var valid_states:Array = []
	
	for state in info:
		if(info.get(state).has(type)):
			if(enoughEnergy(state)):
				valid_states.push_back(state)
	
	var queue:Array = []
	if(!valid_states.empty()):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var roll:int = rng.randi_range(0,valid_states.size()-1)
		queue.push_back(valid_states[roll])
	
	if(queue.empty()):
		queue.push_back(0)
	
	inputs[0].state_queue += queue
	return 0

func enoughEnergy(var state:int):
	if(info.get(state).has("energy")):
		if(energy >= info.get(state).energy):
			return true
		else:
			return false
	return true
