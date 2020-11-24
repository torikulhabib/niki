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
        public Welcome? welcome_rigth;
        public Welcome? welcome_left;
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
        public CircularGrid? circulargrid;
        public Gtk.ListStore liststore;
        public int index_but;

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
            liststore = new Gtk.ListStore (ColumnScanF.N_COLUMNS, typeof (string));
            set_size_request (570, 430);
            scanfolder = new ScanFolder ();
            getlink = new GetLink ();
            infobar = new InfoBar ();
            title_label = new Gtk.Label (_("Select Menu"));
            title_label.justify = Gtk.Justification.CENTER;
            title_label.hexpand = true;
            title_label.get_style_context ().add_class ("h2");

            subtitle_label = new Gtk.Label (_("Drag Url, files or Select a source to playing."));
            subtitle_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            subtitle_label.get_style_context ().add_class ("h3");
            subtitle_label.justify = Gtk.Justification.CENTER;
            subtitle_label.hexpand = true;
            subtitle_label.can_focus = true;
            subtitle_label.wrap = true;
            subtitle_label.margin_bottom = 10;
            subtitle_label.wrap_mode = Pango.WrapMode.WORD;

            welcome_rigth = new Welcome ();
            welcome_rigth.focus_on_click = false;
            welcome_rigth.append ("applications-multimedia", _("Open File"), _("Open File"));
            welcome_rigth.append ("edit-paste", _("Paste URL"), _("Play Stream"));
            welcome_rigth.append ("document-open", _("Open Folder"), _("Open Folder"));
            welcome_rigth.append ("camera-photo", _("Open Camera"), _("Camera Device"));
            welcome_rigth.get_style_context ().add_class ("card");

            welcome_left = new Welcome ();
            welcome_left.focus_on_click = false;
            welcome_left.append ("folder-videos", _("Browse Library"), _("Movie Library"));
            welcome_left.append ("folder-music", _("Browse Library"), _("Music Library"));
            welcome_left.append ("folder-remote", _("Browse Library"), _("DLNA Library"));
            welcome_left.append ("media-optical", _("Browse Library"), _("Optical Library"));
            welcome_left.get_style_context ().add_class ("card");

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
            var frame = new Gtk.Frame (null);
            frame.margin_bottom = 5;
            frame.add (dlna_scrolled);

            var welcome_drive = new Welcome ();
            welcome_drive.append ("media-optical", _("Browse"), _("DVD"));
            welcome_drive.append ("media-optical", _("Browse"), _("ACD"));
            welcome_drive.valign = Gtk.Align.CENTER;
            welcome_drive.get_style_context ().add_class ("widget_background");
            welcome_drive.get_style_context ().add_class ("card");
            welcome_drive.margin_bottom = 30;

            var dlna_grid = new Gtk.Grid ();
            dlna_grid.orientation = Gtk.Orientation.VERTICAL;
            dlna_grid.margin = 10;
            dlna_grid.add (frame);
            dlna_grid.add (dlnaaction);
            dlna_grid.add (dlnarendercontrol);

            circulargrid = new CircularGrid ();

            var devicegrid = new DeviceMonitor ();
            devicegrid.valign = Gtk.Align.CENTER;
            devicegrid.margin_bottom = 30;

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            stack.homogeneous = false;
            stack.transition_duration = 500;
            stack.add_named (vertical_grid, "home");
            stack.add_named (dlna_grid, "dlna");
            stack.add_named (circulargrid, "circular");
            stack.add_named (welcome_drive, "dvd");
            stack.add_named (devicegrid, "device");
            stack.visible_child = vertical_grid;
            stack.show_all ();
            scanfolder.signal_succes.connect ((store_uri)=>{
                start_count (store_uri);
            });
            stack.notify["visible-child"].connect (() => {
                if (stack.visible_child_name == "circular") {
                    circulargrid.circular_clear ();
                }
            });
            var overlay = new Gtk.Overlay ();
            overlay.add (stack);
            overlay.add_overlay (infobar);
            var eventbox = new Gtk.EventBox ();
            eventbox.get_style_context ().add_class ("widget_background");
            eventbox.add (overlay);
            add (eventbox);
            show_all ();

            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY && event.type == Gdk.EventType.2BUTTON_PRESS && NikiApp.window.welcome_page.stack.visible_child_name == "home") {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }
                return Gdk.EVENT_PROPAGATE;
            });

            getlink.errormsg.connect ((links) => {
                infobar.title = links;
                infobar.send_notification ();
                welcome_left.sensitive = true;
                welcome_rigth.sensitive = true;
                NikiApp.settings.set_boolean ("spinner-wait", true);
            });

            getlink.process_all.connect ((links) => {
                NikiApp.window.player_page.right_bar.playlist.add_stream (links);
                welcome_left.sensitive = true;
                welcome_rigth.sensitive = true;
                NikiApp.settings.set_boolean ("spinner-wait", true);
		        if (NikiApp.window.main_stack.visible_child_name == "welcome") {
                    NikiApp.window.player_page.right_bar.playlist.play_first ();
                }
            });
            scanfolder.signal_notify.connect((notif)=> {
                if (stack.visible_child_name == "circular") {
                    stack.visible_child_name = "home";
                }
                infobar.title = notif;
                infobar.send_notification ();
            });

            welcome_rigth.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        remove_all ();
                        var files = run_open_file (this, true, 1);
                        if (files != null) {
                            stack.visible_child_name = "circular";
                            NikiApp.window.player_page.right_bar.playlist.clear_items ();
                            foreach (var file in files) {
                                list_append (file.get_uri ());
                            }
                            start_count (liststore);
                        }
                        break;
                    case 1:
                        NikiApp.window.player_page.right_bar.playlist.clear_items ();
                        Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);
                        string text = clipboard.wait_for_text ().strip ();
                        if (text == null) {
                            return;
                        }
                        getlink.get_link_stream (text);
                        welcome_left.sensitive = false;
                        welcome_rigth.sensitive = false;
                        NikiApp.settings.set_boolean ("spinner-wait", false);
                        break;
                    case 2:
                        var file = run_open_folder (this);
                        if (file != null) {
                            stack.visible_child_name = "circular";
                            NikiApp.window.player_page.right_bar.playlist.clear_items ();
                            scanfolder.remove_all ();
                            scanfolder.scanning (file.get_path (), 0);
                        }
                        break;
                    case 3:
                        devicegrid.start_init ();
                        stack.visible_child_name = "device";
                        break;
                }
            });
            welcome_left.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        stack.visible_child_name = "circular";
                        scanfolder.remove_all ();
                        NikiApp.window.player_page.right_bar.playlist.clear_items ();
                        scanfolder.scanning (GLib.Environment.get_user_special_dir (UserDirectory.VIDEOS), 1);
                        break;
                    case 1:
                        stack.visible_child_name = "circular";
                        scanfolder.remove_all ();
                        NikiApp.window.player_page.right_bar.playlist.clear_items ();
                        scanfolder.scanning (GLib.Environment.get_user_special_dir (UserDirectory.MUSIC), 2);
                        break;
                    case 2:
                        stack.visible_child = dlna_grid;
                        break;
                    case 3:
                        stack.visible_child_name = "dvd";
                        break;
                }
            });
            welcome_drive.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        read_dvd.begin ();
                        break;
                    case 1:
                        read_acd ();
                        break;
                }
            });
        }
        public void start_count (Gtk.ListStore liststore) {
            Timeout.add (750, ()=>{
                circulargrid.count_uri (liststore);
                return false;
            });
        }
        public void list_append (string path) {
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, ColumnScanF.FILENAME, path);
        }
        public void remove_all () {
            if (liststore.iter_n_children (null) > 0) {
                liststore.clear ();
            }
        }
        private async void read_dvd () {
            var dvdanager = new DVDManager ().instance;
            if (!dvdanager.has_media_volumes ()) {
                infobar.title = _("Disk Empty");
                infobar.send_notification ();
                return;
            }

            var volume = dvdanager.get_volumes ().first ();
            if (volume.can_mount () == true && volume.get_mount ().can_unmount () == false) {
                try {
                    yield volume.mount (MountMountFlags.NONE, null);
                } catch (Error e) {
                    critical (e.message);
                }
            }

            var root = volume.get_mount ().get_default_location ();
            string uri_file = root.get_uri ().replace ("file:///", "dvd:///");
            list_append (uri_file);
            stack.visible_child_name = "circular";
            start_count (liststore);
        }
        private void read_acd () {
            var acdmanager = new ACDManager ().instance;
            if (!acdmanager.has_media_volumes ()) {
                infobar.title = _("Disk Empty");
                infobar.send_notification ();
                return;
            }
            acdmanager.get_acd_vol (acdmanager.get_volumes ().first ());
        }
    }
}
