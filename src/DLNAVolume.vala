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
    public class DLNAVolume : Gtk.Revealer {
        public Gtk.Scale scale { get; construct set; }
        public bool hovering_grabing { get; construct set; }
        public signal void leave_scale ();

        construct {
            get_style_context ().add_class ("dlna_volume");
            transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            transition_duration = 500;
            scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 1) {
                draw_value = false,
                can_focus = false,
                show_fill_level = true,
                margin_start = 2,
                margin_end = 2,
                width_request = 81
            };
            scale.set_value (NikiApp.settings.get_int ("dlna-volume"));
            scale.get_style_context ().add_class ("dlna_volume");

            scale.events |= Gdk.EventMask.POINTER_MOTION_MASK;
            scale.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            scale.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            NikiApp.settings.changed["dlna-muted"].connect (() => {
                scale.sensitive = NikiApp.settings.get_boolean ("dlna-muted")? false : true;
            });

            NikiApp.settings.changed["dlna-volume"].connect (() => {
                scale.set_value (NikiApp.settings.get_int ("dlna-volume"));
            });

            scale.motion_notify_event.connect (() => {
                return update_tooltip ();
            });

            scale.button_press_event.connect (() => {
                return update_tooltip ();
            });
            scale.change_value.connect ((scroll, new_value) => {
                if (scroll == Gtk.ScrollType.JUMP) {
                    if (new_value < 0) {
                        new_value = 0;
                    }
                    if (new_value > 100) {
                        new_value = 100;
                    }
                    NikiApp.settings.set_int ("dlna-volume", (int)new_value);
                }
                return false;
            });
            scale.button_release_event.connect (() => {
                return update_tooltip ();
            });

            scale.enter_notify_event.connect (() => {
                hovering_grabing = true;
                return update_tooltip ();
            });

            scale.leave_notify_event.connect (() => {
                hovering_grabing = false;
                leave_scale ();
                return cursor_hand_mode (2);
            });

            scale.enter_notify_event.connect (() => {
                leave_scale ();
                return update_tooltip ();
            });

            scale.leave_notify_event.connect (() => {
                leave_scale ();
                return cursor_hand_mode (2);
            });
            margin_top = 3;
            valign = Gtk.Align.CENTER;
            add (scale);
            show_all ();
        }

        public bool update_tooltip () {
            scale.tooltip_text = double_to_percent ((double)(scale.get_value () / 100));
            return cursor_hand_mode (0);
        }
    }
}
