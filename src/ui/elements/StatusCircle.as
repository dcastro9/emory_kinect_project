package ui.elements
{
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterType;
	
	public class StatusCircle extends Sprite
	{
		private var myBevel:BevelFilter;
		
		private var status:Boolean;
		
		public function StatusCircle(color:uint=0x666666)
		{
			super();
			status = false;
			this.graphics.beginFill(color);
			this.graphics.drawCircle(5,5,12);
			this.graphics.endFill();
			
			myBevel = new BevelFilter()
			myBevel.type = BitmapFilterType.FULL;
			myBevel.distance = 1;
			myBevel.highlightColor = 0x222222;
			myBevel.shadowColor = 0x444444;
			myBevel.blurX = 20;
			myBevel.blurY = 20;
			
			this.filters = [myBevel];
		}
		
		// Default status is success (i.e. color is green).
		public function updateStatus(color:uint=0x23bc00):void {
			if (color == 0x23bc00) {
				status = true;
			}
			else {
				status = false;
			}
			this.graphics.clear();
			this.graphics.beginFill(color);
			this.graphics.drawCircle(5,5,12);
			this.graphics.endFill();
		}
		
		public function getStatus():Boolean {
			return status;
		}
	}
}