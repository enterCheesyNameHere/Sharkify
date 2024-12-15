using System.Collections.Generic;
using Microsoft.Xna.Framework;
using Sharkify.Components;

namespace Sharkify.Entities;

public abstract class Entity
{	
	public string Id { get; init; } // Not implemented
	private List<Component> _ownedComponents = [];

	protected Entity()
	{
		EntityManager.RegisterEntity(this);
	}
	
	// Adds a given component to a list, and returns the added component.
	// If the type already exists, it returns the existing component
	public T AddComponent<T>(T component) where T : Component
	{
		// Need to check to make sure component type doesn't already exist
		foreach (var ownedComponent in _ownedComponents)
		{
			if (ownedComponent.GetType() == component.GetType())
				return (T) ownedComponent;
		}
			
		component.Owner = this;
		_ownedComponents.Add(component);
		
		return component;
	}
	
	public T AddComponent<T>() where T : Component, new()
	{
		var component = new T();

		return AddComponent(component);
	}

	public T GetComponent<T>() where T : Component
	{
		foreach (var component in _ownedComponents)
		{
			if (component.GetType() == typeof(T))
			{
				return (T) component;
			}
		}

		return null;
	}
	
	

	public void Update(GameTime gameTime)
	{
		foreach (var component in _ownedComponents)
		{
			component.Update(gameTime);
		}
	}
}