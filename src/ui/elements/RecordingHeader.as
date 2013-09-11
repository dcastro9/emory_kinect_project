package ui.elements
{
	import flash.text.TextField;
	
	public class RecordingHeader extends TextField
	{
		public static const activeColor:uint = 0xFF0000;
		public static const deactiveColor:uint = 0x666666;
		public function RecordingHeader()
		{
			super();
		}
		
		public function activate():void {
			this.textColor = activeColor;
		}
		public function deactivate():void {
			this.textColor = deactiveColor;
		}
	}
}