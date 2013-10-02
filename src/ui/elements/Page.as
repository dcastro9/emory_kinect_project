package ui.elements
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Page extends Sprite
	{
		public const PAGE_MARGIN:int = 4;
		public const PAGE_WIDTH:int = 612;
		public const PAGE_HEIGHT:int = 792;
		
		private var header:TextField;
		private var content:TextField;
		
		private var headerTextFormat:TextFormat;
		private var contentTextFormat:TextFormat;
		
		public function Page() {
			
			// Setup text formatting for the header & content.
			headerTextFormat = new TextFormat();
			headerTextFormat.font = "SegoeUI";
			headerTextFormat.size = 5;
			headerTextFormat.color = 0x111111;
			
			contentTextFormat = new TextFormat();
			contentTextFormat.font = "SegoeUI";
			contentTextFormat.size = 2;
			contentTextFormat.color = 0x111111;
			
			// Header is always at the top, respective to margin.
			header = new TextField();
			header.defaultTextFormat = headerTextFormat;
			header.text = "--- Page Header ---";
			header.x = PAGE_MARGIN;
			header.y = PAGE_MARGIN;
			addChild(header);
			
			// Content goes below the header.
			content = new TextField();
			content.defaultTextFormat = contentTextFormat;
			content.text = "";
			content.x = PAGE_MARGIN;
			content.y = PAGE_MARGIN + 6;
			content.wordWrap = true;
			addChild(content);
			
			this.width = 612;
			this.height = 792;
			super();
		}
		
		public function addHeader(text:String):void {
			header.text = text;
		}
		
		public function appendContent(text:String):void {
			content.text += text;
		}
		
		public function clearContent():void {
			content.text = "";
		}
		
		public function appendSprite(sprite:Sprite):void {
			
		}
	}
}

