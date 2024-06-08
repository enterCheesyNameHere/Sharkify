extends Node

const PORT := 3000;
const BINDING := "127.0.0.1";

var envVars := _getEnviromentVars();
var RedirectServer := TCPServer.new();
var RedirectURI := "http://%s:%s" % [BINDING, PORT];
var _token: String;
var _refreshToken: String;
var _listen: bool = false;


func _ready():
	AuthCodeRedirect();
	
func _process(delta):
	# Listen for redirects:
	if _listen and RedirectServer.is_connection_available() :
		var connection = RedirectServer.take_connection();
		var request = connection.get_string(connection.get_available_bytes());
		if request:
			_listen = false;
			var auth_code = request.split("code=")[1].split(" ")[0];
			
			GetTokenFromAuthCode(auth_code);

# Redirects user to Spotify to log in so app can get an auth code
func AuthCodeRedirect():
	_listen = true;
	
	var foo = RedirectServer.listen(PORT, BINDING);
	
	var body = [
		"client_id=%s" % envVars["CLIENT_ID"],
		"response_type=code",
		"redirect_uri=%s" % RedirectURI,
		"scope=user-top-read"
	];
	body = "&".join(PackedStringArray(body));
	
	var authURL = "https://accounts.spotify.com/authorize?" + body;
	OS.shell_open(authURL);

func GetTokenFromAuthCode(authCode: String):
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	headers = PackedStringArray(headers);
	
	var body = [
		"client_id=%s" % envVars["CLIENT_ID"],
		"client_secret=%s" % envVars["CLIENT_SECRET"],
		"grant_type=authorization_code",
		"code=%s" % authCode,
		"redirect_uri=%s" % RedirectURI,
		"scope=user-top-read"
	];
	body = "&".join(PackedStringArray(body));
	
	var request := HTTPRequest.new();
	add_child(request);
	
	var err = request.request(
		"https://accounts.spotify.com/api/token",
		headers, 
		HTTPClient.METHOD_POST,
		body
	)
	if err != OK:
		printerr("Error occured while querying Spotify for a token. Error Code %s" % err);
	
	var response = await request.request_completed;
	var resBody = JSON.parse_string(response[3].get_string_from_utf8());
	
	_token = resBody["access_token"];
	_refreshToken = resBody["refresh_token"];
	# var lifeSpan = resBody["expires_in"];
	
	

func _getEnviromentVars() -> Dictionary:
	var file := FileAccess.open("res://.env", FileAccess.READ);
	var content = file.get_as_text(true)
	var variables: Dictionary;
	
	for line in content.split("\n", false):
		var info = line.split("=");
		variables[info[0]] = info[1];
	
	return variables;
	
func GetTopTracks():
	pass;
