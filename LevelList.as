package
{
	import flash.utils.*;
	
	public class LevelList
	{
		[Embed(source="assets/all.lvls", mimeType="application/octet-stream")]
		public static const LEVELS:Class;
		
		public static var levels:Array = [];
		
		public static function load():void
		{
			var data:ByteArray = new LEVELS;
			
			var count:int = data.readInt();
			
			for (var i:int = 0; i < count; i++) {
				var size:int = data.readInt();
				
				var levelData:ByteArray = new ByteArray;
			
				data.readBytes(levelData, 0, size);
				
				levels[i] = levelData;
			}
		}
	}
}

