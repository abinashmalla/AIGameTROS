tool
extends VisualScriptCustomNode

var info:Dictionary = {}
var energy:int = 0
var distance_to_opp:int = 0
var angle_to_opp:float = 0

func _get_caption():
	return "Select State"

func _get_input_value_port_count():
	return 3

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_STRING
		2:
			return TYPE_BOOL

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "State Type"
		2:
			return "lockedQ"

func _has_input_sequence_port():
	return true

func _get_output_value_port_count():
	return 1

func _get_output_value_port_name(idx):
	return "lockedQ"

func _get_output_value_port_type(idx):
	return TYPE_BOOL

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	info = inputs[0].STATE_INFO
	var type:String = inputs[1]
	var lockedQ:bool = inputs[2]
	
	energy = inputs[0].energy
	distance_to_opp = inputs[0].distance_to_opp
	angle_to_opp = inputs[0].angle_to_opp

	var valid_states:Array = []
	
	for state in info:
		match type:
			"attack":
				if(info.get(state).has("attack")):
					if(inRange(state) && enoughEnergy(state)):
						valid_states.push_back(state)
			"movement":
				if(info.get(state).has("movement")):
					if(enoughEnergy(state)):
						valid_states.push_back(state)
			_:
				if(info.get(state).has(type)):
					valid_states.push_back(state)
	
	var queue:Array = []
	if(!valid_states.empty()):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var roll:int = rng.randi_range(0,valid_states.size()-1)
		queue.push_back(valid_states[roll])
	
	if(queue.empty()):
		queue.push_back(0)
	
	var new_queue:int = queue[0]
	while(info.get(new_queue).has("follow")):
		new_queue = info.get(new_queue).follow
		queue.push_back(new_queue)
	
	if(lockedQ):
		inputs[0].state_queue_locked += queue
	else:
		inputs[0].state_queue += queue
	
	outputs[0] = lockedQ
	return 0

func enoughEnergy(var state:int):
	if(info.get(state).has("energy")):
		if(energy >= info.get(state).energy):
			return true
		else:
			return false
	return true

func inRange(var state:int):
	if(info.get(state).has("distance")):
		if(info.get(state).distance < distance_to_opp):
			return false
	if(info.get(state).has("angle_clamp")):
		if(abs(angle_to_opp) > info.get(state).angle_clamp):
			return false
	return true
