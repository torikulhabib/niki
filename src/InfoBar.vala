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
    public class InfoBar : Gtk.Revealer {
        private Gtk.Label notification_label;
        private uint hiding_timer = 0;
        private string _title;
        public string title {
            get {
                return _title;
            }
            construct set {
                if (notification_label != null) {
                    notification_label.label = value.strip ();
                }
                _title = value;
            }
        }

        construct {
            margin = 4;
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.START;
            notification_label = new Gtk.Label (null);
            notification_label.ellipsize = Pango.EllipsizeMode.END;
            notification_label.hexpand = true;
            notification_label.vexpand = false;
            notification_label.margin = 5;

            var notification_frame = new Gtk.EventBox ();
            notification_frame.get_style_context ().add_class ("app-notification");
            notification_frame.add (notification_label);
            add (notification_frame);
        }

        public void send_notification () {
            reveal_child = true;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add_seconds (2, () => {
                reveal_child = false;
                hiding_timer = 0;
                return false;
            });
        }
    }
}
