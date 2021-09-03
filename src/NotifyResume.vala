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
    public class NotifyResume : Gtk.Revealer {
        public signal void resume_play (double progress);
        private PlayerPage? playerpage;
        private Gtk.Label time_label;
        private Gtk.Label resume_label;
        private Gtk.Label attention_label;
        private double progress;
        private bool _hovered = false;
        public bool hovered {
            get {
                return _hovered;
            }
            set {
                _hovered = value;
            }
        }

        public NotifyResume (PlayerPage playerpage) {
            get_style_context ().add_class ("playlist");
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
                if (((Gtk.Window) get_toplevel ()).is_active) {
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
            this.playerpage = playerpage;
            var icon_image = new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.DIALOG) {
                valign = Gtk.Align.END,
                halign = Gtk.Align.END
            };

            resume_label = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 30,
                use_markup = true,
                wrap = true,
                xalign = 0
            };
            resume_label.get_style_context ().add_class ("primary");

            time_label = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 30,
                use_markup = true,
                wrap = true,
                xalign = 0
            };
            attention_label = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 30,
                use_markup = true,
                wrap = true,
                xalign = 0
            };

            var cancel_resume = new Gtk.Button.with_label (_("NO, THANKS"));
            cancel_resume.clicked.connect (() => {
                set_reveal_child (false);
            });
            var resume_now = new Gtk.Button.with_label (_("YES, PLEASE"));
            resume_now.clicked.connect (() => {
                resume_play (progress);
                set_reveal_child (false);
            });

            notify["child-revealed"].connect (()=> {
                if (child_revealed) {
                    resume_now.grab_focus ();
                }
            });

            var box_action = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                margin_top = 5,
                column_spacing = 5,
                margin_start = 5,
                margin_bottom = 10,
                margin_end = 5,
                hexpand = true,
                column_homogeneous = true
            };

            box_action.add (cancel_resume);
            box_action.add (resume_now);

            var message_grid = new Gtk.Grid () {
                margin_start = 5,
                margin_top = 10,
                margin_end = 5,
                column_spacing = 0,
                width_request = 350
            };
            message_grid.attach (icon_image, 0, 0, 1, 3);
            message_grid.attach (resume_label, 1, 0, 1, 1);
            message_grid.attach (time_label, 1, 1, 1, 1);
            message_grid.attach (attention_label, 1, 2, 1, 1);

            var box_mix = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                hexpand = true,
                column_homogeneous = true
            };

            box_mix.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_mix.add (message_grid);
            box_mix.add (box_action);

            add (box_mix);
            show_all ();
        }

        private uint hiding_timer = 0;
        public void reveal_control (double duration, double progress, string auvi) {
            this.progress = progress;
            time_label.label = _("You left off at %s").printf (seconds_to_time ((int)(progress * duration)));
            resume_label.label = Markup.escape_text (NikiApp.settings.get_string ("title-playing"));
            attention_label.label = _("Would you like to resume %s?").printf (auvi);
            if (!child_revealed) {
                set_reveal_child (true);
            }
            margin_end = margin_start = 5;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add_seconds (15, () => {
                set_reveal_child (false);
                hiding_timer = 0;
                return Source.REMOVE;
            });
        }
    }
}
