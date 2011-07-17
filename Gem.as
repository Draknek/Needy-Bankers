package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Gem extends Entity
	{
		public static const SIZE:int = 7;
		
		[Embed(source="assets/1x1.png")] public static const Gfx1x1: Class;
		[Embed(source="assets/sheet.png")] public static const GfxLarger: Class;
		
		public var colorID:int;
		
		public static const COLORS:Array = ["green", "red", "blue"];
		
		public function Gem (_x:int = 0, _y:int = 0, width:int = 1, height:int = 1, _color:int = -1)
		{
			x = _x * SIZE;
			y = _y * SIZE;
			
			type = "gem";
			
			setHitbox(SIZE*width, SIZE*height);
			
			if (_color >= 0) {
				colorID = _color;
			} else {
				colorID = FP.rand(3);
			}
			
			makeGraphic();
		}
		
		public function makeGraphic ():void
		{
			if (width == SIZE && height == SIZE) {
				var sprite:Spritemap = new Spritemap(Gfx1x1, 8, 8);
			
				sprite.add("shine", FP.frames(10*colorID, 10*colorID + 9), 0.25);
				sprite.play("shine");
			
				//sprite.scaleX = width;
				//sprite.scaleY = height;
				
				graphic = sprite;
			} else {
				var data:BitmapData = new BitmapData(width, height, true, 0x0);
				var source:BitmapData = FP.getBitmap(GfxLarger);
				
				FP.rect.width = 8;
				FP.rect.height = 8;
				
				var maxX:int = width/SIZE - 1;
				var maxY:int = height/SIZE - 1;
				
				for (var i:int = 0; i <= maxX; i++) {
					for (var j:int = 0; j <= maxY; j++) {
						if (maxX == 0) {
							if (j == 0) {
								FP.rect.x = 24;
								FP.rect.y = 8;
							} else if (j == maxY) {
								FP.rect.x = 24;
								FP.rect.y = 16;
							} else {
								FP.rect.x = 32;
								FP.rect.y = 16;
							}
						} else if (maxY == 0) {
							if (i == 0) {
								FP.rect.x = 24;
								FP.rect.y = 0;
							} else if (i == maxX) {
								FP.rect.x = 32;
								FP.rect.y = 0;
							} else {
								FP.rect.x = 32;
								FP.rect.y = 8;
							}
						} else {
							if (i == 0) {
								FP.rect.x = 0;
							} else if (i == maxX) {
								FP.rect.x = 16;
							} else {
								FP.rect.x = 8;
							}
							
							if (j == 0) {
								FP.rect.y = 0;
							} else if (j == maxY) {
								FP.rect.y = 16;
							} else {
								FP.rect.y = 8;
							}
						}
						
						FP.rect.x += 40 * (colorID % 2);
						FP.rect.y += 24 * int(colorID / 2);
						
						FP.point.x = i*SIZE;
						FP.point.y = j*SIZE;
						
						data.copyPixels(source, FP.rect, FP.point, null, null, true);
					}
				}
				
				graphic = new Stamp(data);
			}
		}
		
		public override function update (): void
		{
			
		}
	}
}

