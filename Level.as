package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Level extends World
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public static const TILES_X:int = 25;
		public static const TILES_Y:int = 20;
		
		public var dragging:Gem;
		
		public function Level ()
		{
			var tmp:BitmapData = new BitmapData(TILES_X, TILES_Y, false, 0);
			
			for (var i:int = 0; i < 200; i++) {
				do {
					var x:int = FP.rand(TILES_X);
					var y:int = FP.rand(TILES_Y);
					
					if (tmp.getPixel(x, y)) continue;
				
					tmp.setPixel(x, y, 1);
					add(new Gem(x, y));
					
					break;
				} while (false);
			}
			//add(new Player());
		}
		
		public override function update (): void
		{
			if (Input.mousePressed) {
				dragging = collidePoint("gem", mouseX, mouseY) as Gem;
			} else if (Input.mouseReleased) {
				dragging = null;
			} else if (dragging) {
				var dx:int = coordX(mouseX) - dragging.x;
				var dy:int = coordY(mouseY) - dragging.y;
				
				dx = FP.clamp(dx, -1, 1) * Gem.SIZE;
				dy = FP.clamp(dy, -1, 1) * Gem.SIZE;
				
				dragging.moveBy(dx, dy, "gem", true);
			}
			super.update();
		}
		
		public static function coordX(xy:Number):int
		{
			return coord(xy, TILES_X);
		}
		
		public static function coordY(xy:Number):int
		{
			return coord(xy, TILES_Y);
		}
		
		public static function coord(xy:Number, max:int):int
		{
			var tile:int = int(xy / Gem.SIZE);
			
			if (tile < 0) tile = 0;
			else if (tile >= max) tile = max - 1;
			
			return tile * Gem.SIZE;
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

