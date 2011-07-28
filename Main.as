package
{
	import net.flashpunk.*;
	
	import flash.desktop.*;
	import flash.events.*;
	import flash.system.*;
	import flash.ui.*;
	
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
			
			Logger.init(this);
			
			contextMenu.clipboardMenu = true;
			contextMenu.clipboardItems.copy = true;
			contextMenu.clipboardItems.paste = true;
			contextMenu.clipboardItems.clear = true;

			addEventListener(Event.COPY, copyHandler);
			addEventListener(Event.PASTE, pasteHandler);
			addEventListener(Event.CLEAR, clearHandler);
			
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
		
		private static function copyHandler(event:Event):void 
		{
			var level:Level = FP.world as Level;
			
			if (level) {
				System.setClipboard(level.copy());
			}
		}
		
		private static function pasteHandler(event:Event):void 
		{
			var clipboard:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			
			var level:Level = FP.world as Level;
			
			if (level) {
				level.paste(clipboard);
			}
		}
		
		private static function clearHandler(event:Event):void 
		{
			var level:Level = FP.world as Level;
			
			if (level) {
				level.clear();
			}
		}
	}
}

