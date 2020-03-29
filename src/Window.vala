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
    public class Window : Gtk.Window {
	    private static Gtk.TargetEntry [] target_list;
        public PlayerPage player_page;
        public CameraPage camera_page;
        public WelcomePage? welcome_page;
        public Gtk.Stack main_stack;
        private Gtk.HeaderBar headerbar;

        construct {
	        Gtk.TargetEntry string_entry = { "STRING", 0, Target.STRING};
	        Gtk.TargetEntry urilist_entry = { "text/uri-list", 0, Target.URILIST};
	        target_list += string_entry;
	        target_list += urilist_entry;
            set_default_size (570, 430);
            welcome_page = new WelcomePage ();
            player_page = new PlayerPage (this);
            camera_page = new CameraPage ();
            player_page.playback.notify["playing"].connect (position_window);
            var home_button = new Gtk.Button.from_icon_name ("go-home-symbolic", Gtk.IconSize.BUTTON);
            home_button.get_style_context ().add_class ("button_action");
            home_button.tooltip_text = StringPot.Home;
            var home_revealer = new Gtk.Revealer ();
            home_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            home_revealer.add (home_button);
            var light_dark = new LightDark ();
            var spinner = new Gtk.Spinner ();
            var spinner_revealer = new Gtk.Revealer ();
            spinner_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            spinner_revealer.add (spinner);
            headerbar = new Gtk.HeaderBar ();
            headerbar.title = StringPot.Niki;
            headerbar.has_subtitle = false;
            headerbar.show_close_button = true;
            headerbar.decoration_layout = "close:maximize";
            headerbar.pack_start (home_revealer);
            headerbar.pack_end (light_dark);
            headerbar.pack_end (spinner_revealer);
            headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            headerbar.get_style_context ().add_class ("default-decoration");
            set_titlebar (headerbar);
            NikiApp.settings.changed["spinner-wait"].connect (() => {
                spinner_revealer.set_reveal_child (spinner.active = !NikiApp.settings.get_boolean ("spinner-wait")? true : false);
            });
            get_style_context ().add_class ("rounded");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            main_stack = new Gtk.Stack ();
            main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            main_stack.transition_duration = 500;
            main_stack.homogeneous = false;
            main_stack.add_named (welcome_page, "welcome");
            main_stack.add_named (player_page, "player");
            main_stack.add_named (camera_page, "camera");
            main_stack.show_all ();
            add (main_stack);
            show_all ();

            welcome_page.stack.notify["visible-child"].connect (() => {
                home_revealer.set_reveal_child (welcome_page.stack.visible_child_name == "dlna" || welcome_page.stack.visible_child_name == "dvd"? true : false);
                headerbar.title = welcome_page.stack.visible_child_name == "dlna"? StringPot.Niki_DLNA_Browser : StringPot.Niki;
            });
            main_stack.notify["visible-child"].connect (() => {
                headerbar_mode ();
                if (welcome_page.stack.visible_child_name == "circular") {
                    welcome_page.stack.visible_child_name = "home";
                }
                home_revealer.set_reveal_child (welcome_page.stack.visible_child_name == "dlna" || welcome_page.stack.visible_child_name == "dvd"? true : false);
                headerbar.title = welcome_page.stack.visible_child_name == "dlna"? StringPot.Niki_DLNA_Browser : StringPot.Niki;
            });

            home_button.clicked.connect (() => {
                welcome_page.stack.visible_child_name = "home";
            });

            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, target_list, Gdk.DragAction.COPY);
            drag_data_received.connect (on_drag_data_received);
            GLib.Timeout.add (50, headerbar_mode);

            NikiApp.settings.changed["fullscreen"].connect (() => {
                if (NikiApp.settings.get_boolean ("fullscreen")) {
                    unfullscreen ();
                    player_page.stage.set_fullscreen (false);
                } else {
                    fullscreen ();
                    player_page.stage.set_fullscreen (true);
                }
            });
            NikiApp.settings.changed["maximize"].connect (() => {
                if (NikiApp.settings.get_boolean ("maximize")) {
                    unmaximize ();
                } else {
                    maximize ();
                }
            });

            key_press_event.connect ((e) => {
                return new KeyboardPage ().key_press (e, this);
            });

            uint maximize_window = 0;
            size_allocate.connect (() => {
                if (maximize_window != 0) {
                    Source.remove (maximize_window);
                }
                maximize_window = GLib.Timeout.add (50, () => {
                    if (NikiApp.settings.get_boolean ("maximize") == is_maximized) {
                        NikiApp.settings.set_boolean ("maximize", !is_maximized);
                    }
                    maximize_window = 0;
                    return Source.REMOVE;
                });
            });
            uint move_stoped = 0;
            configure_event.connect (() => {
                if (move_stoped != 0) {
                    Source.remove (move_stoped);
                }
                move_stoped = GLib.Timeout.add (500, () => {
                    int height, width;
                    get_size (out width, out height);
                    NikiApp.settings.set_int ("window-width", width);
                    NikiApp.settings.set_int ("window-height", height);
                    int root_x, root_y;
                    get_position (out root_x, out root_y);
                    if (NikiApp.settings.get_boolean ("audio-video") && main_stack.visible_child_name == "player") {
                        NikiApp.settings.set_int ("window-x", root_x);
                        NikiApp.settings.set_int ("window-y", root_y);
                    }
                    move_stoped = 0;
                    return Source.REMOVE;
                });
                return false;
            });
            delete_event.connect (() => {
                if (NikiApp.settings.get_boolean ("audio-video") && player_page.playback.playing) {
                    return hide_on_delete ();
                } else {
                    return destroy_mode ();
                }
            });
            move_widget (this, this);
        }

        public void position_window () {
            set_keep_above (player_page.playback.playing);
        }

        private bool headerbar_mode () {
            if (main_stack.visible_child_name == "welcome") {
                headerbar.show ();
            } else {
                headerbar.hide ();
            }
            return false;
        }

        public void run_open_file (bool clear_playlist = false, bool force_play = true) {
            var file = new Gtk.FileChooserDialog (
            StringPot.Open, this, Gtk.FileChooserAction.OPEN,
            StringPot.Cancel, Gtk.ResponseType.CANCEL,
            StringPot.Open, Gtk.ResponseType.ACCEPT);
            file.select_multiple = true;
            file.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var preview_area = new AsyncImage (true);
            preview_area.pixel_size = 256;
            preview_area.margin_end = 12;

            var all_files_filter = new Gtk.FileFilter ();
            all_files_filter.set_filter_name (StringPot.All_Files);
            all_files_filter.add_pattern ("*");

            var video_filter = new Gtk.FileFilter ();
            video_filter.set_filter_name (StringPot.Audio_Video);
            video_filter.add_mime_type ("video/*");
            video_filter.add_mime_type ("audio/*");

            var label = new Gtk.Label (null);
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            label.ellipsize = Pango.EllipsizeMode.END;
            label.max_width_chars = 20;

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.valign = Gtk.Align.CENTER;
            grid.add (preview_area);
            grid.add (label);
            grid.show_all ();

            file.add_filter (video_filter);
            file.add_filter (all_files_filter);
            file.set_preview_widget (grid);
            file.set_preview_widget_active (false);
            file.set_use_preview_label (false);
            file.update_preview.connect (() => {
                string uri = file.get_preview_uri ();
                if (uri != null && uri.has_prefix ("file://")) {
                    var file_pre = File.new_for_uri (uri);
                    Gdk.Pixbuf pixbuf = null;
                    if (get_mime_type (file_pre).has_prefix ("video/")) {
                        if (!FileUtils.test (large_thumb (file_pre), FileTest.EXISTS)) {
                            var dbus_Thum = new DbusThumbnailer ().instance;
                            dbus_Thum.instand_thumbler (file_pre, "large");
                            dbus_Thum.load_finished.connect (()=>{
                                preview_area.set_from_pixbuf (pix_scale (large_thumb (file_pre), 256));
                                label.label = get_info_file (file_pre);
                                preview_area.show ();
                                file.set_preview_widget_active (true);
                            });
                        } else {
                            pixbuf = pix_scale (large_thumb (file_pre), 256);
                        }
                    } else if (get_mime_type (file_pre).has_prefix ("audio/")) {
                        var audiocover = new AudioCover();
                        audiocover.import (file_pre.get_uri ());
                        pixbuf = audiocover.pixbuf_albumart;
                    }
                    if (pixbuf != null) {
                        label.label = get_info_file (file_pre);
                        preview_area.set_from_pixbuf (pixbuf);
                        preview_area.show ();
                        file.set_preview_widget_active (true);
                    }
                } else {
                    preview_area.hide ();
                    file.set_preview_widget_active (false);
                }
            });

            if (file.run () == Gtk.ResponseType.ACCEPT) {
                File[] files = {};
                foreach (File item in file.get_files ()) {
                    files += item;
                }
                open_files (files, clear_playlist, force_play);
            }
            file.destroy ();
        }

       public bool run_open_folder (int loca_set) {
            var folder_location = new Gtk.FileChooserDialog (
            StringPot.Open, this, Gtk.FileChooserAction.SELECT_FOLDER,
            StringPot.Cancel, Gtk.ResponseType.CANCEL,
            StringPot.Open, Gtk.ResponseType.ACCEPT);
            folder_location.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var filter_folder = new Gtk.FileFilter ();
            filter_folder.add_mime_type ("inode/directory");
            folder_location.set_filter (filter_folder);
            var res = folder_location.run ();
            if (res == Gtk.ResponseType.ACCEPT) {
                switch (loca_set) {
                    case 0 :
                        NikiApp.settings.set_string ("folder-location", folder_location.get_file ().get_path ());
                        break;
                    case 1 :
                        NikiApp.settings.set_string ("lyric-location", folder_location.get_file ().get_path ());
                        break;
                    case 2 :
                        NikiApp.settings.set_string ("ask-lyric", folder_location.get_file ().get_path ());
                        break;
                }
            }
            folder_location.destroy ();
            return res == Gtk.ResponseType.ACCEPT;
        }

        public void open_files (File[] files, bool clear_playlist = false, bool force_play = true) {
            if (clear_playlist) {
                player_page.playlist_widget ().clear_items ();
            }
            foreach (var file in files) {
                player_page.playlist_widget ().add_item (file);
            }
            if (force_play) {
                player_page.play_first_in_playlist ();
            }
        }

        private void on_drag_data_received (Gtk.Widget widget, Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time) {
		    if ((selection_data == null) || !(selection_data.get_length () >= 0)) {
			    return;
		    }
		    switch (target_type) {
		        case Target.STRING:
		            if (main_stack.visible_child_name == "welcome") {
                        player_page.playlist_widget ().clear_items ();
                    }
			        string data = (string) selection_data.get_data ();
                    welcome_page.getlink.get_link_stream (data);
                    welcome_page.welcome_left.sensitive = false;
                    welcome_page.welcome_rigth.sensitive = false;
                    NikiApp.settings.set_boolean ("spinner-wait", false);
			        break;
		        case Target.URILIST:
		            if (main_stack.visible_child_name == "welcome") {
                        player_page.playlist_widget ().clear_items ();
                    }
                    bool audio_video_media = false;
                    foreach (var uri in selection_data.get_uris ()) {
                        File file = File.new_for_uri (uri);
                        if (get_mime_type (file).has_prefix ("video/") || get_mime_type (file).has_prefix ("audio/")) {
                            audio_video_media = true;
                            player_page.playlist_widget ().add_item (file);
                        }
                        if (player_page.playback.playing && main_stack.visible_child_name == "player" && is_subtitle (uri) == true && !NikiApp.settings.get_boolean("audio-video")) {
                            NikiApp.settings.set_string("subtitle-choose", uri);
                            if (!NikiApp.settings.get_boolean("subtitle-available")) {
                                NikiApp.settings.set_boolean ("subtitle-available", true);
                            }
                        }
                    };
		            if (main_stack.visible_child_name == "welcome" && audio_video_media) {
                        player_page.play_first_in_playlist ();
                    }
			        break;
		    }
        }

        public bool is_privacy_mode_enabled () {
            var zeitgeist_manager = new ZeitgeistManager ();
            var privacy_settings = new GLib.Settings ("org.gnome.desktop.privacy");
            bool privacy_mode = privacy_settings.get_boolean ("remember-recent-files") || privacy_settings.get_boolean ("remember-app-usage");
            if (privacy_mode) {
                return true;
            }
            return zeitgeist_manager.app_into_blacklist (NikiApp.instance.application_id);
        }
    }
}
