extends Node2D

export var bounds_x:Vector2 = Vector2(0,1088)
export var bounds_y:Vector2 = Vector2(210,570)

func _ready():
	var size:Vector2 = $Sprite.texture.get_size()
	position.x = size.x/2
	position.y = size.y/2
