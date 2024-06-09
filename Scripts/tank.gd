extends Node2D

const SHARK_SCENE = preload("res://Scenes/shark.tscn");

@export_category("Tank Configuration")
@export var pull_sharks: bool = true;

@export_category("Shark Configuration")

@export_category("Top Tracks Search Parameters")
@export var search_range := Spotify.SEARCH_LONG;
@export_range(1, 50) var tracks_count: int = 10;

var top_tracks: Array;

func _ready():
	if pull_sharks:
		load_sharks();

func _process(delta):
	pass

func load_sharks():
	top_tracks = await Spotify.get_top_tracks_async(search_range, tracks_count);
	var ids: Array[String];
	for track in top_tracks:
		ids.append(track["id"]);
		
	var track_stats = await Spotify.get_tracks_audio_features_async(ids);
	# var shark = SHARK_SCENE.instantiate();
	# shark.track_name = track["name"];
	# add_child(shark);
