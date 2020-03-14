namespace niki {
    public class VideoMix : Gst.Bin {
        private dynamic Gst.Element videoqueue;
        private dynamic Gst.Element videosink;
        private dynamic Gst.Element videotee;
        private dynamic Gst.Element gamma;
        private dynamic Gst.Element color_balance;
        public dynamic Gst.Element flip_filter;
        private dynamic Gst.Element coloreffects;
        private dynamic Gst.Element videoscale;
        private dynamic Gst.Element capsfilter;
        private dynamic Gst.Element videocrop;
        private const string [] VIDEORENDER = {"autovideosink", "vaapisink", "ximagesink", "xvimagesink", "v4l2sink"};

        public VideoMix (ClutterGst.Playback playback) {
            videotee = Gst.ElementFactory.make("tee", "tee");
            videocrop = Gst.ElementFactory.make("videocrop","videocrop");
            videoqueue = Gst.ElementFactory.make("queue","queue");
            videoqueue["flush-on-eos"] = true;
            videoscale = Gst.ElementFactory.make("videoscale","videoscale");
            videoscale["sharpen"] = 1.0;
            videoscale["sharpness"] = 1.5;
            videoscale["method"] = 4;
            flip_filter = Gst.ElementFactory.make ("videoflip", "videoflip");
            gamma = Gst.ElementFactory.make ("gamma","gamma");
            color_balance = Gst.ElementFactory.make ("videobalance","videobalance");
            coloreffects = Gst.ElementFactory.make ("coloreffects","coloreffects");
            capsfilter = Gst.ElementFactory.make ("capsfilter", "capsfilter");
            Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ RGBA, RGB, I420, YV12, YUY2, UYVY, AYUV, Y41B, Y42B, YVYU, Y444, v210, v216, NV12, NV21, UYVP, A420, YUV9, YVU9, IYU1 }");
            videosink = Gst.ElementFactory.make (VIDEORENDER [NikiApp.settings.get_int ("videorender-options")], VIDEORENDER [NikiApp.settings.get_int ("videorender-options")]);
            videosink = playback.get_video_sink ();
            add_many(videoqueue, videotee, capsfilter, videoscale, videocrop, coloreffects, flip_filter, gamma, color_balance, videosink);
            add_pad (new Gst.GhostPad ("sink", videotee.get_static_pad ("sink")));
            videoqueue.link_many (capsfilter, videoscale, videocrop, coloreffects, flip_filter, gamma, color_balance, videosink);
            Gst.Pad sinkpad = videoqueue.get_static_pad ("sink");
            Gst.Pad pad = videotee.get_request_pad ("src_%u");
            pad.link(sinkpad);
            videotee["alloc-pad"] = pad;
            coloreffect ();
            NikiApp.settings.changed["coloreffects-options"].connect (coloreffect);
        }
        private void coloreffect () {
            coloreffects["preset"] = NikiApp.settings.get_int ("coloreffects-options");
        }
        public void setvalue (int index, int valuescale) {
            switch (index) {
                case 0 :
                    gamma["gamma"] = (double) ((101.1 + valuescale)/100.0);
                    break;
                case 1 :
                    color_balance["brightness"] = (double) valuescale / 100.0;
                    break;
                case 2 :
                    color_balance["contrast"] = (double) ((100.0 + valuescale)/100.0);
                    break;
                case 3 :
                    color_balance["saturation"] = (double) ((100.0 + valuescale)/100.0);
                    break;
                case 4 :
                    color_balance["hue"] = (double) valuescale / 100.0;
                    break;
            }
        }

        public Gee.Collection<VideoPreset> get_presets () {
            var presets_data = new Gee.TreeSet<string> ();
            if (NikiApp.settingsVf.get_strv ("custom-presets") != null) {
                foreach (string preset in NikiApp.settingsVf.get_strv ("custom-presets")) {
                    presets_data.add (preset);
                }
            }
            var video_preset = new Gee.TreeSet<VideoPreset> ();
            foreach (var preset_str in presets_data) {
                video_preset.add (new VideoPreset.from_string (preset_str));
            }
            return video_preset;
        }

        private static Gee.TreeSet<VideoPreset>? default_presets = null;
        public static Gee.Collection<VideoPreset> get_default_presets () {
            if (default_presets != null) {
                return default_presets;
            }
            default_presets = new Gee.TreeSet<VideoPreset> ();
            default_presets.add (new VideoPreset.with_value (StringPot.Normal, {0, 0, 0, 0, 0}));
            default_presets.add (new VideoPreset.with_value (StringPot.Vivid, {15, 5, 5, 35, 0}));
            default_presets.add (new VideoPreset.with_value (StringPot.Bright, {5, 10, 10, 10, 0}));
            default_presets.add (new VideoPreset.with_value (StringPot.Full_Color, {0, -1, -1, 100, 0}));
            default_presets.add (new VideoPreset.with_value (StringPot.No_Color, {0, 0, 10, -100, 0}));
            default_presets.add (new VideoPreset.with_value (StringPot.Soft, {0, 0, -10, 0, 0}));
            return default_presets;
        }
    }
}
