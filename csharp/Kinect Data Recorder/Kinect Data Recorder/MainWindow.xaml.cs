﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Timers;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Kinect;
using Kinect.Toolbox;
using Kinect.Toolbox.Record;
using System.IO;
using Microsoft.Win32;

namespace Kinect_Data_Recorder
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow
    {
        private static string KINECT_SSD_PATH = "A:/Patients/";
        private static string PROJECT_PATH = Directory.GetParent(Directory.GetCurrentDirectory()).Parent.FullName + "/";
        private KinectSensor[] kinectSensors = new KinectSensor[2];
        private Dictionary<string, Canvas> canvases = new Dictionary<string, Canvas>(2);
        private Dictionary<string, Image> displays = new Dictionary<string, Image>(2);
        private Dictionary<string, ColorStreamManager> colorManagers = new Dictionary<string, ColorStreamManager>(2);
        private Dictionary<string, DepthStreamManager> depthManagers = new Dictionary<string, DepthStreamManager>(2);
        private Dictionary<string, SkeletonDisplayManager> skeletonDisplayManagers = new Dictionary<string, SkeletonDisplayManager>(2);
        private Dictionary<string, KinectRecorder> recorders = null;
        readonly ContextTracker contextTracker = new ContextTracker();
        private bool recordNextFrameForPosture;
        private bool displayDepth;
        private bool recording = false;
        private KinectReplay replay;
        private Skeleton[] skeletons;

        void Kinects_StatusChanged(object sender, StatusChangedEventArgs e)
        {
            switch (e.Status)
            {
                //case KinectStatus.Connected:
                //    if (kinectSensor == null)
                //    {
                //        kinectSensor = e.Sensor;
                //        Initialize();
                //    }
                //    break;
                case KinectStatus.Disconnected:
                    if (kinectSensors[0] == e.Sensor || kinectSensors[1] == e.Sensor)
                    {
                        Clean(e.Sensor);
                        MessageBox.Show("Kinect was disconnected");
                    }
                    break;
                case KinectStatus.NotReady:
                    break;
                case KinectStatus.NotPowered:
                    if (kinectSensors[0] == e.Sensor || kinectSensors[1] == e.Sensor)
                    {
                        Clean(e.Sensor);
                        MessageBox.Show("Kinect is no longer powered");
                    }
                    break;
                default:
                    MessageBox.Show("Unhandled Status: " + e.Status);
                    break;
            }
        }

    

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                //listen to any status change for Kinects
                KinectSensor.KinectSensors.StatusChanged += Kinects_StatusChanged;

                //loop through all the Kinects attached to this PC, and start the first that is connected without an error.
                foreach (KinectSensor kinect in KinectSensor.KinectSensors)
                {
                    if (kinect.Status == KinectStatus.Connected)
                    {
                        if (kinectSensors[0] == null)
                        {
                            kinectSensors[0] = kinect;
                            string id = kinect.DeviceConnectionId;
                            canvases.Add(id, kinectCanvas1);
                            displays.Add(id, kinectDisplay1);
                            colorManagers.Add(id, new ColorStreamManager());
                            depthManagers.Add(id, new DepthStreamManager());
                        }
                        else if (kinectSensors[1] == null)
                        {
                            kinectSensors[1] = kinect;
                            string id = kinect.DeviceConnectionId;
                            canvases.Add(id, kinectCanvas2);
                            displays.Add(id, kinectDisplay2);
                            colorManagers.Add(id, new ColorStreamManager());
                            depthManagers.Add(id, new DepthStreamManager());
                            break;
                        }
                    }
                }

                if (KinectSensor.KinectSensors.Count == 0)
                    MessageBox.Show("No Kinect found. Please connect one.");
                else if (KinectSensor.KinectSensors.Count == 1)
                {
                    MessageBox.Show("Only one kinect connected. Please connect another");
                    Initialize();
                }
                else
                    Initialize();

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void Initialize()
        {
            for (int i = 0; i < kinectSensors.Length; i++)
            {

                if (kinectSensors[i] == null)
                    return;


                kinectSensors[i].ColorStream.Enable(ColorImageFormat.RgbResolution640x480Fps30);
                kinectSensors[i].ColorFrameReady += kinectRuntime_ColorFrameReady;

                kinectSensors[i].DepthStream.Enable(DepthImageFormat.Resolution320x240Fps30);
                kinectSensors[i].DepthFrameReady += kinectSensor_DepthFrameReady;

                kinectSensors[i].SkeletonStream.Enable(new TransformSmoothParameters
                {
                    Smoothing = 0.5f,
                    Correction = 0.5f,
                    Prediction = 0.5f,
                    JitterRadius = 0.05f,
                    MaxDeviationRadius = 0.04f
                });

                kinectSensors[i].SkeletonFrameReady += kinectRuntime_SkeletonFrameReady;

                string id = kinectSensors[i].DeviceConnectionId;
                skeletonDisplayManagers[id] = new SkeletonDisplayManager(kinectSensors[i], canvases[id]);

                kinectSensors[i].Start();

                
                displays[id].DataContext = colorManagers[id];
            }
        }

        void kinectSensor_DepthFrameReady(object sender, DepthImageFrameReadyEventArgs e)
        {
            if (replay != null && !replay.IsFinished)
                return;

            using (var frame = e.OpenDepthImageFrame())
            {
                if (frame == null)
                    return;
                string id = ((KinectSensor)sender).DeviceConnectionId;
                
                if (recording)
                {
                    KinectRecorder recorder = recorders[id];
                    if ((recorder.Options & KinectRecordOptions.Depth) != 0)
                    {
                        recorder.Record(frame);
                    }
                    
                }

                if (!displayDepth)
                    return;

                depthManagers[id].Update(frame);
            }
        }

        void kinectRuntime_ColorFrameReady(object sender, ColorImageFrameReadyEventArgs e)
        {
            if (replay != null && !replay.IsFinished)
                return;

            using (var frame = e.OpenColorImageFrame())
            {
                if (frame == null)
                    return;
                string id = ((KinectSensor)sender).DeviceConnectionId;
                
                if (recording)
                {
                    KinectRecorder recorder = recorders[id];
                    if ((recorder.Options & KinectRecordOptions.Color) != 0){
                        recorder.Record(frame);
                    }
                    
                }

                if (displayDepth)
                    return;

                colorManagers[id].Update(frame);
            }
        }

        void kinectRuntime_SkeletonFrameReady(object sender, SkeletonFrameReadyEventArgs e)
        {
            if (replay != null && !replay.IsFinished)
                return;

            using (SkeletonFrame frame = e.OpenSkeletonFrame())
            {
                if (frame == null)
                    return;
                string id = ((KinectSensor)sender).DeviceConnectionId;
                
                if (recording)
                {
                    KinectRecorder recorder = recorders[id];
                    if ((recorder.Options & KinectRecordOptions.Skeletons) != 0){
                        recorder.Record(frame);
                    }
                }
                    

                frame.GetSkeletons(ref skeletons);

                if (skeletons.All(s => s.TrackingState == SkeletonTrackingState.NotTracked))
                {
                    canvases[((KinectSensor)sender).DeviceConnectionId].Children.Clear();
                    return;
                }

                ProcessFrame(frame, sender);
            }
        }

        void ProcessFrame(ReplaySkeletonFrame frame, object sender)
        {
            Dictionary<int, string> stabilities = new Dictionary<int, string>();
            foreach (var skeleton in frame.Skeletons)
            {
                if (skeleton.TrackingState != SkeletonTrackingState.Tracked)
                    continue;

                contextTracker.Add(skeleton.Position.ToVector3(), skeleton.TrackingId);
                stabilities.Add(skeleton.TrackingId, contextTracker.IsStableRelativeToCurrentSpeed(skeleton.TrackingId) ? "Stable" : "Non stable");
                if (!contextTracker.IsStableRelativeToCurrentSpeed(skeleton.TrackingId))
                    continue;

                if (recordNextFrameForPosture)
                {
                    recordNextFrameForPosture = false;
                }
            }

            skeletonDisplayManagers[((KinectSensor) sender).DeviceConnectionId].Draw(frame.Skeletons, false);
        }
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            displayDepth = !displayDepth;

            if (displayDepth)
            {
                foreach (KinectSensor kinect in kinectSensors)
                {
                    string id = kinect.DeviceConnectionId;
                    displays[id].DataContext = depthManagers[id];
                }
            }
            else
            {
                foreach (KinectSensor kinect in kinectSensors)
                {
                    string id = kinect.DeviceConnectionId;
                    displays[id].DataContext = colorManagers[id];
                }
            }
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            foreach (KinectSensor kinectSensor in kinectSensors)
            {
                Clean(kinectSensor);
            }
        }

        private void Clean(KinectSensor kinectSensor)
        {
            string id = kinectSensor.DeviceConnectionId;
            if (recording){
                KinectRecorder recorder = recorders[id];
                recorder.Stop();
            }
            if (kinectSensor != null)
            {
                kinectSensor.DepthFrameReady -= kinectSensor_DepthFrameReady;
                kinectSensor.SkeletonFrameReady -= kinectRuntime_SkeletonFrameReady;
                kinectSensor.ColorFrameReady -= kinectRuntime_ColorFrameReady;
                kinectSensor.Stop();
                kinectSensor = null;
            }
        }

        private DispatcherTimer timer;
        private void timerInit()
        {
            timer = new DispatcherTimer(new TimeSpan(0, 0, 1), DispatcherPriority.Normal, delegate
            {

                string label = TimerLabel.Text;
                int min = Int32.Parse(label.Substring(0,2));
                int sec = Int32.Parse(label.Substring(3));
                sec++;
                if (sec >= 60)
                {
                    sec = 0;
                    min++;
                }
                string minS = min.ToString();
                string secS = sec.ToString();
                if (sec < 10)
                {
                    secS = "0" + secS;
                }
                if (min < 10)
                {
                    minS = "0" + minS;
                }
                string result = minS + ":" + secS;
                TimerLabel.Text = result;

            }, this.Dispatcher);
            timer.Start();
        }

        private void StopTimer()
        {
            timer.Stop();
            TimerLabel.Text = "00:00";
        }

        
        private void recordOption_Click(object sender, RoutedEventArgs e)
        {
            // We create the recorders prior to setting 'recording' to true, so that when
            // we set recording to true, we are certain the recorders have been created.
            // If !recording means that you want to initialize recording.
            if (!recording)
            {
                recorders = new Dictionary<string, KinectRecorder>(2);

                string subFolder = "";
                if (Patient_ID.Text == "")
                {
                    subFolder = "no_id/";
                }
                else {
                    subFolder = Patient_ID.Text + "/";
                }

                // Makes sure the directory exists (if it already does, it doesn't raise an error).
                System.IO.Directory.CreateDirectory(KINECT_SSD_PATH + subFolder);
                
                for (int i = 0; i < kinectSensors.Length; i++)
                {
                    string parsedDate = DateTime.Now.ToString().Replace('/', '-').Replace(':', '-');
                    string file = KINECT_SSD_PATH + subFolder + "Kinect " + i.ToString() + " - on " + parsedDate;
                    string kinectID = kinectSensors[i].DeviceConnectionId;
                    DirectRecord(file + ".replay", kinectID);
                }

                timerInit();
                // TODO(dcastro): Creating a new bitmap image every time is a bit excessive,
                // may be better to create once and then continuously switch.
                // However, I don't want to have too many global variables for random things,
                // need to think about a better way of doing this.
                Record_Button_Image.Source = new BitmapImage(new Uri(PROJECT_PATH + "Assets/Recording_Button.jpg"));
            }

            // Set recording to true.
            recording = !recording;

            // End recording.
            if (!recording)
            {
                StopRecord();
                StopTimer();
                Record_Button_Image.Source = new BitmapImage(new Uri(PROJECT_PATH + "Assets/Record_Button.jpg"));
                return;
            }
        }

        void DirectRecord(string targetFileName, string id)
        {
            Stream recordStream = File.Create(targetFileName);
            recorders.Add(id, new KinectRecorder(KinectRecordOptions.Skeletons | KinectRecordOptions.Depth, recordStream));
        }

        void StopRecord()
        {
            if (recorders != null)
            {
                foreach (KinectRecorder recorder in recorders.Values)
                {
                    recorder.Stop();
                }
                recorders = null;
                return;
            }
        }

        public MainWindow()
        {
            
            InitializeComponent();
        }
    }
}
