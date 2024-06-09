extends Node2D


@export_category("Shark Attributes")
## Determines speed and frequency of movement
@export_range(0.0,1.0) var energy: float; 
## Determines how far a shark can move
@export_range(0.0,1.0) var popularity: float;

@onready var tank := get_parent();

var track_id: String;
var track_name: String;


# Called when the node enters the scene tree for the first time.
func _ready():
	$"Movement Cooldown".wait_time = 3;
	$"Movement Cooldown".timeout.connect(move_shark);
	$"Movement Cooldown".start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_shark():
	var distance: int = tank.movement_radius * jitter(popularity);
	var angle: float = randf_range(0,2*PI);
	var movement: Vector2 = Vector2(distance*cos(angle), distance*sin(angle));
	var avg_speed: float = tank.movement_speed * jitter(energy);
	var movement_time: float = distance / avg_speed;
	
	translate(movement);
	$"Movement Cooldown".start();
	
	# Determine movement based on popularity
	
# Applies minor deviation from normal value for added randomness.
func jitter(value: float) -> float:
	return clamp(value + randf_range(-tank.jitter_offset,tank.jitter_offset),0,1);
	
