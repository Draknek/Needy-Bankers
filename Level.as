package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Level extends World
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public static const TILES_X:int = 15;
		public static const TILES_Y:int = 12;
		
		public var hovering:Gem;
		public var dragging:Gem;
		public var dragPoint:Point = new Point;
		
		public var data:BitmapData;
				
		public function Level (_data:BitmapData = null)
		{
			if (_data) {
				data = _data;
			} else {
				data = new BitmapData(TILES_X, TILES_Y, false, 0);
			
				for (var i:int = 0; i < 100; i++) {
					do {
						var x:int = FP.rand(TILES_X);
						var y:int = FP.rand(TILES_Y);
					
						if (data.getPixel(x, y)) continue;
						
						data.setPixel(x, y, FP.choose(1, 2, 3, 5));
					
						break;
					} while (true);
				}
			}
			
			for (x = 0; x < data.width; x++) {
				for (y = 0; y < data.height; y++) {
					var id:int = data.getPixel(x, y);
					
					if (id == 5) add(new Wall(x,y));
					else if (id) add(new Gem(x, y, 1, 1, id));
				}
			}
			
			doCombine();
			
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.R)) {
				FP.world = new Level(data);
				return;
			}
			
			Input.mouseCursor = "auto";
			
			hovering = collidePoint("gem", mouseX, mouseY) as Gem;
			
			if (Input.mousePressed || (! dragging && Input.mouseDown)) {
				dragging = hovering;
				if (dragging) {
					dragPoint.x = coord(mouseX - dragging.x, 100);
					dragPoint.y = coord(mouseY - dragging.y, 100);
				}
			} else if (dragging) {
				var dx:int = coord(mouseX - dragPoint.x, TILES_X - dragging.width/Gem.SIZE + 1) - dragging.x;
				var dy:int = coord(mouseY - dragPoint.y, TILES_Y - dragging.height/Gem.SIZE + 1) - dragging.y;
				
				dx = FP.clamp(dx, -1, 1) * Gem.SIZE;
				dy = FP.clamp(dy, -1, 1) * Gem.SIZE;
				
				dragging.moveBy(dx, dy, ["gem","solid","target"], true);
				
				if (Input.mouseReleased) {
					dragging = null;
				} 
			}
			
			if (dragging) {
				hovering = null;
			}
			
			if (hovering || dragging) Input.mouseCursor = "hand";
			
			doCombine();
			
			super.update();
		}
		
		public function doCombine ():void
		{
			var gem:Gem, gem2:Gem;
			var x2:int, y2:int;
			
			var gems:Array = [];
			
			do {
				var merged:int = 0;
				
				gems.length = 0;
			
				getType("gem", gems);
			
				for each (gem in gems) {
					if (gem == dragging || ! gem.width) continue;
				
					x2 = gem.x + gem.width + 1;
					y2 = gem.y + 1;
			
					gem2 = collidePoint("gem", x2, y2) as Gem;
				
					if (gem2 && gem2 != dragging && gem.height == gem2.height && gem.colorID == gem2.colorID && gem.y == gem2.y) {
						remove(gem2);
						gem.width += gem2.width;
						gem2.width = 0;
						gem.makeGraphic();
						merged++;
					}
				}
			
				updateLists();
			
				gems.length = 0;
			
				getType("gem", gems);
			
				for each (gem in gems) {
					if (gem == dragging || ! gem.width) continue;
				
					x2 = gem.x + 1;
					y2 = gem.y + gem.height + 1;
			
					gem2 = collidePoint("gem", x2, y2) as Gem;
				
					if (gem2 && gem2 != dragging && gem.width == gem2.width && gem.colorID == gem2.colorID && gem.x == gem2.x) {
						remove(gem2);
						gem.height += gem2.height;
						gem2.width = 0;
						gem.makeGraphic();
						merged++;
					}
				}
			
				updateLists();
			} while (merged > 0)
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

