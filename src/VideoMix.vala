/*
* Copyright (c) {2019} torikulhabib (https://github.com/torikulhabib)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@Gmail.com>
*/

namespace Niki {
    public class VideoMix : Gst.Bin {
        private dynamic Gst.Element videoqueue;
        public ClutterGst.VideoSink videosink;
        private dynamic Gst.Element videotee;
        private dynamic Gst.Element elemen_gamma;
        private dynamic Gst.Element color_balance;
        public dynamic Gst.Element flip_filter;
        private dynamic Gst.Element coloreffects;
        private dynamic Gst.Element capsfilter;
        public dynamic Gst.Element videocrop;

        private int _gamma;
        public int gamma {
            get {
                return _gamma;
            }
            set {
                _gamma = value;
                elemen_gamma["gamma"] = (double) ((101.1 + (_gamma / 10)) / 100.0);
            }
        }

        private int _saturation;
        public int saturation {
            get {
                return _saturation;
            }
            set {
                _saturation = value;
                color_balance["saturation"] = (double) ((100.0 + (_saturation / 10)) / 100.0);
            }
        }

        construct {
            videotee = Gst.ElementFactory.make ("tee", "tee");
            videocrop = Gst.ElementFactory.make ("videocrop", "videocrop");
            videoqueue = Gst.ElementFactory.make ("queue", "queue");
            flip_filter = Gst.ElementFactory.make ("videoflip", "videoflip");
            elemen_gamma = Gst.ElementFactory.make ("gamma", "gamma");
            color_balance = Gst.ElementFactory.make ("videobalance", "videobalance");
            coloreffects = Gst.ElementFactory.make ("coloreffects", "coloreffects");
            capsfilter = Gst.ElementFactory.make ("capsfilter", "capsfilter");
            videosink = new ClutterGst.VideoSink ();
            add_many (videoqueue, videotee, capsfilter, videocrop, coloreffects, flip_filter, color_balance, elemen_gamma, videosink);
            add_pad (new Gst.GhostPad ("sink", videotee.get_static_pad ("sink")));
            videoqueue.link_many (capsfilter, videocrop, coloreffects, flip_filter, color_balance, elemen_gamma, videosink);
            Gst.Pad sinkpad = videoqueue.get_static_pad ("sink");
            Gst.Pad pad = videotee.get_request_pad ("src_%u");
            pad.link (sinkpad);
            NikiApp.settings.changed["coloreffects-options"].connect (coloreffect);
            NikiApp.settings.changed["videorender-options"].connect (filetr_caps);
            filetr_caps ();
            coloreffect ();
        }

        private void filetr_caps () {
            switch (NikiApp.settings.get_int ("videorender-options")) {
                case 0:
                    Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ AYUV, YV12, I420, RGBA, BGRA, RGBX, BGRX, RGB, BGR, NV12 }");
                    break;
                case 1:
                    Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ AYUV64, ARGB64, GBRA_12LE, GBRA_12BE, Y412_LE, Y412_BE, A444_10LE, GBRA_10LE, A444_10BE, GBRA_10BE, A422_10LE, A422_10BE, A420_10LE, A420_10BE, RGB10A2_LE, BGR10A2_LE, Y410, GBRA, ABGR, VUYA, BGRA, AYUV, ARGB, RGBA, A420, Y444_16LE, Y444_16BE, v216, P016_LE, P016_BE, Y444_12LE, GBR_12LE, Y444_12BE, GBR_12BE, I422_12LE, I422_12BE, Y212_LE, Y212_BE, I420_12LE, I420_12BE, P012_LE, P012_BE, Y444_10LE, GBR_10LE, Y444_10BE, GBR_10BE, r210, I422_10LE, I422_10BE, NV16_10LE32, Y210, v210, UYVP, I420_10LE, I420_10BE, P010_10LE, NV12_10LE32, NV12_10LE40, P010_10BE, Y444, GBR, NV24, xBGR, BGRx, xRGB, RGBx, BGR, IYU2, v308, RGB, Y42B, NV61, NV16, VYUY, UYVY, YVYU, YUY2, I420, YV12, NV21, NV12, NV12_64Z32, Y41B, IYU1, YVU9, YUV9, RGB16, BGR16, RGB15, BGR15, RGB8P, GRAY16_LE, GRAY16_BE, GRAY10_LE32, GRAY81 }");
                    break;
                case 2:
                    Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ BGRx, BGRA, RGBx, xBGR, xRGB, RGBA, ABGR, ARGB, RGB, BGR, RGB16, BGR16, YUY2, YVYU, UYVY, AYUV, NV12, NV21, NV16, NV61, YUV9, YVU9, Y41B, I420, YV12, Y42B, v308 }");
                    break;
                case 3:
                    Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ AYUV, ARGB, BGRA, ABGR, RGBA, Y444, xRGB, RGBx, xBGR, BGRx, RGB, BGR, Y42B, YUY2, UYVY, YVYU, I420, YV12, IYUV, Y41B, NV12, NV21 }");
                    break;
            }
        }

        public void set_videocrp (int top, int bottom, int left, int right) {
            videocrop["top"] = top;
            videocrop["bottom"] = bottom;
            videocrop["left"] = left;
            videocrop["right"] = right;
        }

        private void coloreffect () {
            coloreffects["preset"] = NikiApp.settings.get_int ("coloreffects-options");
        }

        public Gee.Collection<VideoPreset> get_presets () {
            var video_preset = new Gee.TreeSet<VideoPreset> ();
            foreach (string preset in NikiApp.settings_vf.get_strv ("custom-presets")) {
                video_preset.add (new VideoPreset.from_string (preset));
            }
            return video_preset;
        }

        private static Gee.TreeSet<VideoPreset>? default_presets = null;
        public static Gee.Collection<VideoPreset> get_default_presets () {
            if (default_presets != null) {
                return default_presets;
            }
            default_presets = new Gee.TreeSet<VideoPreset> ();
            default_presets.add (new VideoPreset.with_value (_("Normal"), {0, 0, 0, 0, 0}));
            default_presets.add (new VideoPreset.with_value (_("Vivid"), {15, 5, 5, 35, 0}));
            default_presets.add (new VideoPreset.with_value (_("Bright"), {5, 10, 10, 10, 0}));
            default_presets.add (new VideoPreset.with_value (_("Color Enchaned"), {0, -1, -1, 100, 0}));
            default_presets.add (new VideoPreset.with_value (_("Full Color"), {0, -1, -1, 60, 0}));
            default_presets.add (new VideoPreset.with_value (_("No Color"), {0, 0, 10, -100, 0}));
            default_presets.add (new VideoPreset.with_value (_("Soft"), {0, 0, -10, 0, 0}));
            return default_presets;
        }
    }
}
