using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
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
        KinectSensor[] kinectSensors = new KinectSensor[2];
        Canvas[] canvases = new Canvas[2];
        Dictionary<string, Image> displays = new Dictionary<string, Image>(2);

        Dictionary<string, ColorStreamManager> colorManagers = new Dictionary<string, ColorStreamManager>(2);
        Dictionary<string, DepthStreamManager> depthManagers = new Dictionary<string, DepthStreamManager>(2);
        Dictionary<string, SkeletonDisplayManager> skeletonDisplayManagers = new Dictionary<string, SkeletonDisplayManager>(2);

        readonly ContextTracker contextTracker = new ContextTracker();

        private bool recordNextFrameForPosture;
        bool displayDepth;

        KinectRecorder recorder;
        KinectReplay replay;

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
                            canvases[0] = kinectCanvas1;
                            displays.Add(id, kinectDisplay1);
                            colorManagers.Add(id, new ColorStreamManager());
                            depthManagers.Add(id, new DepthStreamManager());
                        }
                        else if (kinectSensors[1] == null)
                        {
                            kinectSensors[1] = kinect;
                            string id = kinect.DeviceConnectionId;
                            canvases[1] = kinectCanvas2;
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
                skeletonDisplayManagers[id] = new SkeletonDisplayManager(kinectSensors[i], canvases[i]);

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

                if (recorder != null && ((recorder.Options & KinectRecordOptions.Depth) != 0))
                {
                    recorder.Record(frame);
                }

                if (!displayDepth)
                    return;

                depthManagers[((KinectSensor) sender).DeviceConnectionId].Update(frame);
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

                if (recorder != null && ((recorder.Options & KinectRecordOptions.Color) != 0))
                {
                    recorder.Record(frame);
                }

                if (displayDepth)
                    return;

                colorManagers[((KinectSensor)sender).DeviceConnectionId].Update(frame);
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

                if (recorder != null && ((recorder.Options & KinectRecordOptions.Skeletons) != 0))
                    recorder.Record(frame);

                frame.GetSkeletons(ref skeletons);

                if (skeletons.All(s => s.TrackingState == SkeletonTrackingState.NotTracked))
                    return;

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
            if (recorder != null)
            {
                recorder.Stop();
                recorder = null;
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

        private void recordOption_Click(object sender, RoutedEventArgs e)
        {
            if (recorder != null)
            {
                StopRecord();
                return;
            }

            SaveFileDialog saveFileDialog = new SaveFileDialog { Title = "Select filename", Filter = "Replay files|*.replay" };

            if (saveFileDialog.ShowDialog() == true)
            {
                DirectRecord(saveFileDialog.FileName);
            }
        }

        void DirectRecord(string targetFileName)
        {
            Stream recordStream = File.Create(targetFileName);
            recorder = new KinectRecorder(KinectRecordOptions.Skeletons | KinectRecordOptions.Depth, recordStream);
        }

        void StopRecord()
        {
            if (recorder != null)
            {
                recorder.Stop();
                recorder = null;
                return;
            }
        }

        public MainWindow()
        {
            
            InitializeComponent();
        }
    }
}
