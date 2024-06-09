extends Node2D

const SHARK_SCENE = preload("res://Scenes/shark.tscn");

@export_category("Tank Configuration")
@export var pull_sharks: bool = true;

@export_category("Shark Configuration")

@export_category("Top Tracks Search Parameters")
@export var search_range := Spotify.SEARCH_LONG;
@export_range(1, 50) var tracks_count: int = 10;

var shark_tracks: Dictionary;

func _ready():
	shark_tracks = load_tracks();
	
	if shark_tracks.is_empty() and pull_sharks:
		shark_tracks = await pull_data();
		store_tracks(shark_tracks);
		load_sharks(shark_tracks);

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

func load_sharks(tracks: Dictionary):
	for id in tracks:
		var track = tracks[id];
		var shark = SHARK_SCENE.instantiate();
		shark.track_id = id;
		shark.track_name = track["name"];
		shark.energy = track["energy"];
		add_child(shark);
	
	# var shark = SHARK_SCENE.instantiate();
	# shark.track_name = track["name"];
	# add_child(shark);

func store_tracks(tracks: Dictionary):
	pass
	
func load_tracks():
	pass
