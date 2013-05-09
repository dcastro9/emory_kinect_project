package
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceErrorEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceInfoEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import ui.elements.Button;
	import ui.elements.Header;
	import ui.elements.PatientForm;
	import ui.elements.StatusCircle;
	import ui.elements.SubHeader;
	
	import util.recorder.PatientRecorder;
	
	
	[SWF(frameRate="60", backgroundColor="#DDDDDD", width="1000", height="1000")]
	public class Main extends Sprite
	{
		// Defaults
		public static const KinectMaxDepthInFlash:uint = 200;
		public static const WindowWidth:uint = 1000;
		public static const WindowHeight:uint = 600;
		[Embed(source="../fonts/segoeui.ttf", embedAsCFF="false", fontName="SegoeUI")]
		public static const FONT_MARKER:String;
		// Edit this to change where the patient data is saved.
		public static const filePath:String = "C:/Users/kinectpc/Patient Data/";
		
		// General Kinect Settings
		private var settings:KinectSettings;
		
		// Kinect 1 Properties
		private var device1:Kinect;
		private var depthSkeletonContainer1:Sprite;
		private var exportDirectoryK1:File;
		
		// Kinect 2 Properties
		private var device2:Kinect;
		private var depthSkeletonContainer2:Sprite;
		private var exportDirectoryK2:File;
		
		// Errors
		public var deviceMessagesField:TextField;
		public var debugMessagesField:TextField;
		
		// General Text Formatting
		public var textFormat:TextFormat;
		
		// General UI Objects
		private var header:Header;
		private var subHeader:SubHeader;
		private var k1status:StatusCircle;
		private var k2status:StatusCircle;
		private var form:PatientForm;
		private var startButton:Button;
		
		// Kinect Recorder
		private var recorder1:PatientRecorder;
		private var recorder2:PatientRecorder;
		
		public function Main() {
			if (Kinect.isSupported()) {
				// Connect the devices.
				device1 = Kinect.getDevice(0);
				device2 = Kinect.getDevice(1);
				
				// Create the recorder
				recorder1 = new PatientRecorder();
				recorder2 = new PatientRecorder();
				
				// Create the UI components to display for Kinect 1.
				depthSkeletonContainer1 = new Sprite();
				depthSkeletonContainer1.x = 0;
				depthSkeletonContainer1.y = 480;
				addChild(depthSkeletonContainer1);
				
				// Create the UI components to display for Kinect 2.
				depthSkeletonContainer2 = new Sprite();
				depthSkeletonContainer2.x = 640;
				depthSkeletonContainer2.y = 480;
				addChild(depthSkeletonContainer2);
				
				// Setup formatting for text.
				textFormat = new TextFormat();
				textFormat.font = "SegoeUI";
				
				// Instantiate the text fields.
				debugMessagesField = new TextField(); // Stores info details.
				
				deviceMessagesField = new TextField();
				deviceMessagesField.wordWrap = true;
				formatStatusLog(deviceMessagesField);
				addChild(deviceMessagesField);
				
				// Create General UI Objects
				// Menu
				header = new Header(WindowWidth, 60, "Kinect Recording");
				k1status = new StatusCircle();
				k1status.x = 0.92*WindowWidth;
				k1status.y = 25;
				k2status = new StatusCircle();
				k2status.x = 0.92*WindowWidth + 48;
				k2status.y = 25;
				header.addChild(k1status);
				header.addChild(k2status);
				addChild(header);
				// Sub Menu
				subHeader = new SubHeader(WindowWidth, 30, "Please add the patient ID prior to clicking 'Start'. You must add the procedure/comments before clicking stop :).");
				subHeader.x = 0;
				subHeader.y = 60;
				addChild(subHeader);
				// Form
				form = new PatientForm();
				form.x = 60;
				form.y = 140;
				addChild(form);
				// Buttons
				startButton = new Button(110,30, "Start Recording", 0x111111, 0xDDDDDD);
				startButton.x = 450;
				startButton.y = 380;
				startButton.onClick(toggleRecordingHandler);
				startButton.addEventListener(MouseEvent.ROLL_OVER, overHand);
				startButton.addEventListener(MouseEvent.ROLL_OUT, outHand);
				addChild(startButton);
				
				
				// Add the Event Listeners to Kinect 1.
				device1.addEventListener(DeviceEvent.STARTED, kinect1StartedHandler, false, 0, true);
				device1.addEventListener(DeviceEvent.STOPPED, kinect1StoppedHandler, false, 0, true);
				device1.addEventListener(DeviceInfoEvent.INFO, onDeviceInfo, false, 0, true);
				device1.addEventListener(DeviceErrorEvent.ERROR, onDevice1Error, false, 0, true);
				
				// Add the Event Listeners to Kinect 2.
				device2.addEventListener(DeviceEvent.STARTED, kinect2StartedHandler, false, 0, true);
				device2.addEventListener(DeviceEvent.STOPPED, kinect2StoppedHandler, false, 0, true);
				device2.addEventListener(DeviceInfoEvent.INFO, onDeviceInfo, false, 0, true);
				device2.addEventListener(DeviceErrorEvent.ERROR, onDevice2Error, false, 0, true);
				
				settings = new KinectSettings();
				settings.rgbEnabled = true;
				settings.rgbResolution = CameraResolution.RESOLUTION_160_120;
				settings.depthEnabled = true;
				settings.depthResolution = CameraResolution.RESOLUTION_640_480;
				settings.depthShowUserColors = false;
				settings.skeletonEnabled = true;
				settings.handTrackingEnabled = false;
				
				device1.start(settings);
				device2.start(settings);
				
				addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);	
			}
		}
		
		private function onDeviceInfo(event:DeviceInfoEvent):void {
			debugMessagesField.text += "INFO: " + event.message + "\n";
		}
		
		private function onDevice1Error(event:DeviceErrorEvent):void {
			deviceMessagesField.text = "ERROR: Kinect 1 " + event.message + "\n" + deviceMessagesField.text;
			k1status.updateStatus(0xcb2300);
		}
		
		private function onDevice2Error(event:DeviceErrorEvent):void {
			deviceMessagesField.text = "ERROR: Kinect 2 " + event.message + "\n" + deviceMessagesField.text;
			k2status.updateStatus(0xcb2300);
		}
		
		protected function kinect1StartedHandler(event:DeviceEvent):void {
			deviceMessagesField.text = "Kinect 1 has been initialized.\n" + deviceMessagesField.text;
			k1status.updateStatus();
		}
		
		protected function kinect2StartedHandler(event:DeviceEvent):void {
			deviceMessagesField.text = "Kinect 2 has been initialized.\n" + deviceMessagesField.text;
			k2status.updateStatus();
		}
		
		protected function kinect1StoppedHandler(event:DeviceEvent):void {
			deviceMessagesField.text = "Kinect 1 has stopped [restart app].\n" + deviceMessagesField.text;
			k1status.updateStatus(0xcb2300);
		}
		
		protected function kinect2StoppedHandler(event:DeviceEvent):void {
			deviceMessagesField.text = "Kinect 2 has stopped [restart app]\n" + deviceMessagesField.text;
			k2status.updateStatus(0xcb2300);
		}
		
		protected function toggleRecordingHandler(event:Event):void {
			if (recorder1.isRecording() && recorder2.isRecording()) {
				startButton.setText("Start Recording");
				recorder1.stopRecording(form.getJSONString());
				recorder2.stopRecording(form.getJSONString());
				
				// Report success, and clear fields for next patient.
				deviceMessagesField.text = "Patient " + form.getPatientNumber() + " saved.\n" + deviceMessagesField.text;
				form.clearFields();
			}
			else if (!recorder1.isRecording() && !recorder2.isRecording() && form.getPatientNumber() != "") {
				startButton.setText("Stop Recording");
				exportDirectoryK1 = File.documentsDirectory.resolvePath(filePath + form.getPatientNumber() +  "/" + "Kinect1/");
				exportDirectoryK2 = File.documentsDirectory.resolvePath(filePath + form.getPatientNumber() +  "/" + "Kinect2/");
				recorder1.startRecording(device1, exportDirectoryK1);
				recorder2.startRecording(device2, exportDirectoryK2);
			}
			else {
				deviceMessagesField.text = "Please input patient number.\n" + deviceMessagesField.text;
			}
		}
		
		protected function enterFrameHandler(event:Event):void {
			depthSkeletonContainer1.graphics.clear();
			depthSkeletonContainer2.graphics.clear();
			
			for each(var user1:User in device1.users) {
				if (user1.hasSkeleton) {
					for each(var joint1:SkeletonJoint in user1.skeletonJoints) {
						depthSkeletonContainer1.graphics.beginFill(0xFF0000, joint1.positionConfidence);
						depthSkeletonContainer1.graphics.drawCircle(joint1.position.depth.x, joint1.position.depth.y, 5);
						depthSkeletonContainer1.graphics.endFill();
					}
				}
			}
			for each(var user2:User in device2.users) {
				if (user2.hasSkeleton) {
					for each(var joint2:SkeletonJoint in user2.skeletonJoints) {
						depthSkeletonContainer2.graphics.beginFill(0xFF0000, joint2.positionConfidence);
						depthSkeletonContainer2.graphics.drawCircle(joint2.position.depth.x, joint2.position.depth.y, 5);
						depthSkeletonContainer2.graphics.endFill();
					}
				}
			}
		}
		
		private function overHand(e:MouseEvent):void {
			Mouse.cursor=MouseCursor.BUTTON;
		}
		
		private function outHand(e:MouseEvent):void {
			Mouse.cursor=MouseCursor.ARROW;
		}
		
		/** Helper Function **/
		// Should be its own class with more functionality (like add new status, etc). Also should have an addText with latest message first.
		private function formatStatusLog(deviceMessagesField:TextField):void {
			deviceMessagesField.embedFonts = true;
			deviceMessagesField.defaultTextFormat = textFormat;
			deviceMessagesField.width = 215;
			deviceMessagesField.height = 508;
			deviceMessagesField.background = true;
			deviceMessagesField.backgroundColor = 0xEEEEEE;
			deviceMessagesField.textColor = 0x222222;
			deviceMessagesField.border = true;
			deviceMessagesField.borderColor = 0x000000;
			deviceMessagesField.x = WindowWidth - deviceMessagesField.width - 2;
			deviceMessagesField.y = WindowHeight - deviceMessagesField.height - 2;
			deviceMessagesField.text = "STATUS LOG\n";
		}
	}
}