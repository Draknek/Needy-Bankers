package
{
	import flash.display.*;
	import flash.utils.*;
	import Playtomic.*;
	
	public class Logger
	{
		public static var isLocal:Boolean = false;
		
		private static var currentLevel:int = 0;
		private static var startTime:int = 0;
		
		public static function init (obj: DisplayObjectContainer): void
		{
			isLocal = (obj.stage.loaderInfo.loaderURL.substr(0, 7) == 'file://');
			
			if (isLocal) return;
			
			Log.View(Secret.PLAYTOMIC_SWFID, Secret.PLAYTOMIC_GUID, obj.stage.loaderInfo.loaderURL);
		}
		
		public static function startLevel (id:int): void
		{
			if (isLocal || ! id) return;
			
			if (id == currentLevel) {
				Log.LevelCounterMetric("restarted", l(id));
			} else {
				Log.LevelCounterMetric("started", l(id));
				startTime = getTimer();
				//trace("Started level " + id + " at " + startTime);
				currentLevel = id;
			}
		}

		public static function endLevel (id:int): void
		{
			if (isLocal || ! id) return;
			
			var time:int = getTimer() - startTime;
			
			time /= 1000;
			
			//trace("Completed " + id + " in " + time);
			
			Log.LevelCounterMetric("completed", l(id));
			
			Log.LevelAverageMetric("time", l(id), time);
		}
		
		private static function l (id:int):String
		{
			var version:String = "a";
			
			var s:String = version;
			
			if (id < 10) s += "0";
			
			s += id;
			
			return s;
		}
	}
}


