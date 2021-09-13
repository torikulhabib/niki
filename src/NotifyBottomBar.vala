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
    public class NotifyBottomBar : Gtk.Revealer {
        private Gtk.ProgressBar progress_bar;
        private PlayerPage? playerpage;

        public NotifyBottomBar (PlayerPage playerpage) {
            this.playerpage = playerpage;
            transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            transition_duration = 500;
            hexpand = true;
            progress_bar = new Gtk.ProgressBar () {
                expand = true
            };
            progress_bar.set_fraction (0);
            progress_bar.get_style_context ().add_class ("progress_bar");
            playerpage.playback.notify["progress"].connect (() => {
                progress_bar.set_fraction (playerpage.playback.progress);
            });
            add (progress_bar);
        }

        private uint hiding_timer = 0;
        public void reveal_control () {
            show_all ();
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
                hide ();
                return Source.REMOVE;
            });
        }
    }
}
