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
		public var customLevel:Boolean = false;
		
		[Embed(source="assets/editor-tiles.png")]
		public static const EditTilesGfx: Class;
		
		public static var editTile:Spritemap = new Spritemap(EditTilesGfx, 8, 8);
		public static var palette:Entity = createPalette();
		public static var paletteClicked:Boolean = false;
		public static var paletteMouseover:Stamp;
		
		public var text:Text = new Text("", -1, -2, {size:8});
		
		public var id:int;
				
		public function Level (_id:int = 1, _data:BitmapData = null)
		{
			if (_id == 0) {
				customLevel = true;
			}
			
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
			FP.randomSeed = id;
			
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
			
			if (editMode) {
				addGraphic(editTile);
				add(palette);
			}
			
			addGraphic(text);
		}
		
		private static function createPalette ():Entity
		{
			var palette:Entity = new Entity;
			var tiles:Stamp = new Stamp(EditTilesGfx);
			palette.width = tiles.width;
			palette.height = tiles.height;
			
			palette.x = int((FP.width - palette.width)*0.5);
			palette.y = int((FP.height - palette.height)*0.5);
			
			var border:Stamp = new Stamp(new BitmapData(palette.width+2, palette.height+2, false, 0xFFFFFF));
			FP.rect.x = 1;
			FP.rect.y = 1;
			FP.rect.width = palette.width;
			FP.rect.height = palette.height;
			border.source.fillRect(FP.rect, 0x202020);
			
			border.x = -1;
			border.y = -1;
			
			paletteMouseover = new Stamp(new BitmapData(editTile.width+2, editTile.height+2, true, 0xFFFFFFFF));
			
			FP.rect.width = editTile.width;
			FP.rect.height = editTile.height;
			paletteMouseover.source.fillRect(FP.rect, 0x0);
			
			paletteMouseover.x = -1;
			paletteMouseover.y = -1;
			
			palette.graphic = new Graphiclist(border, tiles, paletteMouseover);
			
			return palette;
		}
		
		public function reset ():void
		{
			FP.world = new Level(id, data);
		}
		
		public function nextLevel ():void
		{
			FP.world = new Level(id+1);
		}
		
		public function clear ():void
		{
			data.fillRect(data.rect, 0);
			reloadState();
		}
		
		public override function update (): void
		{
			if (customLevel) {
				text.text = "Test mode";
			} else {
				text.text = "Level " + id;
			}
			
			if (Input.pressed(Key.R)) {
				reset();
				return;
			}
			
			if (! customLevel && Input.pressed(Key.N)) {
				nextLevel();
				return;
			}
			
			if (Input.pressed(Key.E)) {
				if (editMode) {
					editMode = false;
					reloadState();
				} else {
					var newLevel:Level = new Level(0, data);
				
					newLevel.editMode = true;
					newLevel.reloadState();
				
					FP.world = newLevel;
				}
				
				return;
			}
			
			Input.mouseCursor = "auto";
			
			if (editMode) {
				text.text = "Edit mode";
				
				if (Input.pressed(Key.SPACE)) {
					palette.visible = ! palette.visible;
				}
				
				// SPACE: Palette
				// E: Test
				// C: Clear
				// 0-9: choose tile
				
				hovering = null;
				dragging = null;
				
				if (Input.pressed(Key.C)) {
					clear();
				}
				
				for (var i:int = 0; i < 10; i++) {
					if (Input.pressed(Key.DIGIT_0 + i)) {
						editTile.frame = i;
					}
				}
				
				var mx:int = mouseX / Gem.SIZE;
				var my:int = mouseY / Gem.SIZE;
				
				var overPalette:Boolean = palette.visible && palette.collidePoint(palette.x, palette.y, mouseX, mouseY);
				
				if (overPalette) {
					editTile.alpha = 0;
					Input.mouseCursor = "button";
				} else {
					editTile.x = mx * Gem.SIZE;
					editTile.y = my * Gem.SIZE;
					editTile.alpha = 0.5;
				}
				
				if (palette.visible) {
					if (overPalette) {
						mx = mouseX - palette.x;
						my = mouseY - palette.y;
						
						mx /= editTile.width;
						my /= editTile.height;
						
						paletteMouseover.x = -1 + mx * 8;
						paletteMouseover.y = -1 + my * 8;
					} else {
						paletteMouseover.x = -1 + int(editTile.frame % 5) * 8;
						paletteMouseover.y = -1 + int(editTile.frame / 5) * 8;
					}
				}
				
				if (Input.mouseDown) {
					if (overPalette && Input.mousePressed) {
						
						
						editTile.frame = mx + (palette.width / Gem.SIZE) * my;
						
						paletteClicked = true;
					}
					
					if (! overPalette && ! paletteClicked) {
						var id:int = data.getPixel(mx, my);
					
						if (id != editTile.frame) {
							data.setPixel(mx, my, editTile.frame);
						
							reloadState();
						}
					}
					
					palette.visible = false;
				} else {
					paletteClicked = false;
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
			
			if (! customLevel) nextLevel();
			
			Logger.endLevel(id);
			
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
		
		public function copy ():String
		{
			var out:ByteArray = getWorldData();
			
			out.compress();
			
			return Base64.encode(out);
		}
		
		public function paste (input:String):void
		{
			try {
				var bytes:ByteArray = Base64.decode(input);
			
				if (bytes.length) {
					bytes.uncompress();
					setWorldData(bytes);
					id = 0;
					customLevel = true;
				}
			} catch (e:Error) {}
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
			
			if (version > 0) return;
			
			for (var j:int = 0; j < data.height; j++) {
				for (var i:int = 0; i < data.width; i++) {
					data.setPixel(i, j, input.readInt());
				}
			}
			
			reloadState();
		}
		
		public override function begin ():void
		{
			Logger.startLevel(id);
			super.begin();
		}
	}
}

