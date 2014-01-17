package ui.elements
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class RadioButton extends Sprite
	{
		public static const LeftPaddingPercentage:int = 20;
		private var buttons:Array;
		private var bgColor:uint;
		private var bgSelectedColor:uint;
		private var selectedButton:Button;
		private var listener:Function;
		
		public function RadioButton(elements:Array, width:int, height:int, bgColor:uint, fontColor:uint, bgSelectedColor:uint, listener:Function = null)
		{	
			this.buttons = new Array();
			this.bgColor = bgColor;
			this.bgSelectedColor = bgSelectedColor;
			this.listener = listener;
			
			var count:int = 0;
			// Create a button for each element in the array.
			for each (var element:String in elements) {
				buttons[count] = new Button(width, height, element, bgColor, fontColor);
				buttons[count].onClick(selectButton);
				buttons[count].x = count*width + count*width*LeftPaddingPercentage/100;		
				buttons[count].y = 0;
				addChild(buttons[count]);
				count++;
			}
			
			// We do this so its initialized, to deal with potential errors correctly.
			this.selectedButton = buttons[0];
		}
		
		private function selectButton(event:MouseEvent):void {
			// Disable all buttons to default background.
			resetToDefaultBackground();
			
			// Selects the current target (i.e. the button).
			event.currentTarget.setBackground(bgSelectedColor);
			selectedButton = event.currentTarget as Button;
			if (listener != null) {
				listener.call();
			}
		}
		
		public function getActiveButton():String {
			return selectedButton.getText();
		}
		
		public function resetToDefaultBackground():void {
			for each (var button:Button in buttons) {
				button.setBackground(bgColor);
			}
		}
	}
}