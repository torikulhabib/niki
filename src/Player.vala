/*
* Copyright (c) {2021} torikulhabib (https://github.com/torikulhabib)
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
    public class Player : GLib.Object {
        public signal void eos ();
        public signal void ready ();
        public signal void idle ();
        public signal void albumart_changed (Gst.TagList taglist);
        public signal void size_change (int width, int height);
        public signal void updated ();
        public float[] m_magnitudes = new float[10];
        public dynamic Gst.Element pipeline;
        public AudioMix? audiomix;
        public VideoMix? videomix;
        private double period = 0.0;

        public ClutterGst.VideoSink sink {
            get {
                return videomix.videosink;
            }
        }

        public double duration {
            get {
                int64 dur = 0;
                pipeline.query_duration (Gst.Format.TIME, out dur);
                return (double) (dur / 1000000000);
            }
        }

        public double position {
            get {
                int64 pos = 0;
                pipeline.query_position (Gst.Format.TIME, out pos);
                return (double) (pos / 1000000000);
            }
        }

        public double progress {
            get {
                return duration < 1? 0.0 : ((1 / duration) * position);
            }
        }

        private string _uri;
        public string uri {
            get {
                return _uri;
            }
            set {
                _uri = value;
                if (get_states () != Gst.State.READY) {
                    pipeline.set_state (Gst.State.READY);
                }
                pipeline["uri"] = _uri;
                if (!subtitle_active) {
                    subtitle_active = true;
                }
            }
        }

        private bool _playing;
        public bool playing {
            get {
                return _playing;
            }
            set {
                _playing = value;
                if (value == true) {
                    pipeline.set_state (Gst.State.PLAYING);
                } else {
                    pipeline.set_state (Gst.State.PAUSED);
                }
            }
        }

        private double _seeked;
        public double seeked {
            get {
                return _seeked;
            }
            set {
                _seeked = value;
                pipeline.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH, (int64) ((seeked * duration) * 1000000000));
            }
        }

        private double _audio_volume;
        public double audio_volume {
            get {
                return _audio_volume;
            }
            set {
                _audio_volume = value;
                pipeline["volume"] = _audio_volume;
            }
        }

        private double _buffer_fill;
        public double buffer_fill {
            get {
                return _buffer_fill;
            }
            set {
                _buffer_fill = value;
            }
        }

        public double conn_speed {
            get {
                int64 conn;
                pipeline.get ("connection-speed", out conn);
                return (double) conn;
            }
        }

        private int _subtitle_track;
        public int subtitle_track {
            get {
                return _subtitle_track;
            }
            set {
                _subtitle_track = value;
                pipeline["current-text"] = _subtitle_track;
            }
        }

        private int _audio_stream;
        public int audio_stream {
            get {
                return _audio_stream;
            }
            set {
                _audio_stream = value;
                pipeline["current-audio"] = _audio_stream;
            }
        }

        private int _video_stream;
        public int video_stream {
            get {
                return _video_stream;
            }
            set {
                _video_stream = value;
                pipeline["current-video"] = _video_stream;
            }
        }

        private string _subtitle_font_name;
        public string subtitle_font_name {
            get {
                return _subtitle_font_name;
            }
            set {
                _subtitle_font_name = value;
                pipeline["subtitle-font-desc"] = _subtitle_font_name;
            }
        }

        private string _subtitle_uri;
        public string subtitle_uri {
            get {
                return _subtitle_uri;
            }
            set {
                _subtitle_uri = value;
                pipeline["suburi"] = _subtitle_uri;
            }
        }

        private bool _subtitle_active;
        public bool subtitle_active {
            get {
                return _subtitle_active;
            }
            set {
                _subtitle_active = value;
                int texttsink;
                pipeline.get ("flags", out texttsink);
                if (_subtitle_active) {
                    texttsink |= (1 << 2);
                } else {
                    texttsink &= ~(1 << 2);
                }
                pipeline["flags"] = texttsink;
            }
        }

        construct {
            pipeline = Gst.ElementFactory.make ("playbin", "playbin");
            pipeline.sync_state_with_parent ();
            videomix = new VideoMix ();
            audiomix = new AudioMix ();
            videomix.videosink.pipeline_ready.connect (()=> {
                ready ();
                unowned ClutterGst.Frame frame = videomix.videosink.get_frame ();
                size_change (frame.resolution.width, frame.resolution.height);
                if (subtitle_active != NikiApp.settings.get_boolean ("activate-subtitle")) {
                    subtitle_active = NikiApp.settings.get_boolean ("activate-subtitle");
                }
            });
            pipeline["video-sink"] = videomix;
            pipeline["audio-sink"] = audiomix;
            var bus = pipeline.get_bus ();
            bus.enable_sync_message_emission ();
            bus.add_watch (0, bus_callback);
            idle.connect (speed);
            NikiApp.settings.changed["speed-playing"].connect (()=> {
                period = 0.0;
                speed ();
            });
            NikiApp.settings.changed["status-muted"].connect (playback_mute);
            NikiApp.settings.changed["flip-options"].connect (flip_chage);
            flip_chage ();
            playback_mute ();
        }

        public void set_subtittle (string subtitle) {
            insert_last_video (uri, seconds_to_time ((int) (progress * duration)), progress);
            pipeline.set_state (Gst.State.READY);
            subtitle_uri = subtitle;
            playing = false;
            Idle.add (()=> {
                seeked = lastplay_video (uri);
                playing = true;
                return false;
            });
        }

        public void stop () {
            pipeline.set_state (Gst.State.READY);
        }

        private void playback_mute () {
            pipeline["mute"] = NikiApp.settings.get_boolean ("status-muted");
        }

        private GLib.List<string> get_tags (Gst.Element pipeline, string property_name, string action_signal) {
            GLib.List<string> list_tags = new GLib.List<string> ();
            int n_text;
            pipeline.get (property_name, out n_text);
            if (n_text == 0) {
                return list_tags;
            }
            for (int i = 0; i < n_text; i++) {
                Gst.TagList tags;
                string value;
                GLib.Signal.emit_by_name (pipeline, action_signal, i, out tags);
                if (tags != null) {
                    if (tags.get_string ("language-name", out value)) {
                        value = @"Internal $(value)";
                    } else if (tags.get_string ("language-code", out value)) {
                        value = @"Internal $(value)";
                    } else {
                        value = @"Internal $(i+1)";
                    }
                } else {
                    value = _("External");
                }
                list_tags.prepend (value);
            }
            return list_tags;
        }

        public GLib.List<string> get_subtitle_tracks () {
            GLib.List<string> list_tags = new GLib.List<string> ();
            foreach (var tags in get_tags (pipeline, "n-text", "get-text-tags")) {
                list_tags.prepend (tags);
            }
            return list_tags;
        }

        public GLib.List<string> get_audio_streams () {
            GLib.List<string> list_tags = new GLib.List<string> ();
            foreach (var tags in get_tags (pipeline, "n-audio", "get-audio-tags")) {
                list_tags.prepend (tags);
            }
            return list_tags;
        }

        public GLib.List<string> get_video_streams () {
            GLib.List<string> list_tags = new GLib.List<string> ();
            foreach (var tags in get_tags (pipeline, "n-video", "get-video-tags")) {
                list_tags.prepend (tags);
            }
            return list_tags;
        }

        public Gst.State get_states () {
            Gst.State state = Gst.State.NULL;
            Gst.State pending;
            pipeline.get_state (out state, out pending, (Gst.ClockTime) (Gst.SECOND));
            return state;
        }

        private bool bus_callback (Gst.Bus bus, Gst.Message message) {
            if (message.type == Gst.MessageType.STEP_DONE) {
                speed ();
            } else if (message.type == Gst.MessageType.BUFFERING && NikiApp.settings.get_enum ("player-mode") == PlayerMode.STREAMVID) {
                Gst.BufferingMode mode;
                message.parse_buffering_stats (out mode, null, null, null);
                if (mode == Gst.BufferingMode.STREAM || mode == Gst.BufferingMode.LIVE) {
                    notify_property ("conn-speed");
                    int buffering;
                    message.parse_buffering (out buffering);
                    buffer_fill = buffering;
                }
            } else if (message.type == Gst.MessageType.EOS) {
                pipeline.set_state (Gst.State.READY);
                eos ();
            } else if (message.type == Gst.MessageType.ASYNC_DONE) {
                idle ();
            } else if (message.type == Gst.MessageType.ELEMENT) {
                notify_property ("duration");
                notify_property ("position");
                notify_property ("progress");
                if (NikiApp.settings.get_boolean ("audio-video")) {
                    unowned Gst.Structure struct = message.get_structure ();
                    string name = struct.get_name ();
                    if (name == "spectrum") {
                        unowned GLib.Value? vals = struct.get_value ("magnitude");
                        for (int cpt = 0; cpt < 10; ++cpt) {
                            unowned GLib.Value? mag = Gst.ValueList.get_value (vals, cpt);
                            if (mag != null) {
                                m_magnitudes[cpt] = (float)mag;
                            }
                        }
                        updated ();
                    }
                }
            } else if (message.type == Gst.MessageType.TAG) {
                if (NikiApp.settings.get_boolean ("audio-video")) {
                    Gst.TagList tag_list;
                    message.parse_tag (out tag_list);
                    if (tag_list != null) {
                        albumart_changed (tag_list);
                    }
                }
            } else if (message.type == Gst.MessageType.ERROR) {
                GLib.Error err;
                string debug;
                message.parse_error (out err, out debug);
                warning ("Error: %s\n%s\n", err.message, debug);
            }
            return true;
        }

        private void speed () {
            if (NikiApp.settings.get_boolean ("audio-video") && !playing) {
                return;
            }
            double length = Math.sin (period);
            period += Math.PI / 20;
            length += 1.1;
            length *= 100 * Gst.MSECOND;

            switch (NikiApp.settings.get_int ("speed-playing")) {
                case 0 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 0.25, false, false));
                    break;
                case 1 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 0.5, false, false));
                    break;
                case 2 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 0.75, false, false));
                    break;
                case 3 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 0.90, false, false));
                    break;
                case 4 :
                    period = 0.0;
                    break;
                case 5 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 1.25, false, false));
                    break;
                case 6 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 1.5, false, false));
                    break;
                case 7 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 1.75, false, false));
                    break;
                case 8 :
                    pipeline.send_event (new Gst.Event.step (Gst.Format.TIME, (uint64) length, 2.0, false, false));
                    break;
            }
        }

        private void flip_chage () {
            videomix.flip_filter["method"] = NikiApp.settings.get_int ("flip-options");
        }
    }
}
