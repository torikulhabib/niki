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

namespace niki {
    public class VideoMix : Gst.Bin {
        private dynamic Gst.Element videoqueue;
        private dynamic Gst.Element videosink;
        private dynamic Gst.Element videotee;
        private dynamic Gst.Element gamma;
        private dynamic Gst.Element color_balance;
        public dynamic Gst.Element flip_filter;
        private dynamic Gst.Element coloreffects;
        private dynamic Gst.Element capsfilter;
        public dynamic Gst.Element videocrop;
        private dynamic Gst.Element videoscale;
        private const string [] VIDEORENDER = {"autovideosink", "vaapisink", "ximagesink", "xvimagesink"};

        public VideoMix (ClutterGst.Playback playback) {
            videotee = Gst.ElementFactory.make("tee", "tee");
            videocrop = Gst.ElementFactory.make("videocrop","videocrop");
            videoqueue = Gst.ElementFactory.make("queue","queue");
            videoqueue["flush-on-eos"] = true;
            flip_filter = Gst.ElementFactory.make ("videoflip", "videoflip");
            gamma = Gst.ElementFactory.make ("gamma","gamma");
            color_balance = Gst.ElementFactory.make ("videobalance","videobalance");
            coloreffects = Gst.ElementFactory.make ("coloreffects","coloreffects");
            videoscale = Gst.ElementFactory.make ("videoscale","videoscale");
            videoscale["gamma-decode"] = true;
            videoscale["sharpen"] = 1.0;
            videoscale["sharpness"] = 1.5;
            capsfilter = Gst.ElementFactory.make ("capsfilter", "capsfilter");
            Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ RGBA, RGB, I420, YV12, YUY2, UYVY, AYUV, Y41B, Y42B, YVYU, Y444, v210, v216, NV12, NV21, UYVP, A420, YUV9, YVU9, IYU1, VUYA, BGR, Y210, Y410, GRAY8, GRAY16_BE, GRAY16_LE, v308, RGB16, BGR16, RGB15, BGR15, UYVP, RGB8P, ARGB64, AYUV64, r210, I420_10BE, I420_10LE, I422_10BE, I422_10LE, Y444_10BE, Y444_10LE, GBR, GBR_10BE, GBR_10LE, NV16, NV24, NV12_64Z32, A420_10BE, A420_10LE, A422_10BE, A422_10LE, A444_10BE, A444_10LE, NV61, P010_10BE, P010_10LE, IYU2, VYUY, GBRA, GBRA_10BE, GBRA_10LE, BGR10A2_LE, RGB10A2_LE, GBR_12BE, GBR_12LE, GBRA_12BE, GBRA_12LE, I420_12BE, I420_12LE, I422_12BE, I422_12LE, Y444_12BE, Y444_12LE, GRAY10_LE32, NV12_10LE32, NV16_10LE32, NV12_10LE40 }");
            videosink = Gst.ElementFactory.make (VIDEORENDER [NikiApp.settings.get_int ("videorender-options")], VIDEORENDER [NikiApp.settings.get_int ("videorender-options")]);
            videosink = playback.get_video_sink ();
            add_many(videoqueue, videotee, capsfilter, videoscale, videocrop, coloreffects, flip_filter, color_balance, gamma, videosink);
            add_pad (new Gst.GhostPad ("sink", videotee.get_static_pad ("sink")));
            videoqueue.link_many (capsfilter, videoscale, videocrop, coloreffects, flip_filter, color_balance, gamma, videosink);
            Gst.Pad sinkpad = videoqueue.get_static_pad ("sink");
            Gst.Pad pad = videotee.get_request_pad ("src_%u");
            pad.link(sinkpad);
            videotee["alloc-pad"] = pad;
            coloreffect ();
            NikiApp.settings.changed["coloreffects-options"].connect (coloreffect);
        }
        public void set_videocrp (int top, int bottom, int left, int right) {
            videocrop.set_state (Gst.State.PAUSED);
            videocrop["top"] = top;
            videocrop["bottom"] = bottom;
            videocrop["left"] = left;
            videocrop["right"] = right;
            videocrop.set_state (Gst.State.PLAYING);
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
            var video_preset = new Gee.TreeSet<VideoPreset> ();
            foreach (string preset in NikiApp.settingsVf.get_strv ("custom-presets")) {
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
            default_presets.add (new VideoPreset.with_value (_("Full Color"), {0, -1, -1, 100, 0}));
            default_presets.add (new VideoPreset.with_value (_("No Color"), {0, 0, 10, -100, 0}));
            default_presets.add (new VideoPreset.with_value (_("Soft"), {0, 0, -10, 0, 0}));
            return default_presets;
        }
    }
}
