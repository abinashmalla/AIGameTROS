tool
extends VisualScriptCustomNode

func _get_caption():
	return "Update Blackboard"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	return TYPE_OBJECT

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Source"
		1:
			return "Destination"

func _has_input_sequence_port():
	return true

func _step(inputs,outputs,start_mode,working_mem):
	inputs[1].set("position", inputs[0].get("position"))
	inputs[1].set("State", inputs[0].get("State"))
	inputs[1].set("new_state", inputs[0].get("new_state"))
	inputs[1].set("vulnerability", inputs[0].get("vulnerability"))
	inputs[1].set("action_end", inputs[0].get("action_end"))
	inputs[1].set("interrupt", inputs[0].get("interrupt"))
	inputs[1].set("destination", inputs[0].get("destination"))
	inputs[1].set("velocity", inputs[0].get("velocity"))
	inputs[1].set("duration", inputs[0].get("duration"))
	inputs[1].set("angle", inputs[0].get("angle"))
	inputs[1].set("distance", inputs[0].get("distance"))
	inputs[1].set("speed", inputs[0].get("speed"))
	inputs[1].set("energy", inputs[0].get("energy"))
	inputs[1].set("health", inputs[0].get("health"))
	inputs[1].set("stun_opp", inputs[0].get("stun_opp"))
	
	inputs[1].set("State_opp", inputs[0].get("State_opp"))
	inputs[1].set("position_opp", inputs[0].get("position_opp"))
	inputs[1].set("vulnerability_opp", inputs[0].get("vulnerability_opp"))
	inputs[1].set("action_end_opp", inputs[0].get("action_end_opp"))
	inputs[1].set("interrupt_opp", inputs[0].get("interrupt_opp"))
	inputs[1].set("velocity_opp", inputs[0].get("velocity_opp"))
	
	inputs[1].set("projectiles_all",inputs[0].get("projectiles_all"))
	return 0
