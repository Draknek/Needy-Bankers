package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Wall extends Entity
	{
		[Embed(source="assets/rocks.png")] public static const Gfx: Class;
		public function Wall (_x:int = 0, _y:int = 0)
		{
			x = _x * Gem.SIZE;
			y = _y * Gem.SIZE;
			
			type = "solid";
			
			setHitbox(Gem.SIZE, Gem.SIZE);
			
			var sprite:Spritemap = new Spritemap(Gfx, 8, 8);
			sprite.frame = FP.rand(sprite.frameCount);
			
			graphic = sprite;
		}
	}
}

