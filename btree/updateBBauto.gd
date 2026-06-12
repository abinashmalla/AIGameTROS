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
	var properties:Array = inputs[1].get_property_list()
	for property in properties:
		if(property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE):
			inputs[1].set(property.name, inputs[0].get(property.name))
		elif(property.name == "position"):
			inputs[1].set(property.name, inputs[0].get(property.name))
	return 0
