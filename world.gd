extends Node2D

onready var particle_count : int

onready var particle = preload("res://particle.tscn")

func _ready():
	randomize()
	# generates random starting population
	for _i in range(world_parameters.start_particle_count):
		spawn_new_particle(0, get_rand_pos(), true)
	call_deferred("update_pop_count")

func _input(event):
	# spawns in new particles on click
	if event.is_action_pressed("left_click"):
		spawn_new_particle(0, get_global_mouse_position(), true)
	elif event.is_action_pressed("right_click"):
		spawn_new_particle(0, get_global_mouse_position(), false)

# gets random pos in target area
func get_rand_pos():
	return Vector2(randi() % int(world_parameters.area_size.x) + 5, randi() % int(world_parameters.area_size.y) + 5)

# instances new particle
func spawn_new_particle(type, pos, team):
	if particle_count >= world_parameters.max_particle_count:
		return
	
	var new_particle = particle.instance()
	new_particle.global_position = pos
	new_particle.set_colour(type)
	new_particle.set_charge(team)
	call_deferred("add_child", (new_particle))
	update_pop_count()

func update_pop_count():
	particle_count = get_child_count() - 7
	$CanvasLayer/Label.text = "P Count: " + str(particle_count)
