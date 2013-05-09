package ui.elements
{	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class PatientForm extends Sprite
	{
		
		private var idNumber:TextField;
		private var procedure:TextField;
		private var comments:TextField;
		
		private var idLabel:TextField;
		private var procLabel:TextField;
		private var commentsLabel:TextField;
		
		private var textFormat:TextFormat;
		private var commentFormat:TextFormat;
		private var labelFormat:TextFormat;
		
		public function PatientForm(fieldHeight:int = 45, fieldWidth:int = 400, padding:int=15, bgColor:uint=0xFFFFFF)
		{
			super();
			
			textFormat = new TextFormat();
			textFormat.font = "SegoeUI";
			textFormat.size = 20;
			
			commentFormat = new TextFormat();
			commentFormat.font = "SegoeUI";
			commentFormat.size = 18;
			
			labelFormat = new TextFormat();
			labelFormat.font = "SegoeUI";
			labelFormat.color = 0x222222;
			labelFormat.size = 20;
			
			idLabel = new TextField();
			idLabel.embedFonts = true;
			idLabel.defaultTextFormat = labelFormat;
			idLabel.width = fieldWidth;
			idLabel.height = fieldHeight;
			idLabel.text = "Patient ID:";
			addChild(idLabel);
			
			idNumber = new TextField();
			idNumber.border = true;
			idNumber.background = true;
			idNumber.backgroundColor = bgColor;
			idNumber.width = fieldWidth;
			idNumber.height = fieldHeight;
			idNumber.x = 120;
			idNumber.y = 0;
			idNumber.type = "input";
			idNumber.embedFonts = true;
			idNumber.defaultTextFormat = textFormat;
			idNumber.restrict = "0123456789";
			idNumber.maxChars = 15; // TODO(dcastro9): Update with appropriate number.
			addChild(idNumber);
			
			procLabel = new TextField();
			procLabel.embedFonts = true;
			procLabel.defaultTextFormat = labelFormat;
			procLabel.y = (fieldHeight + padding);
			procLabel.width = fieldWidth;
			procLabel.height = fieldHeight;
			procLabel.text = "Procedure:";
			addChild(procLabel);
			procedure = new TextField();
			procedure.border = true;
			procedure.background = true;
			procedure.backgroundColor = bgColor;
			procedure.width = fieldWidth;
			procedure.height = fieldHeight;
			procedure.x = 120;
			procedure.y = fieldHeight + padding;
			procedure.type = "input";
			procedure.embedFonts = true;
			procedure.defaultTextFormat = textFormat;
			addChild(procedure);
			
			commentsLabel = new TextField();
			commentsLabel.embedFonts = true;
			commentsLabel.defaultTextFormat = labelFormat;
			commentsLabel.y = 2*(fieldHeight + padding);
			commentsLabel.width = fieldWidth;
			commentsLabel.height = fieldHeight;
			commentsLabel.text = "Comments:";
			addChild(commentsLabel);
			comments = new TextField();
			comments.multiline = true;
			comments.border = true;
			comments.background = true;
			comments.backgroundColor = bgColor;
			comments.width = fieldWidth;
			comments.height = fieldHeight*2;
			comments.x = 120;
			comments.y = 2*(fieldHeight + padding);
			comments.type = "input";
			comments.embedFonts = true;
			comments.defaultTextFormat = commentFormat;
			addChild(comments);
		}
		
		public function getJSONString():String {
			return '{"id" : ' + idNumber.text + ', "procedure" : "' + procedure.text + '", "comments" : "' + comments.text + '"}';
		}
		
		public function getPatientNumber():String {
			return idNumber.text;	
		}
		
		public function clearFields():void {
			idNumber.text = "";
			procedure.text = "";
			comments.text = "";
		}
	}
}