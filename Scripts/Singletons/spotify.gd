extends Node

signal Authorized;

const PORT := 3000;
const BINDING := "127.0.0.1";

var envVars := _getEnviromentVars();
var RedirectServer := TCPServer.new();
var RedirectURI := "http://%s:%s" % [BINDING, PORT];
var _token: String;
var _refreshToken: String;
var _listen: bool = false;

enum SearchLengths {LONG, MEDIUM, SHORT};


func _enter_tree():
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
			
			# Send page notifying user to close browser or just close the window altogether
			
			connection.disconnect_from_host();
			RedirectServer.stop();

# Redirects user to Spotify to log in so app can get an auth code
func AuthCodeRedirect():
	_listen = true;
	
	var redirectErr = RedirectServer.listen(PORT, BINDING);
	
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
	[]
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
	
	emit_signal("Authorized");
	

func GetTopTracksAsync(timeRange: SearchLengths = SearchLengths.MEDIUM, amount: int = 10) -> Array:
	var range: String;
	match timeRange:
		0:
			range = "long_term";
		1:
			range = "medium_term";
		2:
			range = "short_term";
			
	var topTracks;
	var body: Array[String] = [
		"time_range=%s" % range,
		"limit=%s" % amount
	];
	
	if !_token:
		await Authorized;
	
	return (await _makeRequest("https://api.spotify.com/v1/me/top/tracks", body))["items"];

func _getEnviromentVars() -> Dictionary:
	var file := FileAccess.open("res://.env", FileAccess.READ);
	var content = file.get_as_text(true)
	var variables: Dictionary;
	
	for line in content.split("\n", false):
		var info = line.split("=");
		variables[info[0]] = info[1];
	
	return variables;

func _makeRequest(endpoint: String, body: Array[String]):
	var headers = [
		"Authorization: Bearer %s" % _token
	]
	headers = PackedStringArray(headers);
	var bodyStr = "&".join(PackedStringArray(body));
	
	var request := HTTPRequest.new();
	add_child(request);
	
	var err = request.request(
		endpoint+"?"+bodyStr,
		headers, 
		HTTPClient.METHOD_GET
	);
	
	if err != OK:
		printerr("Error making request to %s. Error: %s" % [endpoint, err]);
		
	var response = await request.request_completed;
	var resBody = JSON.parse_string(response[3].get_string_from_utf8());
	
	return resBody;
