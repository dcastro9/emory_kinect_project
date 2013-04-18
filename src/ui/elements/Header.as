package ui.elements
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Header extends Sprite
	{
		private var h1Format:TextFormat;
		
		public function Header(width:int, height:int,text:String="Header", color:uint=0x222222, fontColor:uint=0xFFFFFF)
		{
			super();
			graphics.beginFill(color);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			h1Format = new TextFormat();
			h1Format.font = "SegoeUI";
			h1Format.size = 25;
			h1Format.color = fontColor;
			
			var header:TextField = new TextField();
			header.x = 60;
			header.y = 10;
			header.width = width;
			header.height = height;
			header.embedFonts = true;
			header.defaultTextFormat = h1Format;
			header.text = text;
			addChild(header);
		}
	}
}