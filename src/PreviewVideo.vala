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
    public class PreviewVideo : Gst.Bin {
        private dynamic Gst.Element videoqueue;
        private dynamic Gst.Element videosink;
        private dynamic Gst.Element videotee;
        public dynamic Gst.Element flip_filter;
        private dynamic Gst.Element capsfilter;

        public PreviewVideo (ClutterGst.Playback playback) {
            videotee = Gst.ElementFactory.make ("tee", "tee");
            videoqueue = Gst.ElementFactory.make ("queue", "queue");
            videoqueue["flush-on-eos"] = true;
            flip_filter = Gst.ElementFactory.make ("videoflip", "videoflip");
            capsfilter = Gst.ElementFactory.make ("capsfilter", "capsfilter");
            Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "video/x-raw, format={ I420, YV12, YUY2, UYVY, AYUV, Y41B, Y42B, YVYU, Y444, v210, v216, NV12, NV21, UYVP, A420, YUV9, YVU9, IYU1 }");
            videosink = Gst.ElementFactory.make ("autovideosink", "autovideosink");
            videosink = playback.get_video_sink ();
            add_many (videoqueue, videotee, capsfilter, flip_filter, videosink);
            add_pad (new Gst.GhostPad ("sink", videotee.get_static_pad ("sink")));
            videoqueue.link_many (capsfilter, flip_filter, videosink);
            Gst.Pad sinkpad = videoqueue.get_static_pad ("sink");
            Gst.Pad pad = videotee.get_request_pad ("src_%u");
            pad.link (sinkpad);
            videotee["alloc-pad"] = pad;
        }
    }
}
