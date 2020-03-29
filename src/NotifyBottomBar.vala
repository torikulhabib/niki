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
    public class NotifyBottomBar : Gtk.Revealer {
        private Gtk.ProgressBar progress_bar;
        private PlayerPage? playerpage;
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
                progress_bar.set_fraction (progress);
            }
        }

        public NotifyBottomBar (PlayerPage playerpage) {
            this.playerpage = playerpage;
            transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            transition_duration = 500;
            progress_bar = new Gtk.ProgressBar ();
            progress_bar.get_style_context ().add_class ("progress_bar");
            progress_bar.hexpand = true;
            playerpage.playback.notify["progress"].connect (() => {
                playback_progress = playerpage.playback.progress;
            });
            add (progress_bar);
            show_all ();
        }

        private uint hiding_timer = 0;
        public void reveal_control () {
            if (!child_revealed) {
                set_reveal_child (true);
            }
            margin_end = margin_start = 5;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add_seconds (1, () => {
                set_reveal_child (false);
                hiding_timer = 0;
                return Source.REMOVE;
            });
        }
    }
}
