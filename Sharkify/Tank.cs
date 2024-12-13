using System;
using System.Collections.Generic;
using System.ComponentModel;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using SpotifyAPI.Web;

namespace Sharkify;

public class Tank : GameComponent
{
	private List<Shark> sharks;

	public Tank(Game game) : base(game)
	{
		
	}
	
	public override void Initialize()
	{
		if (!Spotify.Authenticated)
			Console.Error.WriteLine(new Exception("Spotify not authenticated before tank initialization"));

		var tracks = Spotify.GetTopTracks().Result;
		foreach (var track in tracks)
		{
			var shark = new Shark(Game, track);
			
			Game.Components.Add(shark);
		}
	}
}