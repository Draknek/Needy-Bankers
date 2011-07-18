package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Wall extends Entity
	{
		public function Wall (_x:int = 0, _y:int = 0)
		{
			x = _x * Gem.SIZE;
			y = _y * Gem.SIZE;
			
			type = "solid";
			
			setHitbox(Gem.SIZE, Gem.SIZE);
			
			graphic = Image.createRect(width+1, height+1, 0xA7A7A7);
		}
	}
}

