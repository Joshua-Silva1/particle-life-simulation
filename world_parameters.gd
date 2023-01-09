extends Node

# Simulation stats
const F : float = 0.5 # standard force
const friction : float = 0.90
const start_particle_count : int = 0
const max_particle_count : int = 550
const force_multiplier : float = 2.0
const particle_duplication : bool = true

const spread : float = 0.0 # negative is very clustered
const attraction_factor : float = 0.5
const repulsion_factor : float = 1.5

const max_speed : float = 100.0
const area_size : Vector2 = Vector2(1020, 595)

onready var particle_tiers : Array = [1, 2, 3, 4, 5, 6, 7, 34, 55, 89]

onready var world = get_node("/root/world")
onready var spawn_capper1 = get_node("/root/world/spawnCapper1")
onready var spawn_capper2 = get_node("/root/world/spawnCapper2")

onready var particle_stats = [
	{"colour": "white", "colour_code": "#f7f7c7", "min_radius": 7, "max_radius": 15, "max_velocity": 400, "interactions": 	[1.5*F, F, F, F, F, F, 4*F]},#[-5.0, -0.9, -0.8, -0.7, -0.6, -0.5, -3.0]},
	{"colour": "red", "colour_code": "#ff718c", "min_radius": 10, "max_radius": 5, "max_velocity": 350, "interactions": 	[F, F, F, F, F, F, 2*F]},
	{"colour": "orange", "colour_code": "#ff9072", "min_radius": 7, "max_radius": 15, "max_velocity": 300, "interactions": 	[F, F, 1.5*F, F, F, F, 2*F]},
	{"colour": "yellow", "colour_code": "#ffc567", "min_radius": 7, "max_radius": 10, "max_velocity": 250, "interactions": 	[F, F, F, 2*F, F, F, 1.5*F]},
	{"colour": "green", "colour_code": "#29ab7d", "min_radius": 7, "max_radius": 10, "max_velocity": 200, "interactions": 	[F, F, F, F, 3*F, F, 2*F]},
	{"colour": "blue", "colour_code": "#00408f", "min_radius": 11, "max_radius": 15, "max_velocity": 150, "interactions": 	[F, F, F, F, F, F, 2*F]},
	{"colour": "purple", "colour_code": "#6f2a8f", "min_radius": 14, "max_radius": 15, "max_velocity": 100, "interactions": [2*F, 2*F, 2*F, 2*F, 2*F, 2*F, 6*F]}
]

func spawn_p(pos, team):
	if team:
		if spawn_capper1.is_stopped():
			world.spawn_new_particle(0, pos, team)
			spawn_capper1.start()
	else:
		if spawn_capper2.is_stopped():
			world.spawn_new_particle(0, pos, team)
			spawn_capper2.start()

func get_particle_tier(nearby_particle_count):
	var x = particle_tiers.find(nearby_particle_count)
	return [x, particle_stats[x].get("colour_code")]

