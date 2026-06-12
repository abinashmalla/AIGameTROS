extends RichTextLabel

onready var audio:AudioStreamPlayer = $Pause_Sound
onready var rematch_flare:Particles2D = get_parent().get_node("Rematch_Flare")

var delta_timer:float = 0
signal match_end()

func _ready():
	set_physics_process(false)

func pause():
	bbcode_text ="[center][wave]PAUSE[/wave][/center]"
	audio.playing = true

func unpause():
	bbcode_text = ""

func rematch():
	bbcode_text = "[center][wave]Rematch[/wave][/center]"
	audio.playing = true
	set_physics_process(true)

func _physics_process(delta):
	if delta_timer >= 1:
		emit_signal("match_end")
	delta_timer += delta
