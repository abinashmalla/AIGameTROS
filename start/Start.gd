extends Node2D

onready var timer:Timer = $Timer
onready var start_label:RichTextLabel = $Start_Label
onready var input_matches:LineEdit = $LineEdit
onready var flare:Particles2D = $Flare

var start:bool = false
var start_time:float = 4
var countdown:int = start_time
var delta_count:float = 0
var intro:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_window_maximized(true)
	$AnimationPlayer.play("arrow_move")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(delta_count >= 1 && !intro):
		intro = true
		$Intro_Voice.playing = true
	if(start):
		if(delta_count >= 1):
			delta_count = 0
			countdown -= 1
			if countdown < 0:
				countdown = 0
		start_label.text = str(" Start  in  ", countdown, " .")
	delta_count += delta

func _on_Timer_timeout():
	get_tree().change_scene("res://Fight.tscn")

func _on_LineEdit_text_entered(new_text):
	if(new_text.is_valid_integer()):
		Globals.repeat = int(new_text)
	start = true
	delta_count = 0
	input_matches.visible = false
	flare.emitting = false
	$AnimationPlayer.play("text_blink")
	timer.start(start_time)
