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
    public class CameraBottomBar : Gtk.EventBox {
        private Gtk.Revealer timer_revealer;
        private Gtk.Revealer setting_revealer;
        private Gtk.Label timer_label;
        public Gtk.Button capture_button;
        public TimerButton? timer_button;
        public CameraGrid? cameragrid;
        public Gtk.Button setting_button;
        public Gtk.Button option_button;
        private Gtk.ListStore liststrore;
        private AsyncImage? asyncimage;
        private uint video_timer = 0;
        private uint image_timer = 0;
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
                capture_button.tooltip_text = value? _("Stop") : _("Record");
            }
        }

        public CameraBottomBar (CameraPage camerapage) {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            liststrore = new Gtk.ListStore (ColumnCamPre.N_COLUMNS, typeof (string), typeof (string));
            ((Gtk.TreeSortable)liststrore).set_sort_column_id (1, Gtk.SortType.DESCENDING);
            enter_notify_event.connect ((event) => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    if (event.window == get_window ()) {
                        hovered = true;
                    }
                }
                return false;
            });

            motion_notify_event.connect (() => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    hovered = true;
                }
                return false;
            });
            button_press_event.connect (() => {
                hovered = true;
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect (() => {
                hovered = true;
                return false;
            });
            leave_notify_event.connect ((event) => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    if (event.window == get_window ()) {
                        hovered = false;
                    }
                }
                return false;
            });

            option_button = new Gtk.Button.from_icon_name ("camera-photo-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            option_button.focus_on_click = false;
            option_button.get_style_context ().add_class ("button_action");
            option_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            option_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("camera-video", !NikiApp.settings.get_boolean ("camera-video"));
            });

            capture_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.record-symbolic", Gtk.IconSize.DIALOG);
            capture_button.focus_on_click = false;
            capture_button.get_style_context ().add_class ("button_action");
            capture_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
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
            timer_button.focus_on_click = false;
            timer_label = new Gtk.Label (null);
            timer_label.get_style_context ().add_class ("button_action");
            timer_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            timer_label.get_style_context ().add_class ("h2");
            timer_label.ellipsize = Pango.EllipsizeMode.END;
            timer_revealer = new Gtk.Revealer ();
            timer_revealer.add (timer_label);

            cameragrid = new CameraGrid (camerapage);
            cameragrid.init ();
            var camera_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            camera_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            camera_actionbar.get_style_context ().add_class ("transbgborder");
            camera_actionbar.set_center_widget (cameragrid);
            camera_actionbar.hexpand = true;
            setting_revealer = new Gtk.Revealer ();
            setting_revealer.add (camera_actionbar);
            setting_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            setting_revealer.transition_duration = 500;
            setting_button = new Gtk.Button.from_icon_name ("applications-graphics-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            setting_button.focus_on_click = false;
            setting_button.tooltip_text = _("Setting Filter");
            setting_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            setting_button.get_style_context ().add_class ("button_action");
            setting_revealer.set_reveal_child (NikiApp.settings.get_boolean ("setting-camera"));
            setting_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("setting-camera", !NikiApp.settings.get_boolean ("setting-camera"));
                setting_revealer.set_reveal_child (NikiApp.settings.get_boolean ("setting-camera"));
            });

            asyncimage = new AsyncImage (true);
            asyncimage.get_style_context ().add_class ("button_action");
            asyncimage.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            asyncimage.pixel_size = 48;
            asyncimage.valign = Gtk.Align.CENTER;
            asyncimage.valign = Gtk.Align.CENTER;

            var openimage = new Gtk.Button ();
            openimage.focus_on_click = false;
            openimage.tooltip_text = "Photos";
            openimage.valign = Gtk.Align.CENTER;
            openimage.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            openimage.get_style_context ().add_class ("button_action");
            openimage.add (asyncimage);

            var main_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.set_center_widget (capture_button);
            main_actionbar.pack_start (option_button, false, false, 0);
            main_actionbar.pack_start (timer_button, false, false, 0);
            main_actionbar.pack_end (openimage, false, false, 0);
            main_actionbar.pack_end (setting_button, false, false, 0);
            main_actionbar.hexpand = true;
            main_actionbar.margin_start = 4;
            main_actionbar.margin_end = 4;
            main_actionbar.margin_bottom = 10;
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
            camera_video ();
            liststrore.row_inserted.connect (open_prev);
            camerapage.cameraplayer.was_capture.connect (load_all);
        }
        public bool load_all () {
            load_image ();
            open_prev ();
            return false;
        }
        public void load_image () {
            int img_s = liststrore.iter_n_children (null);
            for (int i = 0; i < img_s; i++) {
                Gtk.TreeIter iter;
                if (liststrore.get_iter_first (out iter)){
                    liststrore.remove (ref iter);
                }
            }
	        File file = File.new_for_path (get_media_directory ());
	        file.enumerate_children_async.begin ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, Priority.DEFAULT, null, (obj, res) => {
		        try {
			        FileEnumerator enumerator = file.enumerate_children_async.end (res);
			        FileInfo info;
			        while ((info = enumerator.next_file (null)) != null) {
                        if (info.get_content_type ().has_prefix ("video/") && NikiApp.settings.get_boolean ("camera-video")) {
                            var found_path = GLib.File.new_build_filename (file.get_path (), info.get_name ());
                            prev_liststore (found_path.get_uri (), found_path.get_basename ());
                        }
                        if (info.get_content_type ().has_prefix ("image/") && !NikiApp.settings.get_boolean ("camera-video")) {
                            var found_path = GLib.File.new_build_filename (file.get_path (), info.get_name ());
                            prev_liststore (found_path.get_uri (), found_path.get_basename ());
                        }
			        }
		        } catch (Error e) {
			        warning ("Error: %s\n", e.message);
		        }
        	});
        }
        private void prev_liststore (string file_name, string title_name) {
            bool exist = false;
            liststrore.foreach ((model, path, iter) => {
                string filename;
                model.get (iter, 0, out filename);
                if (filename == file_name) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }
            Gtk.TreeIter iter;
            liststrore.append (out iter);
            liststrore.set (iter, ColumnCamPre.FILENAME, file_name, ColumnCamPre.TITLE, title_name);
        }
        private void open_prev () {
            if (!NikiApp.settings.get_boolean ("camera-video")) {
                if (image_timer != 0) {
                    Source.remove (image_timer);
                }
                image_timer = GLib.Timeout.add (50, () => {
                    if (file_stored () != null) {
                        pix_loader (pix_file (File.new_for_uri (file_stored ()).get_path ()));
                    } else {
                        asyncimage.set_from_pixbuf (from_theme_icon ("avatar-default-symbolic", 128, 48));
                        asyncimage.show ();
                    }
                    image_timer = 0;
                    return Source.REMOVE;
                });
            } else {
                if (video_timer != 0) {
                    Source.remove (video_timer);
                }
                video_timer = GLib.Timeout.add (50, () => {
                    if (file_stored () != null) {
                        var video_file = File.new_for_uri (file_stored ());
                        if (!FileUtils.test (normal_thumb (video_file), FileTest.EXISTS)) {
                            var dbus_Thum = new DbusThumbnailer ().instance;
                            dbus_Thum.instand_thumbler (video_file, "normal");
                            dbus_Thum.load_finished.connect (()=>{
                                if (pix_file (normal_thumb (video_file)) != null) {
                                    pix_loader (pix_file (normal_thumb (video_file)));
                                }
                            });
                        } else {
                            if (pix_file (normal_thumb (video_file)) != null) {
                                pix_loader (pix_file (normal_thumb (video_file)));
                            }
                        }
                    } else {
                        asyncimage.set_from_pixbuf (from_theme_icon ("avatar-default-symbolic", 128, 48));
                        asyncimage.show ();
                    }
                    video_timer = 0;
                    return Source.REMOVE;
                });
            }
        }

        public string? file_stored () {
            Gtk.TreeIter iter;
            if (liststrore.get_iter_first (out iter)){
                string filename;
                liststrore.get (iter, ColumnCamPre.FILENAME, out filename);
                return filename;
            }
            return null;
        }

        private void pix_loader (Gdk.Pixbuf pixbuf) {
            asyncimage.set_from_pixbuf (align_and_scale_pixbuf (circle_pix (pixbuf), 48));
            asyncimage.show ();
        }

        private void camera_video () {
            ((Gtk.Image) option_button.image).icon_name = (NikiApp.settings.get_boolean ("camera-video")? "com.github.torikulhabib.niki.capture-symbolic" : "com.github.torikulhabib.niki.record-symbolic");
            option_button.tooltip_text = NikiApp.settings.get_boolean ("camera-video")? _("Camera") : _("Video");
            ((Gtk.Image) capture_button.image).icon_name = (NikiApp.settings.get_boolean ("camera-video")? "com.github.torikulhabib.niki.record-symbolic" : "com.github.torikulhabib.niki.capture-symbolic");
            capture_button.tooltip_text = NikiApp.settings.get_boolean ("camera-video")? _("Record") : _("Capture");
            timer_button.sensitive = NikiApp.settings.get_boolean ("camera-video")? false : true;
            load_all ();
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
