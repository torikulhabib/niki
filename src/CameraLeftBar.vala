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
    public class CameraLeftBar : Gtk.Revealer {
        private Gtk.Button zoom_in_button;
        private Gtk.Button zoom_out_button;
        private Gtk.Scale scale;
        private uint hiding_timer = 0;
        private bool _hovered = false;
        public bool hovered {
            get {
                return _hovered;
            }
            set {
                _hovered = value;
                if (value) {
                    if (hiding_timer != 0) {
                        Source.remove (hiding_timer);
                        hiding_timer = 0;
                    }
                } else {
                    reveal_control ();
                }
            }
        }

        public CameraLeftBar (CameraPage camerapage) {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            transition_duration = 500;
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            enter_notify_event.connect ((event) => {
                if (event.window == get_window ()) {
                    hovered = true;
                }
                return false;
            });
            motion_notify_event.connect (() => {
                if (window.is_active) {
                    reveal_control ();
                    hovered = true;
                }
                return false;
            });

            leave_notify_event.connect ((event) => {
                if (event.window == get_window ()) {
                    hovered = false;
                }
                return false;
            });
            scale = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, 1, 10, 0.1);
            scale.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            scale.get_style_context ().add_class ("volume");
            scale.draw_value = false;
            scale.hexpand = true;
            scale.inverted = true;
            scale.enter_notify_event.connect (() => {
                cursor_hand_mode (0);
                return false;
            });
            scale.leave_notify_event.connect (() => {
                cursor_hand_mode (2);
                return false;
            });
            scale.motion_notify_event.connect (() => {
                cursor_hand_mode (0);
                return false;
            });
            scale.change_value.connect ((scroll, new_value) => {
                if (scroll == Gtk.ScrollType.JUMP) {
                    if (new_value < 1) {
                        new_value = 1;
                    }
                    if (new_value > 10) {
                        new_value = 10;
                    }
                    camerapage.zoom_in_out (new_value);
                }
                return false;
            });
            scale.value_changed.connect (() => {
                camerapage.zoom_in_out (scale.get_value ());
                sensitive_button ();
            });
            zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.BUTTON);
            zoom_in_button.tooltip_text = StringPot.Zoom_In;
            zoom_in_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            zoom_in_button.get_style_context ().add_class ("button_action");
            zoom_in_button.clicked.connect (() => {
                if (scale.get_value () < 10.0) {
                    scale.set_value (scale.get_value () + 0.1);
                }
            });
            zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.BUTTON);
            zoom_out_button.tooltip_text = StringPot.Zoom_Out;
            zoom_out_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            zoom_out_button.get_style_context ().add_class ("button_action");
            zoom_out_button.clicked.connect (() => {
                if (scale.get_value () > 1.0) {
                    scale.set_value (scale.get_value () - 0.1);
                }
            });
            var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            content_box.get_style_context ().add_class ("playlist");
            content_box.margin = 5;
            content_box.pack_start (zoom_in_button, false, false, 0);
            content_box.pack_start (scale, true, true, 0);
            content_box.pack_start (zoom_out_button, false, false, 0);
            add (content_box);
            show_all ();
            sensitive_button ();
        }
        private void sensitive_button () {
            zoom_out_button.sensitive = scale.get_value () == 1? false : true;
            zoom_in_button.sensitive = scale.get_value () == 10? false : true;
        }
        public void reveal_control () {
            set_reveal_child (true);
            margin_top = 120;
            margin_bottom = 120;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }

            hiding_timer = GLib.Timeout.add_seconds (2, () => {
                if (hovered) {
                    hiding_timer = 0;
                    return false;
                }
                set_reveal_child (false);
                hiding_timer = 0;
                return false;
            });
        }
    }
}
