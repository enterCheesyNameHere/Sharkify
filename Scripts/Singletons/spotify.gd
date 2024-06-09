extends Node

signal Authorized;

const _PORT := 3000;
const _BINDING := "127.0.0.1";

var _env_vars := _get_env_vars();
var _redirect_server := TCPServer.new();
var _redirect_uri := "http://%s:%s" % [_BINDING, _PORT];
var _token: String;
var _refreshToken: String;
var _listen: bool = false;
var _verifier: String;

enum {SEARCH_LONG, SEARCH_MEDIUM, SEARCH_SHORT};

func _enter_tree():
	authorization_code_redirect();
	
func _process(delta):
	# Listen for redirects:
	if _listen and _redirect_server.is_connection_available() :
		var connection = _redirect_server.take_connection();
		var request = connection.get_string(connection.get_available_bytes());
		if request:
			_listen = false;
			var auth_code = request.split("code=")[1].split(" ")[0];
			
			_get_token_from_auth_code(auth_code);
			
			# Send page notifying user to close browser or just close the window altogether
			
			connection.disconnect_from_host();
			_redirect_server.stop();

# Redirects user to Spotify to log in so app can get an auth code
func authorization_code_redirect():
	_verifier = _generate_code_verifier(128);
	var challenge = _generate_code_challenge(_verifier);
	_listen = true;
	
	var redirectErr = _redirect_server.listen(_PORT, _BINDING);
	
	var body = [
		"client_id=%s" % _env_vars["CLIENT_ID"],
		"response_type=code",
		"redirect_uri=%s" % _redirect_uri,
		"scope=user-top-read",
		"code_challenge_method=S256",
		"code_challenge=%s" % challenge
	];
	
	body = "&".join(PackedStringArray(body));
	
	var authURL = "https://accounts.spotify.com/authorize?" + body;
	OS.shell_open(authURL);

# Need to update this to use a different form of authorization so it can be shared
# without sharing the client secret as well.
func _get_token_from_auth_code(authCode: String):
	var headers = [
		"Content-Type: application/x-www-form-urlencoded"
	]
	headers = PackedStringArray(headers);
	
	var body = [
		"client_id=%s" % _env_vars["CLIENT_ID"],
		"code_verifier=%s" % _verifier,
		"grant_type=authorization_code",
		"code=%s" % authCode,
		"redirect_uri=%s" % _redirect_uri,
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
	var res_body = JSON.parse_string(response[3].get_string_from_utf8());
	
	_token = res_body["access_token"];
	_refreshToken = res_body["refresh_token"];
	# var lifeSpan = res_body["expires_in"];
	
	emit_signal("Authorized");

func get_top_tracks_async(timeRange := SEARCH_MEDIUM, amount: int = 10) -> Array:
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
	
	return (await _make_request("https://api.spotify.com/v1/me/top/tracks", body))["items"];

func _get_env_vars() -> Dictionary:
	var file := FileAccess.open("res://.env", FileAccess.READ);
	var content = file.get_as_text(true)
	var variables: Dictionary;
	
	for line in content.split("\n", false):
		var info = line.split("=");
		variables[info[0]] = info[1];
	
	return variables;

func _make_request(endpoint: String, body: Array[String]):
	var headers = [
		"Authorization: Bearer %s" % _token
	]
	headers = PackedStringArray(headers);
	var body_str = "&".join(PackedStringArray(body));
	
	var request := HTTPRequest.new();
	add_child(request);
	
	var err = request.request(
		endpoint+"?"+body_str,
		headers, 
		HTTPClient.METHOD_GET
	);
	
	if err != OK:
		printerr("Error making request to %s. Error: %s" % [endpoint, err]);
		
	var response = await request.request_completed;
	var res_body = JSON.parse_string(response[3].get_string_from_utf8());
	
	return res_body;

func _generate_code_verifier(length: int):
	length = clamp(length, 43, 128);
	var code: String;
	var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789-._~";
	
	for i in range(length):
		code += possible[randi_range(0, possible.length()-1)];
		
	return code;
	
func _generate_code_challenge(verifier: String):
	var challenge = Marshalls.raw_to_base64(verifier.sha256_text().hex_decode());
	return challenge.replace("=", "").replace("+","-").replace("/","_");
	
	
