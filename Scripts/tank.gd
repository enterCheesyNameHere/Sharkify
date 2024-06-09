extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get top 10 tracks from spotify
	Spotify.GetTopTracks();
	# Create sharks with all that data


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
