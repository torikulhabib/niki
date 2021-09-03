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
    public class VolumeListMode : Gtk.Grid {
        public Gtk.Scale scale { get; construct set; }
        public bool hovering_grabing { get; construct set; }
        public signal void leave_scale ();

        construct {
            get_style_context ().add_class ("dlna_volume");
            scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01) {
                draw_value = false,
                can_focus = false,
                show_fill_level = true,
                margin_start = 2,
                margin_end = 2,
                width_request = 350
            };
            scale.set_value (NikiApp.settings.get_double ("volume-adjust"));

            NikiApp.settings.changed["status-muted"].connect (() => {
                scale.sensitive = NikiApp.settings.get_boolean ("status-muted")? false : true;
            });

            NikiApp.settings.changed["volume-adjust"].connect (() => {
                scale.set_value (NikiApp.settings.get_double ("volume-adjust"));
            });

            scale.change_value.connect ((scroll, new_value) => {
                if (scroll == Gtk.ScrollType.JUMP) {
                    NikiApp.settings.set_double ("volume-adjust", new_value);
                }
                return false;
            });
            scale.button_release_event.connect (update_tooltip);
            scale.motion_notify_event.connect (update_tooltip);
            scale.button_press_event.connect (update_tooltip);
            scale.enter_notify_event.connect (() => {
                hovering_grabing = true;
                leave_scale ();
                return update_tooltip ();
            });

            scale.leave_notify_event.connect (() => {
                hovering_grabing = false;
                leave_scale ();
                return cursor_hand_mode (2);
            });
            var volume_button = new VolumeButton () {
                valign = Gtk.Align.CENTER
            };
            volume_button.get_style_context ().add_class ("transbgborder");
            volume_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("status-muted", !NikiApp.settings.get_boolean ("status-muted"));
            });
            var volume_buttonmax = new VolumeButton () {
                valign = Gtk.Align.CENTER
            };
            scale.get_style_context ().add_class ("transbgborder");
            volume_buttonmax.get_style_context ().add_class ("transbgborder");
            volume_buttonmax.clicked.connect (() => {
                NikiApp.settings.set_double ("volume-adjust", 1.0);
            });
            orientation = Gtk.Orientation.HORIZONTAL;
            add (volume_button);
            add (scale);
            add (volume_buttonmax);
            show_all ();
        }

        public bool update_tooltip () {
            scale.tooltip_text = double_to_percent (scale.get_value ());
            return cursor_hand_mode (0);
        }
    }
}
