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
    public class Window : Gtk.Window {
        private static Gtk.TargetEntry [] target_list;
        public PlayerPage? player_page;
        public CameraPage? camera_page;
        public WelcomePage? welcome_page;
        public Gtk.Stack main_stack;
        private Gtk.HeaderBar headerbar;

        construct {
            Gtk.TargetEntry string_entry = { "STRING", 0, Target.STRING};
            Gtk.TargetEntry urilist_entry = { "text/uri-list", 0, Target.URILIST};
            target_list += string_entry;
            target_list += urilist_entry;
            get_style_context ().add_class ("rounded");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");

            set_default_size (570, 430);

            welcome_page = new WelcomePage ();
            player_page = new PlayerPage (this);
            camera_page = new CameraPage ();

            player_page.playback.notify["playing"].connect (position_window);

            var home_button = new Gtk.Button.from_icon_name ("go-home-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Home")
            };

            var home_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.CROSSFADE
            };
            home_revealer.add (home_button);

            var light_dark = new LightDark () {
                focus_on_click = false
            };

            var spinner = new Gtk.Spinner ();
            var spinner_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.CROSSFADE
            };
            spinner_revealer.add (spinner);

            headerbar = new Gtk.HeaderBar () {
                title = _("Niki"),
                has_subtitle = false,
                show_close_button = true,
                decoration_layout = "close:maximize"
            };
            headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            headerbar.get_style_context ().add_class ("default-decoration");
            headerbar.pack_start (home_revealer);
            headerbar.pack_end (light_dark);
            headerbar.pack_end (spinner_revealer);
            set_titlebar (headerbar);

            NikiApp.settings.changed["spinner-wait"].connect (() => {
                spinner_revealer.set_reveal_child (spinner.active = !NikiApp.settings.get_boolean ("spinner-wait")? true : false);
            });

            main_stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
                transition_duration = 500,
                homogeneous = false
            };
            main_stack.add_named (welcome_page, "welcome");
            main_stack.add_named (player_page, "player");
            main_stack.add_named (camera_page, "camera");
            main_stack.show_all ();
            add (main_stack);

            welcome_page.stack.notify["visible-child"].connect (() => {
                home_revealer.set_reveal_child (welcome_page.stack.visible_child_name == "dlna" || welcome_page.stack.visible_child_name == "dvd" || welcome_page.stack.visible_child_name == "device"? true : false);
                headerbar.title = welcome_page.stack.visible_child_name == "dlna"? _("Niki DLNA Browser") : _("Niki");
            });

            main_stack.notify["visible-child"].connect (() => {
                headerbar_mode ();
                if (welcome_page.stack.visible_child_name == "circular") {
                    welcome_page.stack.visible_child_name = "home";
                }
                home_revealer.set_reveal_child (welcome_page.stack.visible_child_name == "dlna" || welcome_page.stack.visible_child_name == "dvd" || welcome_page.stack.visible_child_name == "device"? true : false);
                headerbar.title = welcome_page.stack.visible_child_name == "dlna"? _("Niki DLNA Browser") : _("Niki");
            });

            home_button.clicked.connect (() => {
                welcome_page.stack.visible_child_name = "home";
            });

            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, target_list, Gdk.DragAction.COPY);
            drag_data_received.connect (on_drag_data_received);

            NikiApp.settings.changed["fullscreen"].connect (() => {
                if (NikiApp.settings.get_boolean ("fullscreen")) {
                    unfullscreen ();
                } else {
                    fullscreen ();
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

            uint move_stoped = 0;
            configure_event.connect (() => {
                if (move_stoped != 0) {
                    Source.remove (move_stoped);
                }
                move_stoped = GLib.Timeout.add (500, () => {
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

            uint maximize_window = 0;
            window_state_event.connect ((state)=> {
                if (state.new_window_state.to_string () == Gdk.WindowState.MAXIMIZED.to_string ()) {
                    if (maximize_window != 0) {
                        Source.remove (maximize_window);
                    }
                    maximize_window = GLib.Timeout.add (40, () => {
                        if (NikiApp.settings.get_boolean ("maximize") == is_maximized) {
                            NikiApp.settings.set_boolean ("maximize", !is_maximized);
                        }
                        maximize_window = 0;
                        return Source.REMOVE;
                    });
                }
                return false;
            });

            delete_event.connect (() => {
                if (NikiApp.settings.get_boolean ("audio-video") && player_page.playback.playing) {
                    return hide_on_delete ();
                } else {
                    return destroy_mode ();
                }
            });
            move_widget (this);
            headerbar_mode ();
        }

        public void position_window () {
            set_keep_above (player_page.playback.playing);
        }

        private void headerbar_mode () {
            if (main_stack.visible_child_name == "welcome") {
                headerbar.show ();
            } else {
                headerbar.hide ();
            }
        }

        public void open_files (File[] files, bool clear_playlist = false, bool force_play = true) {
            if (clear_playlist) {
                player_page.right_bar.playlist.clear_items ();
            }
            if (main_stack.visible_child_name == "player") {
                foreach (var file in files) {
                    player_page.right_bar.playlist.add_item (file);
                }
                if (force_play) {
                    player_page.right_bar.playlist.play_first ();
                }
            } else if (main_stack.visible_child_name == "welcome") {
                NikiApp.window.welcome_page.index_but = 1;
                welcome_page.remove_all ();
                foreach (var file in files) {
                    welcome_page.list_append (file.get_uri ());
                }
                welcome_page.stack.visible_child_name = "circular";
                welcome_page.start_count (welcome_page.liststore);
            }
        }

        private void on_drag_data_received (Gtk.Widget widget, Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time) {
            if ((selection_data == null) || !(selection_data.get_length () >= 0)) {
                return;
            }
            switch (target_type) {
                case Target.STRING:
                    if (main_stack.visible_child_name == "welcome") {
                        player_page.right_bar.playlist.clear_items ();
                    }
                    string data = (string) selection_data.get_data ();
                    welcome_page.getlink.get_link_stream (data);
                    welcome_page.welcome_left.sensitive = false;
                    welcome_page.welcome_rigth.sensitive = false;
                    NikiApp.settings.set_boolean ("spinner-wait", false);
                    break;
                case Target.URILIST:
                    File [] files = null;
                    foreach (var uri in selection_data.get_uris ()) {
                        File file = File.new_for_uri (uri);
                        if (get_mime_type (file).has_prefix ("video/") || get_mime_type (file).has_prefix ("audio/")) {
                            files += file;
                        }
                        if (player_page.playback.playing && main_stack.visible_child_name == "player" && is_subtitle (uri) == true && !NikiApp.settings.get_boolean ("audio-video")) {
                            if (!NikiApp.settings.get_boolean ("subtitle-available")) {
                                NikiApp.settings.set_boolean ("subtitle-available", true);
                            }
                            player_page.bottom_bar.menu_popover.file_chooser_subtitle.select_uri (uri);
                            player_page.playback.set_subtittle (uri);
                        }
                    };
                    if (files != null) {
                        if (main_stack.visible_child_name == "welcome") {
                            open_files (files, true);
                        } else if (main_stack.visible_child_name == "player") {
                            open_files (files, false, false);
                        }
                    }
                break;
            }
        }
    }
}
