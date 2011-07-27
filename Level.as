package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class Level extends LoadableWorld
	{
		public static const TILES_X:int = 15;
		public static const TILES_Y:int = 12;
		
		public var hovering:Gem;
		public var dragging:Gem;
		public var dragPoint:Point = new Point;
		
		public var data:BitmapData;
		
		public var editMode:Boolean = false;
		public static var paint:int = 0;
		
		public var text:Text = new Text("", -1, -2, {size:8});
		
		public var id:int;
				
		public function Level (_id:int = 0, _data:BitmapData = null)
		{
			if (_id == 0) _id = 1;
			if (_id >= LevelList.levels.length) _id = 1;
			
			id = _id;
			
			if (_data) {
				data = _data;
				reloadState();
			} else {
				data = new BitmapData(TILES_X, TILES_Y, false, 0);
				
				setWorldData(LevelList.levels[id]);
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
					else if (id > 5 && id <= 9) add(new Target(x, y, id));
				}
			}
			
			doCombine();
			
			addGraphic(text);
		}
		
		public function reset ():void
		{
			FP.world = new Level(id, data);
		}
		
		public function nextLevel ():void
		{
			FP.world = new Level(id+1);
		}
		
		public override function update (): void
		{
			text.text = "Level " + id;
			
			if (Input.pressed(Key.R)) {
				reset();
				return;
			}
			
			if (Input.pressed(Key.N)) {
				nextLevel();
				return;
			}
			
			if (Input.pressed(Key.E)) {
				if (editMode) {
					editMode = false;
					reloadState();
				} else {
					var newLevel:Level = new Level(id, data);
				
					newLevel.editMode = true;
					newLevel.reloadState();
				
					FP.world = newLevel;
				}
				
				return;
			}
			
			Input.mouseCursor = "auto";
			
			if (editMode) {
				text.text = "Edit mode";
				
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
			
				if (! dragging && hovering && Input.mouseDown) {
					dragging = hovering;
					dragPoint.x = coord(mouseX - dragging.x);
					dragPoint.y = coord(mouseY - dragging.y);
					
					Audio.play("click");
				} else if (dragging) {
					var dx:int = coord(mouseX - dragPoint.x, TILES_X - dragging.width/Gem.SIZE + 1) - dragging.x;
					var dy:int = coord(mouseY - dragPoint.y, TILES_Y - dragging.height/Gem.SIZE + 1) - dragging.y;
				
					dx = FP.clamp(dx, -1, 1) * Gem.SIZE;
					dy = FP.clamp(dy, -1, 1) * Gem.SIZE;
				
					dragging.moveBy(dx, dy, ["gem","solid"], true);
				
					if (Input.mouseReleased) {
						dragging = null;
						doCombine(true);
						testComplete();
					} 
				}
			
				if (dragging) {
					hovering = null;
				}
			
				if (hovering || dragging) Input.mouseCursor = "hand";
				
				super.update();
			}
		}
		
		public function testComplete ():Boolean
		{
			var gems:Array = [];
			
			getType("gem", gems);
			
			for each (var gem:Gem in gems) {
				for (var i:int = 2; i < gem.width; i += Gem.SIZE) {
					for (var j:int = 2; j < gem.height; j += Gem.SIZE) {
						var e:Entity = collidePoint("target", gem.x + i, gem.y + j);
						
						if (! e) return false;
						
						var t:Target = e as Target;
						
						if (t.colorID != gem.colorID) return false;
					}
				}
			}
			
			nextLevel();
			
			Audio.play("complete");
			
			return true;
		}
		
		public function doCombine (playSfx:Boolean = false):void
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
				
				if (playSfx && merged > 0) {
					Audio.play("attach");
					playSfx = false;
				}
			} while (merged > 0);
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
		
		public override function getWorldData (): *
		{
			var out:ByteArray = new ByteArray;
			
			const version:int = 0;
			
			out.writeInt(version);
			
			for (var j:int = 0; j < data.height; j++) {
				for (var i:int = 0; i < data.width; i++) {
					out.writeInt(data.getPixel(i, j));
				}
			}
			
			return out;
		}
		
		public override function setWorldData (input: ByteArray): void {
			removeAll();
			
			input.position = 0;
			
			var version:int = input.readInt();
			
			for (var j:int = 0; j < data.height; j++) {
				for (var i:int = 0; i < data.width; i++) {
					data.setPixel(i, j, input.readInt());
				}
			}
			
			reloadState();
		}
	}
}

