using System;
using System.Collections.Generic;

using Sharkify.Components;
using Sharkify.Entities;

namespace Sharkify;

public static class EntityManager
{
	private static List<Entity> RegisteredEntities = [];
	private static List<Component> RegisteredComponents = [];

	public static void RegisterComponent(Component component)
	{
		RegisteredComponents.Add(component);
	}

	public static void RegisterComponents(IEnumerable<Component> components)
	{
		foreach (var component in components)
		{
			RegisterComponent(component);
		}
	}

	public static void RegisterEntity(Entity entity)
	{
		RegisteredEntities.Add(entity);	
	}

	public static void RegisterEntities(IEnumerable<Entity> entities)
	{
		foreach (var entity in entities)
		{
			RegisterEntity(entity);
		}
	}
}