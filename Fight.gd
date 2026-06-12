extends Node2D

export var countdown:int = 3

onready var globalBB:YSort = $GlobalBB
onready var pause_text:RichTextLabel = $Pause_Text
onready var stats:Sprite = $Stats

func _input(event):
	if event.is_action_pressed("PAUSE"):
		globalBB.pauseGame()
	if event.is_action_pressed("REMATCH"):
		globalBB.rematch()
	if event.is_action_pressed("STATS"):
		stats.visible = !stats.visible

func _on_Pause_Text_match_end():
	globalBB.pauseGame()
	get_tree().reload_current_scene()

func _on_Rematch_Timer_timeout():
	Globals.repeat -= 1
	if(Globals.repeat > 0):
		globalBB.rematch()
	else:
		stats.visible = true
