package util.recorder
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.data.Serialize;
	import com.as3nui.nativeExtensions.air.kinect.data.UserFrame;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.UserFrameEvent;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getTimer;

	public class PatientRecorder
	{
		private var _isRecording:Boolean;
		
		private var _kinect:Kinect;
		
		private var _recordingStartTime:int;
		
		private var _exportDirectory:File;
		private var _exportSettingsFile:File;
		private var _exportRgbDirectory:File;
		private var _exportDepthDirectory:File;
		private var _exportUserFrameDirectory:File;
		
		private var patientNumber:String;
		private var description:String;
		
		public function PatientRecorder() {
		}
		
		public function isRecording():Boolean {
			return _isRecording;
		}
		
		public function startRecording(kinect:Kinect, exportDirectory:File):void {
			if (!_isRecording) {
				_isRecording = true;
				
				Serialize.init();
				
				_recordingStartTime = getTimer();
				_kinect = kinect;
				
				_exportDirectory = exportDirectory;
				
				_exportDirectory.createDirectory();
				
				trace("Exporting to:", _exportDirectory.nativePath);
				
				_exportSettingsFile = _exportDirectory.resolvePath("kinect_settings.json");
				var settingsFileStream:FileStream = new FileStream();
				settingsFileStream.open(_exportSettingsFile, FileMode.WRITE);
				settingsFileStream.writeUTFBytes(JSON.stringify(_kinect.settings));
				settingsFileStream.close();
				
				_exportRgbDirectory = _exportDirectory.resolvePath("rgb");
				_exportRgbDirectory.createDirectory();
				
				_exportDepthDirectory = _exportDirectory.resolvePath("depth");
				_exportDepthDirectory.createDirectory();
				
				_exportUserFrameDirectory = _exportDirectory.resolvePath("user");
				_exportUserFrameDirectory.createDirectory();
				
				_kinect.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbHandler, false, 0, true);
				_kinect.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthHandler, false, 0, true);
				_kinect.addEventListener(UserFrameEvent.USER_FRAME_UPDATE, userFrameUpdateHandler, false, 0, true);
			}
		}
		
		public function stopRecording(otherData:String=""):void {
			if (_isRecording) {
				_isRecording = false;
				if (_kinect) {
					_kinect.removeEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbHandler, false);
					_kinect.removeEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthHandler, false);
					_kinect.removeEventListener(UserFrameEvent.USER_FRAME_UPDATE, userFrameUpdateHandler, false);
				}
				
				// save the other data.
				var _patientDetailsFile:File = _exportDirectory.resolvePath("patient_details.json");
				var patientDetailsFileStream:FileStream = new FileStream();
				var settingsFileStream:FileStream = new FileStream();
				settingsFileStream.open(_patientDetailsFile, FileMode.WRITE);
				settingsFileStream.writeUTFBytes(otherData);
				settingsFileStream.close();
			}
		}
		
		public function getJSONKinectData():String {
			return JSON.stringify(_kinect.settings);
		}
		
		private function copySettings():void {
			_exportSettingsFile = _exportDirectory.resolvePath("settings.json");
		}
		
		protected function rgbHandler(event:CameraImageEvent):void {
			writeImageFrame(_exportRgbDirectory, event.imageData);
		}
		
		protected function depthHandler(event:CameraImageEvent):void {
			writeImageFrame(_exportDepthDirectory, event.imageData);
		}
		
		protected function userFrameUpdateHandler(event:UserFrameEvent):void {
			writeUserFrame(_exportUserFrameDirectory, event.userFrame);
		}
		
		private function writeImageFrame(frameDirectory:File, bmpData:BitmapData):void {
			var time:int = getTimer() - _recordingStartTime;
			var frameFile:File = frameDirectory.resolvePath("" + time);
			var fileStream:FileStream = new FileStream();
			fileStream.open(frameFile, FileMode.WRITE);
			fileStream.writeInt(bmpData.width);
			fileStream.writeInt(bmpData.height);
			fileStream.writeBytes(bmpData.getPixels(bmpData.rect));
			fileStream.close();
		}
		
		private function writeUserFrame(frameDirectory:File, userFrame:UserFrame):void {
			var time:int = getTimer() - _recordingStartTime;
			var frameFile:File = frameDirectory.resolvePath("" + time);
			var fileStream:FileStream = new FileStream();
			fileStream.open(frameFile, FileMode.WRITE);
			fileStream.writeObject(userFrame);
			fileStream.close();
		}
	}
}