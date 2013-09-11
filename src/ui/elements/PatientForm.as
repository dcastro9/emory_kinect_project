package ui.elements
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class PatientForm extends Sprite
	{
		public static const ProcedureChoices:Array = new Array("Walking", "Jogging", "Running");
		
		private var idNumber:TextField;
		private var procedure:TextField;
		private var procChoice:RadioButton;
		private var comments:TextField;
		
		private var idLabel:TextField;
		private var procLabel:TextField;
		private var otherChoice:TextField;
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
			addChild(idNumber);
			
			procLabel = new TextField();
			procLabel.embedFonts = true;
			procLabel.defaultTextFormat = labelFormat;
			procLabel.y = (fieldHeight + padding);
			procLabel.width = fieldWidth;
			procLabel.height = fieldHeight;
			procLabel.text = "Procedure:";
			addChild(procLabel);
			procChoice = new RadioButton(ProcedureChoices, 80, 30, 0xCCCCCC, 0x000000, 0x66AAFF, clearProcedure);
			procChoice.x = 120;
			procChoice.y = fieldHeight + padding;
			addChild(procChoice);
			
			otherChoice = new TextField();
			otherChoice.embedFonts = true;
			otherChoice.defaultTextFormat = labelFormat;
			otherChoice.x = 90;
			otherChoice.y = 2*(fieldHeight + padding/2);
			otherChoice.width = fieldWidth;
			otherChoice.height = fieldHeight;
			otherChoice.text = "Other:";
			addChild(otherChoice);
			procedure = new TextField();
			procedure.border = true;
			procedure.background = true;
			procedure.backgroundColor = bgColor;
			procedure.width = fieldWidth/2;
			procedure.height = fieldHeight/1.5;
			procedure.x = 150;
			procedure.y = 2*(fieldHeight + padding/2);
			procedure.type = "input";
			procedure.embedFonts = true;
			procedure.defaultTextFormat = textFormat;
			procedure.addEventListener(Event.CHANGE, assessProcedure);
			addChild(procedure);
			
			commentsLabel = new TextField();
			commentsLabel.embedFonts = true;
			commentsLabel.defaultTextFormat = labelFormat;
			commentsLabel.y = 3*(fieldHeight + padding);
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
			comments.y = 3*(fieldHeight + padding);
			comments.type = "input";
			comments.embedFonts = true;
			comments.defaultTextFormat = commentFormat;
			addChild(comments);
		}
		
		public function getJSONString():String {
			return '{"id" : ' + idNumber.text + ', "procedure" : "' + getProcedure() + '", "comments" : "' + comments.text + '"}';
		}
		
		public function getPatientNumber():String {
			return idNumber.text;	
		}
		
		public function getProcedure():String {
			if (procedure.text != "") {
				return procedure.text;
			}
			else {
				return procChoice.getActiveButton();
			}
		}
		
		private function clearProcedure():void {
			procedure.text = "";
		}
		
		public function clearFields(event:Event):void {
			idNumber.text = "";
			procedure.text = "";
			comments.text = "";
			procChoice.resetToDefaultBackground();
		}
		
		private function assessProcedure(event:Event):void {
			if (event.currentTarget.text != "") {
				procChoice.resetToDefaultBackground();
			}
		}
	}
}