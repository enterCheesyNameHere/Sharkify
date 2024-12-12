using System;
using Sharkify;

using var game = new Sharkify.Game1();

Spotify.InitialAuthentication();

while (!Spotify.Authenticated) { }

var tracks = await Spotify.GetTopTracks();
foreach (var track in tracks)
{
	Console.WriteLine(track.Name);
}

game.Run();