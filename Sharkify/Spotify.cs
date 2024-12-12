using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SpotifyAPI.Web;
using SpotifyAPI.Web.Auth;

namespace Sharkify;

// Handles spotify interactions
public static class Spotify
{
	public static bool Authenticated { get; private set; }
	
	private static EmbedIOAuthServer _server;
	private static string _verifier;
	private static ISpotifyClient _client;
	
	// Runs the initial authentication for the app
	// Probably will want to rework when I start maximizing how long the app can run, but for now this'll work
	public static async void InitialAuthentication()
	{
		(_verifier, var challenge) = PKCEUtil.GenerateCodes();
		
		var loginRequest = new LoginRequest(
			new Uri("http://localhost:5543/callback"),
			"fd08f5f1bd0449f18d42c2459962153a",
			LoginRequest.ResponseType.Code
		)
		{
			CodeChallengeMethod = "S256",
			CodeChallenge = challenge,
			Scope = new[] { Scopes.UserTopRead }
		};
		var uri = loginRequest.ToUri();
		
		var info = new System.Diagnostics.ProcessStartInfo
		{
			FileName = uri.ToString(),
			UseShellExecute = true
		};
		
		System.Diagnostics.Process.Start(info);

		_server = new EmbedIOAuthServer(new Uri("http://localhost/callback"), 5543);
		await _server.Start();

		_server.AuthorizationCodeReceived += GetCallback;
		
	}
	
	private static async Task GetCallback(object sender, AuthorizationCodeResponse response)
	{
		await _server.Stop();
		
		var initialResponse = await new OAuthClient().RequestToken(
			new PKCETokenRequest("fd08f5f1bd0449f18d42c2459962153a", response.Code, new Uri("http://localhost:5543/callback"), _verifier)
		);

		var authenticator = new PKCEAuthenticator("fd08f5f1bd0449f18d42c2459962153a", initialResponse);
		var config = SpotifyClientConfig.CreateDefault().WithAuthenticator(authenticator);

		_client = new SpotifyClient(config);
		Authenticated = true;
	}

	public static async Task<List<FullTrack>> GetTopTracks(int limit = 10, int offset = 0)
	{
		var req = new UsersTopItemsRequest(TimeRange.MediumTerm)
		{
			Limit = limit,
			Offset = offset
		};
		
		var res = await _client.UserProfile.GetTopTracks(req);
		return res.Items;
	}

}