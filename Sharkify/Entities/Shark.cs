using Sharkify.Components;

namespace Sharkify.Entities;

// Prefab essentially
// Mainly used just to build out an entity with everything a shark needs.
// Right now the only component is transform though so that's all it gets
public class Shark : Entity
{
	public Shark()
	{
		AddComponent<Transform>();
	}
}