extends Node

onready var countdown:int = get_parent().countdown
onready var player1:Node2D = get_child(0)
onready var player2:Node2D = get_child(1)
onready var player1_stats:Node2D = get_parent().get_node("Stats/Stats_P1")
onready var player2_stats:Node2D = get_parent().get_node("Stats/Stats_P2")
onready var player1_status:Node2D = get_parent().get_node("Status_Bar/Status_Bar_P1")
onready var player2_status:Node2D = get_parent().get_node("Status_Bar/Status_Bar_P2")
onready var fight_text:RichTextLabel = get_parent().get_node("Fight_Text")
onready var pause_text:RichTextLabel = get_parent().get_node("Pause_Text")
onready var rematch_timer:Timer = get_parent().get_node("Rematch_Timer")

var projectiles:Array
var fight_end:bool = false
var player1_win:bool = false
var player2_win:bool = false
var match_time:float = 0

func _ready():	
	var bounds_x:Vector2 = get_parent().get_node("Stage").bounds_x
	var bounds_y:Vector2 = get_parent().get_node("Stage").bounds_y
	
	process_priority = 0
	player1.process_priority = 1
	player2.process_priority = 1
	
	var player1_icon:Texture = player1.get_node("Icon").texture
	var player2_icon:Texture = player2.get_node("Icon").texture
	
	player1.STATE_INFO_opp = player2.STATE_INFO
	player2.STATE_INFO_opp = player1.STATE_INFO
	player1.setStateInfoOpp()
	player2.setStateInfoOpp()
	player1.bounds_x = bounds_x
	player1.bounds_y = bounds_y
	player2.bounds_x = bounds_x
	player2.bounds_y = bounds_y
	player1._BTREE.bounds_x = bounds_x
	player1._BTREE.bounds_y = bounds_y
	player2._BTREE.bounds_x = bounds_x
	player2._BTREE.bounds_y = bounds_y
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var p1_x = rng.randi_range(bounds_x.x+18,bounds_x.y/2)
	rng.randomize()
	var p1_y = rng.randi_range(bounds_y.x,bounds_y.y-36-10)
	rng.randomize()
	var p2_x = rng.randi_range(bounds_x.y/2,bounds_x.y-18)
	rng.randomize()
	var p2_y = rng.randi_range(bounds_y.x,bounds_y.y-36-10)
	
	player1.position = Vector2(p1_x,p1_y)
	player2.position = Vector2(p2_x,p2_y)
	
	player1.countdown = countdown
	player2.countdown = countdown
	
	player1_stats.set_icon(player1_icon)
	player2_stats.set_icon(player2_icon)
	player1_status.set_icon(player1_icon)
	player2_status.set_icon(player2_icon)
	
	player1_stats.set_text(player1.stats)
	player2_stats.set_text(player2.stats)
	
	print(player1.name)
	print(player2.name)

func updatePlayersBB():
	player1.position_opp = player2.position
	player1.State_opp = player2.State
	player1.vulnerability_opp = player2.vulnerability
	player1.action_end_opp = player2.action_end
	player1.interrupt_opp = player2.interrupt
	player1.velocity_opp = player2.velocity
	
	player2.position_opp = player1.position
	player2.State_opp = player1.State
	player2.vulnerability_opp = player1.vulnerability
	player2.action_end_opp = player1.action_end
	player2.interrupt_opp = player1.interrupt
	player2.velocity_opp = player1.velocity
	
	player1.projectiles_all = projectiles
	player2.projectiles_all = projectiles

func updatePlayerHealthEnergy():
	player1_status.health = player1.health
	player1_status.energy = player1.energy
	
	player2_status.health = player2.health
	player2_status.energy = player2.energy

func updateProjectiles():
	projectiles = get_tree().get_nodes_in_group("Projectile")

func _physics_process(delta):
	updateProjectiles()
	updatePlayersBB()
	updatePlayerHealthEnergy()
	checkResult()

func checkResult():
	if(player1.health <= 0 || player2.health <= 0):
		if(!fight_end):
			player1.setVictory()
			player2.setVictory()
			fight_end = true
			
			if(player1.health <= 0 && player2.health <= 0):
				fight_text.victory_text = "Draw"
			elif(player1.health > 0):
				player1_win = true
				fight_text.victory_text = str(player1.name, " Wins!","")
			elif(player2.health > 0):
				player2_win = true
				fight_text.victory_text = str(player2.name, " Wins!")
		
			match_time = fight_text.fight_time
			
			player1.record(player1_win,match_time)
			player2.record(player2_win,match_time)
			player1.generateStats()
			player2.generateStats()
			player1_stats.set_text(player1.stats)
			player2_stats.set_text(player2.stats)
			rematch_timer.start()

func pauseGame():
	if get_tree().paused:
		pause_text.unpause()
		get_tree().paused = false
	else:
		fight_text.pause()
		pause_text.pause()
		get_tree().paused = true

func rematch():
	fight_text.pause()
	pause_text.rematch()
	get_tree().paused = true
