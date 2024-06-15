extends Node2D


@export_category("Shark Attributes")
## Determines speed and frequency of movement.
## More energetic songs (closer to 1) move faster and more often
@export_range(0.0,1.0) var energy: float; 
## Determines how far a shark can move via resistance.
## More popular (closer to 1) sharks will "glide" farther
@export_range(0.0,1.0) var popularity: float;
## Determines a shark's sociability.
## Sharks with a higher valence will more often move towards other sharks
@export_range(0.0,1.0) var valence: float;

@onready var tank := get_parent();

var track_id: String;
var track_name: String;

var resistance: float = 0.0;
var velocity: Vector2 = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Movement Cooldown".wait_time = tank.movement_frequency;
	$"Movement Cooldown".timeout.connect(move_shark);
	$"Movement Cooldown".start();
	
	var tank_walls: Area2D = get_parent().get_node("Walls");
	tank_walls.area_entered.connect(bounce)

func _process(delta):
	if not $Sprite2D.is_playing():
		if velocity != Vector2.ZERO:
			$Sprite2D.play("Moving");
		else:
			$Sprite2D.play("Looking");
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Move shark from velocity vector
	if velocity != Vector2.ZERO:
		position += velocity*delta;
	
	# Apply resistance
	if velocity != Vector2.ZERO:
		var resistance_vec: Vector2 = resistance * delta * Vector2(cos(velocity.angle()), sin(velocity.angle()));
		velocity = (velocity/abs(velocity))*clamp(abs(velocity) - resistance_vec, Vector2.ZERO, abs(velocity));
	
	# Start cooldown for movement when stopped.
	# Cooldown is restarting even though 
	if velocity == Vector2.ZERO and $"Movement Cooldown".is_stopped():
		print("Cooldown started")
		$"Movement Cooldown".start();

func move_shark():
	# Generate direction of travel and starting velocity
	var angle: float = randf_range(0,2*PI);
	var vel: float = tank.movement_speed * jitter(energy);
	
	# Flip and orient the shark depending on the angle
	if abs(angle) > PI/2 and abs(angle) < 3*PI/2:
		scale = Vector2(abs(scale.x), scale.y);
		rotate(-angle);
	else: 
		scale *= Vector2(-1,1);
		rotate(angle);
	
	# Update velocity vector and calculate resistance
	print("Move");
	velocity = Vector2(vel*cos(angle), vel*sin(angle));
	resistance = tank.movement_resistance / jitter(popularity)

# Reverses the velocity of the shark and halfs it
# TODO: Determine if I just want to half it or make the multiplier variable
func bounce():
	print("bounce")
	velocity = -velocity/2;
	
# Applies minor deviation from normal value for added randomness.
func jitter(value: float) -> float:
	return clamp(value + randf_range(-tank.jitter_offset,tank.jitter_offset),0,1);
	

