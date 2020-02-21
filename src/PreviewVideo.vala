namespace niki {
    public class PreviewVideo : Gst.Bin {
        private dynamic Gst.Element videoqueue;
        public dynamic Gst.Element videosink;
        private dynamic Gst.Element videotee;
        public dynamic Gst.Element flip_filter;
        public dynamic Gst.Element filter;

        public PreviewVideo (ClutterGst.Playback playback) {
            videotee = Gst.ElementFactory.make("tee", "tee");
            videoqueue = Gst.ElementFactory.make("queue","queue");
            flip_filter = Gst.ElementFactory.make ("videoflip", "videoflip");
            filter = Gst.ElementFactory.make ("capsfilter", "capsfilter");
            Gst.Util.set_object_arg ((GLib.Object) filter, "caps", "video/x-raw, format={ I420, YV12, YUY2, UYVY, AYUV, Y41B, Y42B, YVYU, Y444, v210, v216, NV12, NV21, UYVP, A420, YUV9, YVU9, IYU1 }");
            videosink = Gst.ElementFactory.make("autovideosink", "autovideosink");
            videosink = playback.get_video_sink ();
            add_many(videoqueue, videotee, filter, flip_filter, videosink);
            add_pad (new Gst.GhostPad ("sink", videotee.get_static_pad ("sink")));
            videoqueue.link_many (filter, flip_filter, videosink);
            Gst.Pad sinkpad = videoqueue.get_static_pad ("sink");
            Gst.Pad pad = videotee.get_request_pad ("src_%u");
            pad.link(sinkpad);
            videotee["alloc-pad"] = pad;
        }
    }
}
