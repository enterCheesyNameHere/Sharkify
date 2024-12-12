using System;
using System.Data;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;
using SpotifyAPI.Web;

namespace Sharkify;

public class Shark : DrawableGameComponent
{
	public Texture2D Sprite { get; private set; }

	public Vector2 Position;

	
	//public FullTrack Track { get; init; }

	private SpriteBatch _spriteBatch;
	private Vector2 _velocity;
	private Vector2 _nextPos;

	private const int BaseSpeed = 1; 
	
	public Shark(Game game/*, FullTrack track*/) : base(game)
	{
		_spriteBatch = new SpriteBatch(GraphicsDevice);
		
		//Track = track;
	}

	public override void Initialize()
	{
		Sprite = Game.Content.Load<Texture2D>("ball");
		
		// Place Shark at a random place in the tank:
		Position = GetRandomPosition();
	}

	public override void Update(GameTime gameTime)
	{
		// AI
		if (Vector2.Distance(Position, _nextPos) <= 0.1)
			_nextPos = GetRandomPosition();

		_velocity = (Position - _nextPos) / BaseSpeed;

		Position += _velocity * -gameTime.ElapsedGameTime.Milliseconds / 1000;
	}

	public override void Draw(GameTime gameTime)
	{
		_spriteBatch.Begin();
		_spriteBatch.Draw(Sprite, Position, Color.White);
		_spriteBatch.End();
		
		base.Draw(gameTime);
	}

	private Vector2 GetRandomPosition()
	{
		var pos = new Vector2();
		
		var rand = new Random();
		var bounds = Game.Window.ClientBounds.Size.ToVector2();
		var spriteSize = Sprite.Bounds.Size.ToVector2();
		
		pos.X = rand.Next() % (bounds.X - spriteSize.X);
		pos.Y = rand.Next() % (bounds.Y - spriteSize.Y);

		return pos;
	}
}