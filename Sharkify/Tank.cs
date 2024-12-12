using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Content;

namespace Sharkify;

public class Tank : DrawableGameComponent
{
	private List<Shark> sharks;
	
	private ContentManager Content { get; init; }

	public Tank(Game game, IServiceProvider serviceProvider) : base(game)
	{
		Content = new ContentManager(serviceProvider, "content");
		
	}
	
	
}