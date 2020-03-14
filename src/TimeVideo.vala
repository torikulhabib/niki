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
    public class TimeVideo : Gtk.Revealer {
        public Gtk.Label progress_duration_label { get; construct set; }
        private string duration_string;

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
                duration_string = seconds_to_time ((int) duration);

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
                progress_duration_label.label = seconds_to_time ((int) (progress * playback_duration)) +" / " + duration_string;
            }
        }

        public TimeVideo (ClutterGst.Playback playback) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            transition_duration = 500;
            playback.notify["progress"].connect (() => {
                playback_progress = playback.progress;
            });
            playback.notify["duration"].connect (() => {
                playback_duration = playback.duration;
            });

            progress_duration_label = new Gtk.Label (null);
            progress_duration_label.get_style_context ().add_class ("button_action");
            progress_duration_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            progress_duration_label.selectable = true;
            progress_duration_label.halign = Gtk.Align.START;
            add (progress_duration_label);
            margin_top = 2;
            margin_start = 0;
            show_all ();
        }
    }
}
