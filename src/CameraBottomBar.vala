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
    public class CameraBottomBar : Gtk.Revealer {
        private Gtk.Revealer timer_revealer;
        private Gtk.Revealer setting_revealer;
        private Gtk.Label timer_label;
        public Gtk.Button capture_button;
        public TimerButton? timer_button;
        public CameraGrid? cameragrid;
        public Gtk.Button setting_button;
        public Gtk.Button option_button;
        private AsyncImage asyncimage;
        private bool _hovered = false;
        public bool hovered {
            get {
                return _hovered;
            }
            set {
                _hovered = value;
            }
        }

        private bool _playing = false;
        public bool playing {
            get {
                return _playing;
            }
            set {
                _playing = value;
                ((Gtk.Image) capture_button.image).icon_name = value? "com.github.torikulhabib.niki.recording-symbolic" : "com.github.torikulhabib.niki.record-symbolic";
                capture_button.tooltip_text = value? StringPot.Stop : StringPot.Record;
            }
        }

        public CameraBottomBar (CameraPage camerapage) {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            set_reveal_child (true);
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;
            get_style_context ().add_class ("ground_action_button");

            enter_notify_event.connect ((event) => {
                if (window.is_active) {
                    if (event.window == get_window ()) {
                        hovered = true;
                    }
                }
                return false;
            });

            motion_notify_event.connect (() => {
                if (window.is_active) {
                    hovered = true;
                }
                return false;
            });

            leave_notify_event.connect ((event) => {
                if (window.is_active) {
                    if (event.window == get_window ()) {
                        hovered = false;
                    }
                }
                return false;
            });

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("ground_action_button");

            var camera_actionbar = new Gtk.ActionBar ();
            camera_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            camera_actionbar.get_style_context ().add_class ("ground_action_button");

            option_button = new Gtk.Button.from_icon_name ("camera-photo-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            option_button.get_style_context ().add_class ("button_action");
            option_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("camera-video", !NikiApp.settings.get_boolean ("camera-video"));
            });

            capture_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.record-symbolic", Gtk.IconSize.DIALOG);
            capture_button.get_style_context ().add_class ("button_action");
            capture_button.clicked.connect (() => {
                if (NikiApp.settings.get_boolean ("camera-video")) {
                    playing = !playing;
                    camerapage.capture_record (playing);
                    if (playing) {
                        start_recording_time ();
                    } else {
                        stop_recording_time ();
                    }
                } else {
                    camerapage.capture_record (playing);
                }
            });

            timer_button = new TimerButton ();
            timer_label = new Gtk.Label (null);
            timer_label.get_style_context ().add_class ("ground_action_button");
            timer_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            timer_label.ellipsize = Pango.EllipsizeMode.END;
            timer_revealer = new Gtk.Revealer ();
            timer_revealer.add (timer_label);

            cameragrid = new CameraGrid (camerapage);
            cameragrid.init ();
            camera_actionbar.set_center_widget (cameragrid);
            camera_actionbar.hexpand = true;
            setting_revealer = new Gtk.Revealer ();
            setting_revealer.add (camera_actionbar);
            setting_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            setting_revealer.transition_duration = 500;
            setting_button = new Gtk.Button.from_icon_name ("applications-graphics-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            setting_button.tooltip_text = StringPot.Setting_Filter;
            setting_button.get_style_context ().add_class ("button_action");
            setting_revealer.set_reveal_child (NikiApp.settings.get_boolean ("setting-camera"));
            setting_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("setting-camera", !NikiApp.settings.get_boolean ("setting-camera"));
                setting_revealer.set_reveal_child (NikiApp.settings.get_boolean ("setting-camera"));
            });
            asyncimage = new AsyncImage (true);
            asyncimage.pixel_size = 60;
            asyncimage.margin_end = 12;
            asyncimage.valign = Gtk.Align.CENTER;
            var image_grid = new Gtk.Grid ();
            image_grid.set_size_request (32, 32);
            image_grid.valign = Gtk.Align.CENTER;
            image_grid.add (asyncimage);
            asyncimage.set_from_pixbuf (new ObjectPixbuf().from_theme_icon ("image-x-generic-symbolic", 128, 48));
            main_actionbar.set_center_widget (capture_button);
            main_actionbar.pack_start (option_button);
            main_actionbar.pack_start (timer_button);
            main_actionbar.pack_end (image_grid);
            main_actionbar.pack_end (setting_button);
            main_actionbar.hexpand = true;
            main_actionbar.margin_bottom = 15;
            main_actionbar.show_all ();

		    var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.get_style_context ().add_class ("bottombar");
            grid.margin = grid.row_spacing = grid.column_spacing = grid.margin_top = 0;
            grid.hexpand = true;
            grid.add (timer_revealer);
            grid.add (main_actionbar);
            grid.add (setting_revealer);
            grid.show_all ();
            add (grid);
            show_all ();
            NikiApp.settings.changed["camera-video"].connect (camera_video);
            bind_property ("playing", option_button, "sensitive", BindingFlags.INVERT_BOOLEAN);
            bind_property ("playing", option_button, "sensitive", BindingFlags.INVERT_BOOLEAN);
            camera_video ();
        }
        public void select_image (string inpu_data) {
            try {
                Gdk.Pixbuf pixbuf = null;
                pixbuf = new Gdk.Pixbuf.from_file_at_scale (inpu_data, 32, 32, true);
                asyncimage.set_from_pixbuf (pixbuf);
                asyncimage.show ();
            } catch (Error e) {
                GLib.warning (e.message);
            }
        }
        private void camera_video () {
            ((Gtk.Image) option_button.image).icon_name = (NikiApp.settings.get_boolean ("camera-video")? "com.github.torikulhabib.niki.capture-symbolic" : "com.github.torikulhabib.niki.record-symbolic");
            option_button.tooltip_text = NikiApp.settings.get_boolean ("camera-video")? StringPot.Camera : StringPot.Video;
            ((Gtk.Image) capture_button.image).icon_name = (NikiApp.settings.get_boolean ("camera-video")? "com.github.torikulhabib.niki.record-symbolic" : "com.github.torikulhabib.niki.capture-symbolic");
            capture_button.tooltip_text = NikiApp.settings.get_boolean ("camera-video")? StringPot.Record : StringPot.Capture;
            timer_button.sensitive = NikiApp.settings.get_boolean ("camera-video")? false : true;
        }

        private uint recording_timeout = 0U;
        public void start_recording_time () {
            timer_revealer.reveal_child = true;
            int seconds = 0;
            timer_label.label = seconds_to_time (seconds);
            recording_timeout = Timeout.add_seconds (1, () => {
                seconds++;
                timer_label.label = seconds_to_time (seconds);
                return GLib.Source.CONTINUE;
            });
        }

        public void stop_recording_time () {
            timer_revealer.reveal_child = false;
            GLib.Source.remove (recording_timeout);
            recording_timeout = 0U;
        }
    }
}
