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
    public class TimeMusic : Gtk.Revealer {
        public Gtk.Label progression_label { get; construct set; }
        public Gtk.Label duration_label { get; construct set; }

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
            }
        }

        public TimeMusic (ClutterGst.Playback playback) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            transition_duration = 500;
            playback.notify["progress"].connect (() => {
                playback_progress = playback.progress;
            });
            playback.notify["duration"].connect (() => {
                playback_duration = playback.duration;
            });

            get_style_context ().add_class ("seek_bar");
            progression_label = new Gtk.Label (null);
            progression_label.get_style_context ().add_class ("seek_bar");
            progression_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            progression_label.selectable = true;
            duration_label = new Gtk.Label (null);
            duration_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            duration_label.selectable = true;
            var actionbar = new Gtk.ActionBar ();
            actionbar.get_style_context ().add_class ("ground_action_button");
            actionbar.pack_start (progression_label);
            actionbar.pack_end (duration_label);
            actionbar.hexpand = true;
            add (actionbar);
            show_all ();
        }
    }
}