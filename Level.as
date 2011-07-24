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
		[Embed(source="assets/sheet-targets.png")] public static const TargetGfx: Class;
		
		public static const TILES_X:int = 15;
		public static const TILES_Y:int = 12;
		
		public var hovering:Gem;
		public var dragging:Gem;
		public var dragPoint:Point = new Point;
		
		public var data:BitmapData;
		
		public var editMode:Boolean = false;
		public static var paint:int = 0;
				
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
			
			reloadState();
		}
		
		private function reloadState ():void
		{
			removeAll();
			
			updateLists();
			
			var x:int, y:int;
			for (x = 0; x < data.width; x++) {
				for (y = 0; y < data.height; y++) {
					var id:int = data.getPixel(x, y);
					
					if (id == 5) add(new Wall(x,y, ! editMode));
					else if (id > 0 && id < 5) add(new Gem(x, y, 1, 1, id));
					else if (id > 5 && id <= 9) {
						var e:Entity = add(new Entity);
						e.layer = 10;
						
						var s:Spritemap = new Spritemap(TargetGfx, 8, 8);
						s.frame = id - 6;
						
						e.graphic = s;
						
						e.x = x*7;
						e.y = y*7;
					}
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
			
			if (Input.pressed(Key.E)) {
				if (editMode) {
					editMode = false;
					reloadState();
				} else {
					var newLevel:Level = new Level(data);
				
					newLevel.editMode = true;
					newLevel.reloadState();
				
					FP.world = newLevel;
				}
				
				return;
			}
			
			Input.mouseCursor = "auto";
			
			if (editMode) {
				hovering = null;
				dragging = null;
				
				if (Input.pressed(Key.C)) {
					data.fillRect(data.rect, 0);
					reloadState();
				}
				
				for (var i:int = 0; i < 10; i++) {
					if (Input.pressed(Key.DIGIT_0 + i)) {
						paint = i;
					}
				}
				
				if (Input.mouseDown) {
					var mx:int = mouseX / Gem.SIZE;
					var my:int = mouseY / Gem.SIZE;
					
					var id:int = data.getPixel(mx, my);
					
					if (id != paint) {
						data.setPixel(mx, my, paint);
						
						reloadState();
					}
				}
			} else {
				hovering = collidePoint("gem", mouseX, mouseY) as Gem;
			
				if (Input.mousePressed || (! dragging && Input.mouseDown)) {
					dragging = hovering;
					if (dragging) {
						dragPoint.x = coord(mouseX - dragging.x);
						dragPoint.y = coord(mouseY - dragging.y);
					}
				} else if (dragging) {
					var dx:int = coord(mouseX - dragPoint.x, TILES_X - dragging.width/Gem.SIZE + 1) - dragging.x;
					var dy:int = coord(mouseY - dragPoint.y, TILES_Y - dragging.height/Gem.SIZE + 1) - dragging.y;
				
					dx = FP.clamp(dx, -1, 1) * Gem.SIZE;
					dy = FP.clamp(dy, -1, 1) * Gem.SIZE;
				
					dragging.moveBy(dx, dy, ["gem","solid"], true);
				
					if (Input.mouseReleased) {
						dragging = null;
						doCombine();
					} 
				}
			
				if (dragging) {
					hovering = null;
				}
			
				if (hovering || dragging) Input.mouseCursor = "hand";
				
				super.update();
			}
		}
		
		public function doCombine ():void
		{
			var gem:Gem, gem2:Gem;
			var x2:int, y2:int;
			
			var gems:Array = [];
			
			updateLists();
			
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
		
		public static function coord(xy:Number, max:int = 100):int
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

