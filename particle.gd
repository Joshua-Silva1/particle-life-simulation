extends Area2D

# Particle stats
onready var speed_mod : float = 1
onready var velocity : Vector2 = Vector2.ZERO
onready var wall_adjacent : bool = false
onready var nearby_particles : Array = []

onready var is_positive : bool# negative ones destroy positive ones on contact
onready var colour : float
onready var min_radius : float = 5.0
onready var max_radius : float = 10.0
onready var interactions : PoolRealArray

func _ready():
	# Sets initial collision zones
	$CollisionShape2D.shape.radius = min_radius * 5
	$force_range/CollisionShape2D.shape.radius = max_radius * 5

func _physics_process(_delta):
	# pulls out of bounds particles back to centre
	if wall_adjacent:
		velocity += global_position.direction_to(Vector2(500, 250)* 0.5)
	
	# applies velocity
	global_position += velocity
	velocity *= world_parameters.friction
	velocity = velocity.clamped(speed_mod)
	
	apply_interaction_forces()
	
	# Particle Replication check (purple particles create new particles)
	if colour == 6:
		duplicate_particle()

func add_velocity(vec):
	velocity += vec

func update_colour():
	set_colour(clamp(nearby_particles.size(), 0, 6))

func set_charge(team):
	is_positive = team
	if !is_positive:
		$Sprite.self_modulate -= Color(0, 0, 0, 0.7)

# Updates stats of particle on a colour change
func set_colour(co):
	if co == colour:
		return
	if colour == 6:
		duplicate_particle()
	var c = world_parameters.particle_stats[co]
	colour = co
	$Sprite.modulate = c.get("colour_code")
	min_radius = c.get("min_radius")
	max_radius = c.get("max_radius")
	interactions = c.get("interactions")
	speed_mod = c.get("max_velocity")

func duplicate_particle():
	if world_parameters.particle_duplication:
		world_parameters.spawn_p((global_position + velocity.clamped(world_parameters.spread)), is_positive)

# Interacts with nearby particles
func apply_interaction_forces():
	for particle in nearby_particles:
		var dist = global_position.distance_to(particle.global_position)
		if dist <= 0:
			break
		var dir = global_position.direction_to(particle.global_position)
		var col_interaction = interactions[particle.colour]
		if dist <= min_radius:
			if is_positive != particle.is_positive:
				particle.call_deferred("queue_free")
				call_deferred("queue_free")
				return
			particle.add_velocity(world_parameters.repulsion_factor * world_parameters.force_multiplier * (world_parameters.friction / dist) * dir * col_interaction)
		else:
			particle.add_velocity(-world_parameters.attraction_factor * (world_parameters.force_multiplier) * (world_parameters.friction / dist) * dir * col_interaction)


# Tracks nearby particles
func _on_force_range_area_entered(area):
	if area == self:
		return
	nearby_particles.append(area)
	update_colour()

func _on_force_range_area_exited(area):
	if area == self:
		return
	nearby_particles.erase(area)
	update_colour()


# Tracks nearby walls
func _on_new_particle_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	wall_adjacent = true

func _on_new_particle_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):
	wall_adjacent = false
