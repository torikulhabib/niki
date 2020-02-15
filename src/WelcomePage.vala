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
    public class WelcomePage : Gtk.Grid {
        private WelcomeSource? welcome_rigth;
        private WelcomeSource? welcome_left;
        private InfoBar? infobar;
        private Gtk.Label title_label;
        private Gtk.Label subtitle_label;
        public ScanFolder? scanfolder;
        public GetLink? getlink;
        public Gtk.Stack stack;
        public DLNAMain? dlnamain;
        public DLNATreeView? treview;
        public DLNARenderControl? dlnarendercontrol;
        public DLNAAction? dlnaaction;

        construct {
            dlnamain = new DLNAMain (this);
            treview = new DLNATreeView (this);
            treview.reload_device.connect (() => {
                dlnamain.init_upnp_media_server ();
                dlnamain.contextmanager_media_server.rescan_control_points ();
            });
            dlnarendercontrol = new DLNARenderControl (this);
            dlnaaction = new DLNAAction (this);
            dlnarendercontrol.changed.connect (()=> {
                if (!dlnarendercontrol.get_selected_device ()) {
                    dlnaaction.set_reveal_child (true);
                } else {
                    dlnaaction.set_reveal_child (false);
                }
            });
            set_size_request (570, 430);
            scanfolder = new ScanFolder ();
            getlink = new GetLink ();
            infobar = new InfoBar ();
            title_label = new Gtk.Label (StringPot.Select_Menu);
            title_label.justify = Gtk.Justification.CENTER;
            title_label.hexpand = true;
            title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

            subtitle_label = new Gtk.Label (StringPot.DND_Home);
            subtitle_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            subtitle_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            subtitle_label.justify = Gtk.Justification.CENTER;
            subtitle_label.hexpand = true;
            subtitle_label.wrap = true;
            subtitle_label.wrap_mode = Pango.WrapMode.WORD;

            welcome_rigth = new WelcomeSource ();
            welcome_rigth.append ("applications-multimedia", StringPot.Open_File, StringPot.Open_File);
            welcome_rigth.append ("edit-paste", StringPot.Paste_URL, StringPot.Play_Stream);
            welcome_rigth.append ("document-open", StringPot.Open_Folder, StringPot.Open_Folder);
            welcome_rigth.append ("camera-web", StringPot.Open_Camera, StringPot.Camera_Device);

            welcome_left = new WelcomeSource ();
            welcome_left.append ("folder-videos", StringPot.Browse_Library, StringPot.Movie_Library);
            welcome_left.append ("folder-music", StringPot.Browse_Library, StringPot.Music_Library);
            welcome_left.append ("folder-remote", StringPot.Browse_Library, StringPot.DLNA_Library);
            welcome_left.append ("media-optical", StringPot.Browse_Library, StringPot.Optical_Library);

            var grid_home = new Gtk.Grid ();
            grid_home.get_style_context ().add_class ("widget_background");
            grid_home.orientation = Gtk.Orientation.HORIZONTAL;
            grid_home.margin_bottom = 30;
            grid_home.add (welcome_rigth);
            grid_home.add (welcome_left);

            var vertical_grid = new Gtk.Grid ();
            vertical_grid.get_style_context ().add_class ("widget_background");
            vertical_grid.orientation = Gtk.Orientation.VERTICAL;
            vertical_grid.valign = Gtk.Align.CENTER;
            vertical_grid.margin = 15;
            vertical_grid.add (title_label);
            vertical_grid.add (subtitle_label);
            vertical_grid.add (grid_home);

            var dlna_scrolled = new Gtk.ScrolledWindow (null, null);
            dlna_scrolled.get_style_context ().add_class ("dlna_scrollbar");
            dlna_scrolled.add (treview);
            dlna_scrolled.show_all ();
            var dlna_grid = new Gtk.Grid ();
            dlna_grid.orientation = Gtk.Orientation.VERTICAL;
            dlna_grid.margin = 10;
            dlna_grid.add (dlna_scrolled);
            dlna_grid.add (dlnaaction);
            dlna_grid.add (dlnarendercontrol);

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            stack.transition_duration = 500;
            stack.add_named (vertical_grid, "home");
            stack.add_named (dlna_grid, "dlna");
            stack.visible_child = vertical_grid;
            stack.vhomogeneous = false;
            stack.show_all ();

            var overlay = new Gtk.Overlay ();
            overlay.add (stack);
            overlay.add_overlay (infobar);
            var eventbox = new Gtk.EventBox ();
            eventbox.get_style_context ().add_class ("widget_background");
            eventbox.add (overlay);
            add (eventbox);
            show_all ();

            bool mouse_primary_down = false;
            motion_notify_event.connect ((event) => {
                if (mouse_primary_down) {
                    mouse_primary_down = false;
                    window.begin_move_drag (Gdk.BUTTON_PRIMARY, (int)event.x_root, (int)event.y_root, event.time);
                }
                return false;
            });

            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    mouse_primary_down = true;
                }
                if (event.button == Gdk.BUTTON_PRIMARY && event.type == Gdk.EventType.2BUTTON_PRESS && window.welcome_page.stack.visible_child_name == "home") {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    mouse_primary_down = false;
                }
                return false;
            });
            getlink.errormsg.connect ((links) => {
                infobar.title = links;
                infobar.send_notification ();
                welcome_left.sensitive = true;
                welcome_rigth.sensitive = true;
                links = null;
            });

            getlink.process_all.connect ((links) => {
                window.player_page.playlist_widget ().add_stream (links);
                welcome_left.sensitive = true;
                welcome_rigth.sensitive = true;
		        if (window.main_stack.visible_child_name == "welcome") {
                    window.player_page.play_first_in_playlist ();
                }
                links = null;
            });
            scanfolder.signal_notify.connect((notif)=> {
                infobar.title = notif;
                infobar.send_notification ();
            });

            welcome_rigth.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        window.run_open_file (true);
                        if (NikiApp.settings.get_boolean ("stream-mode")) {
                            NikiApp.settings.set_boolean ("stream-mode", false);
                        }
                        break;
                    case 1:
                        if (!NikiApp.settings.get_boolean ("stream-mode")) {
                            NikiApp.settings.set_boolean ("stream-mode", true);
                        }
                        window.player_page.playlist_widget ().clear_items ();
                        Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);
                        string text = clipboard.wait_for_text ().strip ();
                        if (text == null) {
                            return;
                        }
                        getlink.get_link_stream (text);
                        welcome_left.sensitive = false;
                        welcome_rigth.sensitive = false;
                        break;
                    case 2:
                        window.player_page.playlist_widget ().clear_items ();
                        window.run_open_folder ();
                        if (NikiApp.settings.get_boolean ("stream-mode")) {
                            NikiApp.settings.set_boolean ("stream-mode", false);
                        }
                        break;
                    case 3:
		                window.main_stack.visible_child_name = "camera";
		                window.camera_page.ready_play ();
                        break;
                }
            });
            welcome_left.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        window.player_page.playlist_widget ().clear_items ();
                        scanfolder.scanning (GLib.Environment.get_user_special_dir (UserDirectory.VIDEOS), 1);
                        if (NikiApp.settings.get_boolean ("stream-mode")) {
                            NikiApp.settings.set_boolean ("stream-mode", false);
                        }
                        break;
                    case 1:
                        window.player_page.playlist_widget ().clear_items ();
                        scanfolder.scanning (GLib.Environment.get_user_special_dir (UserDirectory.MUSIC), 2);
                        if (NikiApp.settings.get_boolean ("stream-mode")) {
                            NikiApp.settings.set_boolean ("stream-mode", false);
                        }
                        break;
                    case 2:
                        stack.visible_child = dlna_grid;
                        break;
                    case 3:
                        read_first_disk.begin ();
                        break;
                }
            });
        }
        private async void read_first_disk () {
            var disk_manager = new DiskManager ().instance;
            if (!disk_manager.has_media_volumes ()) {
                infobar.title = StringPot.Disk_Empty;
                infobar.send_notification ();
                return;
            }
            if (disk_manager.get_volumes ().is_empty) {
                infobar.title = StringPot.Disk_Empty;
                infobar.send_notification ();
                return;
            }

            var volume = disk_manager.get_volumes ().first ();
            if (volume.can_mount () == true && volume.get_mount ().can_unmount () == false) {
                try {
                    yield volume.mount (MountMountFlags.NONE, null);
                } catch (Error e) {
                    critical (e.message);
                }
            }

            var root = volume.get_mount ().get_default_location ();
            string uri_file = root.get_uri ().replace ("file:///", "dvd:///");
            window.player_page.playlist_widget ().add_item (File.new_for_uri (uri_file));
		    if (window.main_stack.visible_child_name == "welcome") {
                window.player_page.play_first_in_playlist ();
            }
        }
    }
}
