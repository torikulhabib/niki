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
            camera_page = new CameraPage (this);
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

            main_stack.notify["visible-child"].connect (() => {
                headerbar_mode ();
            });
            welcome_page.stack.notify["visible-child"].connect (() => {
                home_revealer.set_reveal_child (welcome_page.stack.visible_child_name == "dlna"? true : false);
                headerbar.title = welcome_page.stack.visible_child_name == "dlna"? StringPot.Niki_DLNA_Browser : StringPot.Niki;
            });
            main_stack.notify["visible-child"].connect (() => {
                home_revealer.set_reveal_child (welcome_page.stack.visible_child_name == "dlna"? true : false);
                headerbar.title = welcome_page.stack.visible_child_name == "dlna"? StringPot.Niki_DLNA_Browser : StringPot.Niki;
            });

            home_button.clicked.connect (() => {
                welcome_page.stack.visible_child_name = "home";
                player_page.top_bar.button_home ();
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
                return new KeyboardPage ().key_press (e, window);
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
                    NikiApp.settings.set_int ("window-x", root_x);
                    NikiApp.settings.set_int ("window-y", root_y);
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
                Idle.add (() => {
                    string uri = file.get_preview_uri ();
                    if (uri != null && uri.has_prefix ("file://")) {
                        var preview_file = File.new_for_uri (uri);
                        try {
                            Gdk.Pixbuf pixbuf = null;
                            switch (file_type (preview_file)) {
                                case 0 :
                                    var videopreview = new VideoPreview (preview_file.get_path (), preview_file.get_uri(), get_mime_type (preview_file));
                                    videopreview.run_preview ();
                                    if (get_mime_type (preview_file).has_prefix ("video/")) {
                                        pixbuf = new Gdk.Pixbuf.from_file_at_scale (videopreview.set_preview_large (), 256, 256, true);
                                    }
                                    break;
                                case 1 :
                                    var audiocover = new AudioCover();
                                    audiocover.import (preview_file.get_uri ());
                                    pixbuf = audiocover.pixbuf_albumart;
                                    break;
                            }
                            if (pixbuf != null) {
                                label.label = get_info_file (preview_file);
                                preview_area.set_from_pixbuf (pixbuf);
                                preview_area.show ();
                                file.set_preview_widget_active (true);
                            }
                        } catch (Error e) {
                            GLib.warning (e.message);
                            return true;
                        }
                    } else {
                        preview_area.hide ();
                        file.set_preview_widget_active (false);
                    }
                    return Source.REMOVE;
                });
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

       public void run_open_folder () {
            var folder_location = new Gtk.FileChooserDialog (
                StringPot.Open, this, Gtk.FileChooserAction.SELECT_FOLDER,
                StringPot.Cancel, Gtk.ResponseType.CANCEL,
                StringPot.Open, Gtk.ResponseType.ACCEPT);
            folder_location.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var filter_folder = new Gtk.FileFilter ();
            filter_folder.add_mime_type ("inode/directory");
            folder_location.set_filter (filter_folder);

            if (folder_location.run () == Gtk.ResponseType.ACCEPT) {
                NikiApp.settings.set_string ("folder-location", folder_location.get_file ().get_path ());
                welcome_page.scanfolder.scanning (NikiApp.settings.get_string ("folder-location"), 0);
            }
            folder_location.destroy ();
        }

        public void open_files (File[] files, bool clear_playlist = false, bool force_play = true) {
            if (clear_playlist) {
                player_page.playlist_widget ().clear_items ();
            }
            string [] videos = {};
            foreach (var file in files) {
                player_page.playlist_widget ().add_item (file);
                videos += file.get_uri ();
            }
            if (force_play && videos.length > 0) {
                string videofile = videos [0];
                var file = File.new_for_uri (videofile);
                play_file (videofile, get_info_size (videofile), file_type (file));
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
			        break;
		        case Target.URILIST:
		            if (main_stack.visible_child_name == "welcome") {
                        player_page.playlist_widget ().clear_items ();
                    }
                    string [] videos = {};
                    foreach (var uri in selection_data.get_uris ()) {
                        var file = File.new_for_uri (uri);
                        player_page.playlist_widget ().add_item (file);
                        videos += file.get_uri ();
                    };
                    if (videos.length > 0) {
                        string videofile = videos [0];
                        if (!player_page.playback.playing) {
                            var file = File.new_for_uri (videofile);
                            play_file (videofile, get_info_size (videofile), file_type (file));
                        }
                    }
			        break;
		    }
        }

        public void play_file (string uri, string filesize, int mediatype, bool from_beginning = true) {
            NikiApp.settings.set_string ("tittle-playing", Markup.escape_text (get_song_info (File.new_for_uri (uri))));
            if (get_mime_type (File.new_for_uri (uri)).has_prefix ("audio/")) {
                NikiApp.settings.set_string ("artist-music", get_artist_music (uri));
                NikiApp.settings.set_string ("album-music", get_album_music (uri));
            }
            player_page.play_file (uri, filesize, mediatype, from_beginning);
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
