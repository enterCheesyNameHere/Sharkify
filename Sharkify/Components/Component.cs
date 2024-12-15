using Microsoft.Xna.Framework;
using Sharkify.Entities;

namespace Sharkify.Components;

public abstract class Component
{
	public Entity Owner;

	protected Component()
	{
		EntityManager.RegisterComponent(this);
	}

	// For now this is where local systems live. 
	// I'll work on a more refined process when I get to systems.
	public virtual void Update(GameTime gameTime) {}

}