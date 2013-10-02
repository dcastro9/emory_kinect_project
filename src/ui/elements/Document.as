package ui.elements
{
	import flash.display.Sprite;
	import flash.printing.PrintJob;
	
	public class Document extends Sprite
	{
		private var pages:Vector.<Page>;
		public function Document(numPages:int) {
			super();
			pages = new Vector.<Page>(numPages);
			for (var i:int = 0; i < numPages; i++) {
				pages[i] = new Page();
				trace("Adding page.");
			}
		}
		
		public function addPage(page:Page):void {
			pages[pages.length] = page;
		}
		
		public function printDocument(printJob:PrintJob):void {
			for (var i:int = 0; i < pages.length; i++) {
				printJob.addPage(pages[i] as Sprite);
			}
			printJob.send();
		}
		
		public function addHeader(pageNum:int, text:String):void {
			pages[pageNum].addHeader(text);
		}
		
		public function appendContent(pageNum:int, text:String):void {
			pages[pageNum].appendContent(text);
		}
		
		public function appendSprite(pageNum:int, sprite:Sprite):void {
			pages[pageNum].appendSprite(sprite);
		}
		
		public function getPage(pageNum:int):Page {
			return pages[pageNum];
		}
	}
}
