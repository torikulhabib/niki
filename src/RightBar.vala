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
    public class RightBar : Gtk.Revealer {
        public Playlist? playlist;
        public PlayerPage? player_page;
        private Gtk.Label header_label;
        private Gtk.Button edit_button;
        private RepeatButton? repeat_button;
        private Gtk.ScrolledWindow playlist_scrolled;
        private Gtk.Grid content_box;
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
                    reveal_control (false);
                }
            }
        }

        public RightBar (PlayerPage? player_page) {
            this.player_page = player_page;
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
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
                if (NikiApp.window.is_active) {
                    reveal_control (false);
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

            var open_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
            open_button.get_style_context ().add_class ("button_action");
            open_button.set_tooltip_text (StringPot.Open_File);
            open_button.clicked.connect ( () => {
                NikiApp.window.run_open_file (false, false);
            });
            var add_folder = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.folder-symbolic", Gtk.IconSize.BUTTON);
            add_folder.get_style_context ().add_class ("button_action");
            add_folder.set_tooltip_text (StringPot.Open_Folder);
            add_folder.clicked.connect ( () => {
                if (NikiApp.window.run_open_folder (0)) {
                    NikiApp.window.welcome_page.scanfolder.remove_all ();
                    NikiApp.window.welcome_page.scanfolder.scanning (NikiApp.settings.get_string ("folder-location"), 0);
                    NikiApp.window.welcome_page.scanfolder.signal_succes.connect ((file_list)=>{
                        NikiApp.window.welcome_page.circulargrid.count_uri (file_list);
                    });
                }
            });
            edit_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
            edit_button.get_style_context ().add_class ("button_action");
            edit_button.clicked.connect ( () => {
                NikiApp.settings.set_boolean ("edit-playlist", !NikiApp.settings.get_boolean ("edit-playlist")); 
            });

            var font_button = new Gtk.Button.from_icon_name ("font-x-generic-symbolic", Gtk.IconSize.BUTTON);
            font_button.get_style_context ().add_class ("button_action");
            font_button.tooltip_text = NikiApp.settings.get_string ("font");
            font_button.clicked.connect (() => {
                player_page.bottom_bar.menu_popover.font_button ();
                font_button.tooltip_text = NikiApp.settings.get_string ("font");
            });
            var font_button_revealer = new Gtk.Revealer ();
            font_button_revealer.add (font_button);
            font_button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            font_button_revealer.transition_duration = 100;

            repeat_button = new RepeatButton ();
            var repeat_button_revealer = new Gtk.Revealer ();
            repeat_button_revealer.add (repeat_button);
            repeat_button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            repeat_button_revealer.transition_duration = 100;
            repeat_button_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            font_button_revealer.set_reveal_child (NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("lyric-available"));
            NikiApp.settings.changed["audio-video"].connect (() => {
                repeat_button_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
                font_button_revealer.set_reveal_child (NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("lyric-available"));
            });

            NikiApp.settings.changed["lyric-available"].connect (() => {
                font_button_revealer.set_reveal_child (NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("lyric-available"));
            });

            header_label = new Gtk.Label (null);
            header_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            header_label.ellipsize = Pango.EllipsizeMode.END;
            var focus_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.play-symbolic", Gtk.IconSize.BUTTON);
            focus_button.get_style_context ().add_class ("button_action");
            focus_button.set_tooltip_text (StringPot.Go_to_Play);

            var header = new Gtk.ActionBar ();
            header.get_style_context ().add_class ("playlist");
            header.hexpand = true;
            header.pack_start (focus_button);
            header.set_center_widget (header_label);

		    var box_action = new Gtk.Grid ();
            box_action.orientation = Gtk.Orientation.HORIZONTAL;
		    box_action.add (open_button);
		    box_action.add (add_folder);
		    box_action.add (edit_button);

            playlist = new Playlist();
            playlist_scrolled = new Gtk.ScrolledWindow (null, null);
            playlist_scrolled.get_style_context ().add_class ("scrollbar");
            playlist_scrolled.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            playlist_scrolled.vexpand = true;
            playlist_scrolled.add (playlist);
            playlist_scrolled.show_all ();
            focus_button.clicked.connect ( () => {
                playlist.scroll_to_cell (playlist.set_current (player_page.playback.uri), null, true, (float) 0.5, 0);
            });

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.get_style_context ().add_class ("playlist");
            main_actionbar.hexpand = true;
            main_actionbar.pack_start (box_action);
            main_actionbar.pack_end (font_button_revealer);
            main_actionbar.pack_end (repeat_button_revealer);
            content_box = new Gtk.Grid ();
            content_box.get_style_context ().add_class ("playlist");
            content_box.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            content_box.orientation = Gtk.Orientation.VERTICAL;
            content_box.vexpand = true;
            content_box.add (header);
            content_box.add (playlist_scrolled);
            content_box.add (main_actionbar);
            content_box.show_all ();
            add (content_box);
            uint remove_time = 0;
            size_allocate.connect (()=> {
                if (remove_time != 0) {
                    Source.remove (remove_time);
                }
                remove_time = GLib.Timeout.add (500, () => {
                    size_flexible ();
                    remove_time = 0;
                    return Source.REMOVE;
                });
            });
            NikiApp.settings.changed["edit-playlist"].connect (playlist_edit);
            playlist_edit ();
            notify["child-revealed"].connect (() => {
                if (!child_revealed) {
                    hovered = child_revealed;
                }
                size_flexible ();
            });
            playlist.enter_notify_event.connect (() => {
                return cursor_hand_mode(0);
            });

            playlist.motion_notify_event.connect (() => {
                size_flexible ();
                return cursor_hand_mode(0);
            });

            playlist.leave_notify_event.connect (() => {
                return cursor_hand_mode(2);
            });
        }

        private void playlist_edit () {
            header_label.label = !NikiApp.settings.get_boolean ("edit-playlist")? StringPot.Playlist : StringPot.Select_Remove;
            ((Gtk.Image) edit_button.image).icon_name = NikiApp.settings.get_boolean ("edit-playlist")? "go-previous-symbolic" : "list-remove-symbolic";
            edit_button.tooltip_text = NikiApp.settings.get_boolean ("edit-playlist")? StringPot.Back_Playlist : StringPot.Remove_Playlists;
        }

        private void size_flexible (){
            playlist_scrolled.set_min_content_width (90 + ((int)(NikiApp.settings.get_int ("window-width") * 0.15)));
        }

        public void reveal_control (bool button = true) {
            if (button) {
                set_reveal_child (!child_revealed? true : false);
            }
            content_box.margin = 4;
            margin_top = (int)player_page.top_actor.height;
            margin_bottom = (int)player_page.bottom_actor.height;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }

            hiding_timer = GLib.Timeout.add_seconds (3, () => {
                if (hovered || playlist.menu.visible) {
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
