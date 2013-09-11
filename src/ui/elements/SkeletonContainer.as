package ui.elements
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SkeletonContainer extends Sprite
	{
		private var height:int;
		private var width:int;
		private var headerText:TextField;
		public function SkeletonContainer(skeleton:Sprite,text:String, width:int, height:int, textFormat:TextFormat)
		{
			this.width = width;
			this.height = height;
			super();
			this.graphics.beginFill(0xAAAAAA);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			
			headerText = new TextField();
			headerText.embedFonts = true;
			headerText.defaultTextFormat = textFormat;
			headerText.text = text;
			headerText.x = 60;
			headerText.y = 8;
			headerText.textColor = 0x000000;
			headerText.width = width;
			addChild(headerText);
			addChild(skeleton);
		}
	}
}