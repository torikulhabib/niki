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
    public class PreviewClutterGst : ClutterGst.Playback {
        public dynamic Gst.Element pipeline;
        private dynamic Gst.Element playsink;
        public PreviewVideo? previewvideo;

        construct {
            previewvideo = new PreviewVideo (this);
            pipeline = get_pipeline ();
            pipeline["video-sink"] = previewvideo;
            var iter = ((Gst.Bin)pipeline).iterate_sinks ();
            Value value;
            while (iter.next (out value) == Gst.Iterator.OK) {
                playsink = (Gst.Element)value;
                string sink_name = playsink.get_name ();
                if (strcmp (sink_name, "playsink") != 0) {
                    break;
                }
            }
            int flags;
            playsink.get ("flags", out flags);
            flags &= ~(1 << 1);
            flags &= ~(1 << 2);
            playsink["flags"] = flags;
            flip_chage ();
            NikiApp.settings.changed["flip-options"].connect (flip_chage);
        }
        private void flip_chage () {
            var start_progress = progress;
            pipeline.set_state (Gst.State.PAUSED);
            previewvideo.flip_filter["method"] = NikiApp.settings.get_int ("flip-options");
            pipeline.set_state (Gst.State.NULL);
            if (NikiApp.window != null) {
                ready.connect (() => {
                    progress = start_progress;
                    start_progress = 0.0;
                });
            }
        }
    }
}
