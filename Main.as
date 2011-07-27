package
{
	import net.flashpunk.*;
	
	public class Main extends Engine
	{
		public function Main () 
		{
			super(106, 85, 60, true);
			
			FP.screen.scale = 5;
			
			//FP.console.enable();
		}
		
		public override function init (): void
		{
			sitelock("draknek.org");
			
			LevelList.load();
			
			Audio.init(this);
			
			FP.world = new Level;
			
			super.init();
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) == 'file://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
			if (allowed is String) allowed = [allowed];
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) return true;
			}
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
	}
}

