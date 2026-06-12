extends LineEdit

onready var caret:Sprite = $Caret
onready var posX:int = rect_size.x/2

var delta_timer:float = 0

func _ready():
	caret_position += text.length()
	grab_focus()

func _physics_process(delta):
	caret.position.x = posX+12*caret_position
	if(delta_timer >= 0.65):
		caret.visible = !caret.visible
		delta_timer = 0
	delta_timer += delta
