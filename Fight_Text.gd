extends RichTextLabel

onready var fight = get_parent()
onready var countdown:int = get_parent().countdown
onready var background_music:AudioStreamPlayer = get_parent().get_node("Background Music")
onready var fight_timer:RichTextLabel = $Fight_Timer
export var fight_time:float = 0
export var victory_text:String = ""

onready var audio:AudioStreamPlayer = $Fight_Sounds

const countdown_beep = preload("res://common/countdown.wav")
const fight_cry = preload("res://common/fight.wav")
const victory_sound = preload("res://common/win.wav")
const victory_bg = preload("res://common/win_bg.wav")

var delta_timer:float = 0
var fight_text:String
var victory_declared:bool = false
var time_format_string = "%02d:%02d"
var time_string
var time_min:int = 0
var time_seconds:int = 0
var time_ms:int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(delta_timer >= 1):
		delta_timer = 0
		countdown -= 1
	
	if(countdown == 0):
		fight_text = "Fight!"
		if(delta_timer == 0):
			audio.stream = fight_cry
			audio.playing = true
	elif(countdown < 0):
		countdown = -1
		fight_text = ""
	else:
		if(delta_timer == 0):
			audio.stream = countdown_beep
			audio.playing = true
		fight_text = str(countdown)
	
	if(victory_text != ""):
		fight_text = victory_text
		if(!victory_declared):
			background_music.stream = victory_bg
			background_music.playing = true
			audio.stream = victory_sound
			audio.playing = true
			victory_declared = true
			time_format_string = "%02d:%02d.%02d"
			time_string = time_format_string % [time_min, time_seconds, time_ms]
			fight_timer.bbcode_text = str("[center]",time_string,"[/center]")
	else:
		if(countdown<=0):
			fight_time += delta
			time_min = fight_time/60
			time_seconds = fight_time - time_min*60
			time_ms = (fight_time - int(fight_time))*100
			time_string = time_format_string % [time_min, time_seconds]
			fight_timer.bbcode_text = str("[center]",time_string,"[/center]")
	
	bbcode_text = str("[center]",fight_text,"[/center]")
	delta_timer += delta

func pause():
	bbcode_text = str("")
	
