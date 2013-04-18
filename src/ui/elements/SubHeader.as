package ui.elements
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SubHeader extends Sprite
	{
		private var h2Format:TextFormat;
		
		public function SubHeader(width:int, height:int, subMenuText:String="Sub Menu Text", color:uint=0x333333, fontColor:uint=0xFFFFFF)
		{
			super();
			graphics.beginFill(color);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			h2Format = new TextFormat();
			h2Format.font = "SegoeUI";
			h2Format.size = 15;
			h2Format.color = fontColor;
			
			var header:TextField = new TextField();
			header.x = 60;
			header.y = 2;
			header.width = width;
			header.height = height;
			header.embedFonts = true;
			header.defaultTextFormat = h2Format;
			header.text = subMenuText;
			addChild(header);
		}
	}
}