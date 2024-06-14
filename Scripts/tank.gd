extends Node2D

const SHARK_SCENE = preload("res://Scenes/shark.tscn");


@export_category("Tank Configuration")
@export var pull_sharks: bool = true;

@export_category("Shark Configuration")
## Minimum resistance (deacceleration) a shark with popularity of 1 experiences
@export var movement_resistance: int = 1; 
## Maxmimum speed a shark with energy of 1 can move
@export var movement_speed: int = 5;
## Maximum frequency of movements (per minute) a shark with energy of 1 will have.
@export var movement_frequency: int = 10;
## Maximum change that the jitter function can make
@export_range(0, 0.5) var jitter_offset: float = 0.1;



@export_category("Top Tracks Search Parameters")
## Search range for top songs
@export var search_range: Spotify.search_ranges = Spotify.search_ranges.LONG;
## Number of tracks to pull from Spotify. 
@export_range(1, 50) var tracks_count: int = 10;

var shark_tracks: Dictionary;
func _ready():	
	if shark_tracks.is_empty() and pull_sharks:
		Spotify.authorization_code_redirect();
		shark_tracks = await pull_data();
		store_tracks(shark_tracks);
		create_sharks(shark_tracks);

func _process(delta):
	pass
	
func pull_data() -> Dictionary:
	var top_tracks = await Spotify.get_top_tracks_async(search_range, tracks_count);
	var tracks: Dictionary;
	for track: Dictionary in top_tracks:
		var id = track["id"]
		tracks[id] = {};
		tracks[id].merge(track);
		tracks[id].erase("id");
		
	# Pull the audio features of each track in the ID list and put them in the dictionary of tracks
	var tracks_stats = (await Spotify.get_tracks_audio_features_async(tracks.keys()))["audio_features"];
	for stats in tracks_stats:
		var id = stats["id"];
		tracks[id].merge(stats);
		tracks[id].erase("id");
		
	return tracks;

func create_sharks(tracks: Dictionary):
	var wall_size: Vector2 = $"Walls/Left Wall".shape.get_rect().size;
	var roof_size: Vector2 = $Walls/Roof.shape.get_rect().size;
	var upper_corner: Vector2 = Vector2(wall_size.x, roof_size.y);
	var lower_corner: Vector2 = Vector2(roof_size.x + wall_size.x, wall_size.y - roof_size.y);
	
	for id in tracks:
		var track = tracks[id];
		var shark = SHARK_SCENE.instantiate();
		
		# Add Attributes
		shark.track_id = id;
		shark.track_name = track["name"];
		shark.energy = track["energy"];
		shark.popularity = track["popularity"];
		
		shark.position = Vector2(randi_range(upper_corner.x, lower_corner.x), randi_range(upper_corner.y, lower_corner.y));
		add_child(shark);
	
	# var shark = SHARK_SCENE.instantiate();
	# shark.track_name = track["name"];
	# add_child(shark);

func store_tracks(tracks: Dictionary):
	pass
	
func load_tracks():
	pass
