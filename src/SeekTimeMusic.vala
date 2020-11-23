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
    public class SeekTimeMusic : Gtk.Grid {
        public Gtk.Label progression_label;
        public Gtk.Label duration_label;
        private Gtk.Scale scale;

        private double _playback_duration;
        public double playback_duration {
            get {
                return _playback_duration;
            }
            set {
                double duration = value;
                if (duration < 0.0) {
                    duration = 0.0;
                }
                _playback_duration = duration;
                duration_label.label = seconds_to_time ((int) duration);
            }
        }

        private double _playback_progress;
        public double playback_progress {
            get {
                return _playback_progress;
            }
            set {
                double progress = value;
                if (progress < 0.0) {
                    progress = 0.0;
                } else if (progress > 1.0) {
                    progress = 1.0;
                }
                _playback_progress = progress;
                progression_label.label = seconds_to_time ((int) (progress * playback_duration));
                scale.set_value (progress);
            }
        }

        public SeekTimeMusic (ClutterGst.Playback playback) {
            get_style_context ().add_class ("seek_bar");
            playback.notify["progress"].connect (() => {
                playback_progress = playback.progress;
            });
            playback.notify["duration"].connect (() => {
                playback_duration = playback.duration;
            });
            scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
            scale.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            scale.get_style_context ().add_class ("seek_bar");
            scale.hexpand = true;
            scale.draw_value = false;
            scale.width_request = 350;
            scale.margin_end = scale.margin_start = 10;

            scale.enter_notify_event.connect (() => {
                return cursor_hand_mode (0);
            });
            scale.leave_notify_event.connect (() => {
                return cursor_hand_mode (2);
            });
            scale.motion_notify_event.connect ((event) => {
                return cursor_hand_mode (0);
            });

            scale.change_value.connect ((scroll, new_value) => {
                if (scroll == Gtk.ScrollType.JUMP) {
                    playback.progress = new_value;
                }
                return false;
            });
            progression_label = new Gtk.Label (null);
            progression_label.get_style_context ().add_class ("h3");

            duration_label = new Gtk.Label (null);
            duration_label.get_style_context ().add_class ("h3");

            margin = 0;
            hexpand = true;
            orientation = Gtk.Orientation.HORIZONTAL;
            add (progression_label);
            add (scale);
            add (duration_label);
        }
    }
}
