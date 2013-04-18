package ui.elements
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Button extends Sprite
	{
		private var buttonText:TextField;
		
		public function Button(width:int, height:int, text:String, color:uint, fontColor:uint) {
			graphics.beginFill(color);
			graphics.drawRect(0,0,width,height);
			graphics.endFill();
			
			var buttonFormat:TextFormat = new TextFormat();
			buttonFormat.font = "SegoeUI";
			buttonFormat.size = 15;
			buttonFormat.color = fontColor;
			
			buttonText = new TextField();
			buttonText.x = 0.02*width;
			buttonText.y = 0.02*height;
			buttonText.width = width;
			buttonText.height = height;
			buttonText.embedFonts = true;
			buttonText.defaultTextFormat = buttonFormat;
			buttonText.text = text;
			addChild(buttonText);
			
			this.useHandCursor = true;
			this.buttonMode = true;
			this.mouseChildren = true;
		}
		
		public function onClick(listener:Function):void {
			this.addEventListener(MouseEvent.CLICK, listener);
		}
		
		public function setText(text:String):void {
			buttonText.text = text;
		}
	}
}