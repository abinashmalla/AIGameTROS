tool
extends VisualScriptCustomNode

var info:Dictionary = {}
var energy:int = 0
var distance_to_opp:int = 0
var angle_to_opp:float = 0

func _get_caption():
	return "Select Attack"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "In Range"
		1:
			return "Not in Range"

func _step(inputs,outputs,start_mode,working_mem):
	info = inputs[0].STATE_INFO
	var type:String = "attack"
	
	energy = inputs[0].energy
	distance_to_opp = inputs[0].distance_to_opp
	angle_to_opp = inputs[0].angle_to_opp

	var valid_states:Array = []
	var priority_states:Array = []
	
	for state in info:
		if(info.get(state).has(type)):
			if(enoughEnergy(state)):
				valid_states.push_back(state)
				if(info.get(state).has("start")):
					if(inRange(state)):
						priority_states.push_back(state)
						break
	
	if(!priority_states.empty()):
		valid_states = priority_states
	
	var queue:Array = []
	if(!valid_states.empty()):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var roll:int = rng.randi_range(0,valid_states.size()-1)
		queue.push_back(valid_states[roll])
	
	inputs[0].attack_range = 0
	
	if(inputs[0].try_attack != -1):
		var try_attack = inputs[0].try_attack
		inputs[0].try_attack = -1
		if(enoughEnergy(try_attack) && inRange(try_attack)):
			queue = [try_attack]
	
	if(queue.empty()):
		return 1
	
	var new_queue:int = queue[0]
	while(info.get(new_queue).has("follow")):
		new_queue = info.get(new_queue).follow
		queue.push_back(new_queue)

	if(!inRange(queue[0])):
		if(info.get(queue[0]).has("distance")):
			inputs[0].attack_range = info.get(queue[0]).get("distance")
			inputs[0].try_attack = queue[0]
		return 1
		
	inputs[0].state_queue += queue
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
		if(info.get(state).has("start")):
			if(info.get(state).start > distance_to_opp):
				return false
	if(info.get(state).has("angle_clamp")):
		if(abs(angle_to_opp) > info.get(state).angle_clamp):
			return false
	return true
