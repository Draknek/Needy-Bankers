package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Target extends Entity
	{
		[Embed(source="assets/sheet-targets.png")] public static const Gfx: Class;
		
		public var id:int;
		
		public function Target (_x:int, _y:int, _id:int)
		{
			id = _id - 5;
			
			layer = 10;
			
			var s:Spritemap = new Spritemap(Gfx, 8, 8);
			s.frame = id;
			
			graphic = s;
			
			x = _x*7;
			y = _y*7;
			
			type = "target";
			
			setHitbox(Gem.SIZE, Gem.SIZE);
		}
	}
}

