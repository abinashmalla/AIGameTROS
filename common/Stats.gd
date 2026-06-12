extends Node2D

onready var player_icon:Sprite = $Player_Icon
onready var stats_text:RichTextLabel = $Stats_Text

func set_icon(var icon:Texture):
	player_icon.texture = icon

func set_text(var text:String):
	stats_text.bbcode_text = str("[center]",text,"[/center]")
