extends Node2D

export var health:int = 100
export var energy:int = 100
export var invert:bool = false

export var health_high:Color
export var health_low:Color

onready var health_bar:TextureProgress = $Health_Bar
onready var health_label:Label = $Health_Label
onready var energy_bar:TextureProgress = $Energy_Bar
onready var energy_label:Label = $Energy_Label
onready var player_icon:Sprite = $Player_Icon

func _ready():
	var screen_size:Vector2 = get_viewport_rect().size
	var status_pos:Vector2 = Vector2(10,10) 
	if(invert):
		status_pos = Vector2(screen_size.x-100*2-10-60,10)
	position = status_pos

func set_icon(var icon:Texture):
	player_icon.texture = icon
	player_icon.position.x += icon.get_size().x/2*0.2083
	player_icon.position.y += icon.get_size().x/2*0.2083

func set_health():
	health = clamp(health,0,100)
	if(health <= 30):
		health_bar.tint_progress = health_low
	else:
		health_bar.tint_progress = health_high
	health_bar.value = health
	health_label.text = str(health,"%")

func set_energy():
	energy = clamp(energy,0,100)
	energy_bar.value = energy
	energy_label.text = str(energy)

func _process(delta):
	set_health()
	set_energy()
