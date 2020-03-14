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
    public class PlaybackPlayer : ClutterGst.Playback {
        public dynamic Gst.Element pipeline;
        private dynamic Gst.Element playsink;
        private dynamic Gst.Element visualmode;
        public VideoMix? videomix;
        public AudioMix? audiomix;
        private const string [] VISUALMODE = {"goom", "goom2k1", "spacescope", "spectrascope", "synaescope", "wavescope", "monoscope"};

        construct {
            videomix = new VideoMix (this);
            audiomix = new AudioMix ();
            pipeline = this.get_pipeline ();
            pipeline["video-sink"] = videomix;
            var iter = ((Gst.Bin)pipeline).iterate_sinks ();
            Value value;
            while (iter.next (out value) == Gst.Iterator.OK) {
                playsink = (Gst.Element)value;
                string sink_name = playsink.get_name ();
                if (strcmp (sink_name, "playsink") != 0) {
                    sink_name = null;
                    break;
                }
            }
            playsink["audio-sink"] = audiomix;
            Gst.Bus bus = ((Gst.Pipeline)pipeline).get_bus ();
            bus.add_signal_watch ();
            bus.message.connect (handle_message);
            do_step ();
            notify["idle"].connect (do_step);
            NikiApp.settings.changed["speed-playing"].connect (() => {
                pipeline.set_state (Gst.State.PAUSED);
                var new_progress = ((duration * progress) + (double)0)/duration;
                progress = new_progress.clamp (0.0, 1.0);
                do_step ();
                pipeline.set_state (Gst.State.PLAYING);
            });

            NikiApp.settings.changed["subtitle-choose"].connect (() => {
                if (window != null) {
                    var start_progress = this.progress;
                    pipeline.set_state (Gst.State.NULL);
                    subtitle_uri = NikiApp.settings.get_string ("subtitle-choose");
                    pipeline.set_state (Gst.State.PLAYING);
                    ready.connect (() => {
                        progress = start_progress;
                        start_progress = 0.0;
                    });
                }
            });

            flip_chage ();
            visualisationsink ();
            NikiApp.settings.changed["flip-options"].connect (flip_chage);
            NikiApp.settings.changed["visualisation-options"].connect (visualisationsink);
            NikiApp.settings.changed["visualmode-options"].connect (visualisationsink);
            NikiApp.settings.changed["shader-options"].connect (visualisationsink);
            NikiApp.settings.changed["status-muted"].connect (playback_mute);
            NikiApp.settings.changed["amount-entry"].connect (() => {
                if (VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [6] ||
                    VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [0] ||
                    VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [1]) {
                    saderamount (NikiApp.settings.get_int ("amount-entry"));
                }
            });
            playback_mute ();
        }
        private void playback_mute () {
            pipeline["mute"] = NikiApp.settings.get_boolean ("status-muted");
        }
        private void handle_message (Gst.Bus bus, Gst.Message message) {
            if (message.type == Gst.MessageType.STEP_DONE) {
                do_step ();
            }
        }
        private void do_step () {
            switch (NikiApp.settings.get_int ("speed-playing")) {
                case 0 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 600 * Gst.MSECOND, 0.25, false, false));
                    break;
                case 1 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 400 * Gst.MSECOND, 0.5, false, false));
                    break;
                case 2 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 200 * Gst.MSECOND, 0.75, false, false));
                    break;
                case 3 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 100 * Gst.MSECOND, 0.90, false, false));
                    break;
                case 4 :
                    break;
                case 5 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 100 * Gst.MSECOND, 1.25, false, false));
                    break;
                case 6 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 100 * Gst.MSECOND, 1.5, false, false));
                    break;
                case 7 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 100 * Gst.MSECOND, 1.75, false, false));
                    break;
                case 8 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, 100 * Gst.MSECOND, 2.0, false, false));
                    break;
            }
        }
        private void visualisationsink () {
            var start_progress = this.progress;
            pipeline.set_state (Gst.State.PAUSED);
            switch (NikiApp.settings.get_int ("visualisation-options")) {
                case 0 :
                    int stopsink;
                    playsink.get ("flags", out stopsink);
                    stopsink &= ~(1 << 3);
                    playsink["flags"] = stopsink;
                    pipeline.set_state (Gst.State.NULL);
                    break;
                case 1 :
                    visualmode = Gst.ElementFactory.make(VISUALMODE [NikiApp.settings.get_int ("visualmode-options")], VISUALMODE [NikiApp.settings.get_int ("visualmode-options")]);
                    if (VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [6]) {
                        shader_chage ();
                    }
                    if (VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [6] ||
                        VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [0] ||
                        VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [1]) {
                        saderamount (NikiApp.settings.get_int ("amount-entry"));
                    }
                    int startsink;
                    playsink.get ("flags", out startsink);
                    startsink |= (1 << 3);
                    playsink["flags"] = startsink;
                    playsink["vis-plugin"] = visualmode;
                    pipeline.set_state (Gst.State.NULL);
                    break;
            }
            if (window != null) {
                pipeline.set_state (Gst.State.PLAYING);
                this.ready.connect (() => {
                    this.progress = start_progress;
                    start_progress = 0.0;
                });
            }
        }
        private void shader_chage () {
            pipeline.set_state (Gst.State.NULL);
            switch (NikiApp.settings.get_int ("shader-options")) {
                case 0 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.NONE;
                    break;
                case 1 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE;
                    break;
                case 2 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE_AND_MOVE_UP;
                    break;
                case 4 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE_AND_MOVE_DOWN;
                    break;
                case 5 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE_AND_MOVE_LEFT;
                    break;
                case 6 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE_AND_MOVE_RIGHT;
                    break;
                case 7 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE_AND_MOVE_VERT_OUT;
                    break;
                case 8 :
                    visualmode["shader"] = Gst.PbUtils.AudioVisualizerShader.FADE_AND_MOVE_VERT_IN;
                    break;
            }
        }
        public void saderamount (int index) {
            if (VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] != VISUALMODE [6]) {
                visualmode["shade-amount"] = index;
            }
        }
        private void flip_chage () {
            var start_progress = this.progress;
            pipeline.set_state (Gst.State.PAUSED);
            videomix.flip_filter["method"] = NikiApp.settings.get_int ("flip-options");
            pipeline.set_state (Gst.State.NULL);
            if (window != null) {
                pipeline.set_state (Gst.State.PLAYING);
                this.ready.connect (() => {
                    this.progress = start_progress;
                    start_progress = 0.0;
                });
            }
        }
    }
}
