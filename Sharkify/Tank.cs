using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;

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
			throw new Exception("Spotify not authenticated before tank initialization");

		var tracks = Spotify.GetTopTracks().Result;
		foreach (var track in tracks)
		{
			var shark = new Shark(Game, track);
			
			Game.Components.Add(shark);
		}
	}
}