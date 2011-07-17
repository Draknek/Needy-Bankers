package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Gem extends Entity
	{
		public static const SIZE:int = 24;
		
		public function Gem (_x:int = 0, _y:int = 0)
		{
			x = _x * SIZE;
			y = _y * SIZE;
			
			type = "gem";
			
			setHitbox(SIZE, SIZE);
			
			graphic = Image.createRect(SIZE, SIZE, 0xFF0000);
		}
		
		public override function update (): void
		{
			
		}
	}
}

