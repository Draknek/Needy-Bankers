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
		
		public var colorID:int;
		
		public function Target (_x:int, _y:int, _id:int)
		{
			colorID = _id - 6;
			
			layer = 10;
			
			var s:Spritemap = new Spritemap(Gfx, 8, 8);
			s.frame = colorID + 1;
			
			graphic = s;
			
			x = _x*7;
			y = _y*7;
			
			type = "target";
			
			setHitbox(Gem.SIZE, Gem.SIZE);
		}
	}
}

