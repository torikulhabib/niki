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
    public class RightBar : Gtk.Revealer {
        public Playlist? playlist;
        public Gtk.Revealer entry_rev;
        private PlayerPage? playerpage;
        private RepeatButton? repeat_button;
        public ButtonRevealer? font_button_rev;
        private Gtk.Label header_label;
        private Gtk.Button remove_button;
        private Gtk.ScrolledWindow playlist_scrolled;
        private Gtk.Box content_box;
        private SearchEntry entry;
        private DialogImport dialogimport;
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

        public RightBar (PlayerPage? playerpage) {
            this.playerpage = playerpage;
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
                if (((Gtk.Window) get_toplevel ()).is_active) {
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
            playlist = new Playlist ();
            var open_button = new Gtk.Button.from_icon_name ("applications-multimedia-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Open File")
            };
            open_button.get_style_context ().add_class ("button_action");
            open_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            open_button.clicked.connect (impor_file);

            remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            remove_button.get_style_context ().add_class ("button_action");
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            remove_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("edit-playlist", !NikiApp.settings.get_boolean ("edit-playlist"));
            });

            font_button_rev = new ButtonRevealer ("font-x-generic-symbolic") {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 100,
                reveal_child = NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("lyric-available")
            };
            font_button_rev.button.get_style_context ().add_class ("button_action");
            font_button_rev.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            font_button_rev.clicked.connect (() => {
                playerpage.bottom_bar.menu_popover.font_selection_btn.clicked ();
                font_button_rev.tooltip_text = NikiApp.settings.get_string ("font");
            });
            repeat_button = new RepeatButton ();
            repeat_button.get_style_context ().add_class ("button_action");
            repeat_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            var repeat_button_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 100
            };
            repeat_button_revealer.add (repeat_button);
            repeat_button_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            NikiApp.settings.changed["audio-video"].connect (() => {
                repeat_button_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
                font_button_rev.set_reveal_child (NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("lyric-available"));
            });

            NikiApp.settings.changed["lyric-available"].connect (() => {
                font_button_rev.set_reveal_child (NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("lyric-available"));
            });

            header_label = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END
            };
            header_label.get_style_context ().add_class ("selectedlabel");
            header_label.get_style_context ().add_class ("h3");
            header_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var focus_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.play-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Go to Play")
            };
            focus_button.get_style_context ().add_class ("button_action");
            focus_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var search_button = new Gtk.Button.from_icon_name ("system-search-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Search")
            };
            search_button.get_style_context ().add_class ("button_action");
            search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            entry = new SearchEntry (playlist);
            entry.get_style_context ().add_class ("entrycss");
            entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            entry_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
                transition_duration = 500
            };
            entry_rev.add (entry);
            search_button.clicked.connect ( () => {
                entry_rev.set_reveal_child (!entry_rev.child_revealed);
                entry.grab_focus_without_selecting ();
            });
            entry_rev.notify["child-revealed"].connect (() => {
                if (!entry_rev.child_revealed) {
                    entry.text = "";
                }
            });
            var header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true
            };
            header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            header.get_style_context ().add_class ("transbgborder");
            header.pack_start (focus_button, false, false, 0);
            header.set_center_widget (header_label);
            header.pack_end (search_button, false, false, 0);

            var box_action = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL
            };
            box_action.add (open_button);
            box_action.add (remove_button);

            playlist.get_style_context ().add_class ("scrollbar");
            playlist.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            playlist.set_search_entry (entry);

            playlist_scrolled = new Gtk.ScrolledWindow (null, null) {
                propagate_natural_height = true
            };
            playlist_scrolled.get_style_context ().add_class ("scrollbar");
            playlist_scrolled.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            playlist_scrolled.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            playlist_scrolled.add (playlist);
            focus_button.clicked.connect ( () => {
                playlist.scroll_to_cell (playlist.set_current (playerpage.playback.uri, playerpage), null, true, 0.5f, 0);
            });

            var main_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true
            };
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.pack_start (box_action, false, false, 0);
            main_actionbar.pack_end (font_button_rev, false, false, 0);
            main_actionbar.pack_end (repeat_button_revealer, false, false, 0);

            content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                height_request = 70
            };
            content_box.get_style_context ().add_class ("playlist");
            content_box.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            content_box.pack_start (header, false, false, 0);
            content_box.pack_start (entry_rev, false, false, 0);
            content_box.pack_start (playlist_scrolled, false, false, 0);
            content_box.pack_end (main_actionbar, false, false, 0);
            add (content_box);
            show_all ();

            playerpage.size_allocate.connect (size_flexible);
            playlist.item_added.connect (playlist_edit);
            NikiApp.settings.changed["edit-playlist"].connect (playlist_edit);
            NikiApp.settings.changed["title-playing"].connect (playlist_edit);
            NikiApp.settings.changed["artist-music"].connect (playlist_edit);
            NikiApp.settings.changed["album-music"].connect (playlist_edit);
            playerpage.playback.notify["idle"].connect (playlist_edit);
            playerpage.playback.notify["playing"].connect (playlist_edit);

            notify["child-revealed"].connect (() => {
                if (!child_revealed) {
                    hovered = child_revealed;
                    entry_rev.set_reveal_child (false);
                    entry.text = "";
                }
                size_flexible ();
            });
            playlist.enter_notify_event.connect (() => {
                return cursor_hand_mode (0);
            });

            playlist.motion_notify_event.connect (() => {
                size_flexible ();
                return cursor_hand_mode (0);
            });

            playlist.leave_notify_event.connect (() => {
                return cursor_hand_mode (2);
            });
            playlist_edit ();
        }

        public void impor_file () {
            if (dialogimport == null) {
                dialogimport = new DialogImport (playerpage);
                dialogimport.show_all ();
                dialogimport.show.connect (()=> {
                    NikiApp.window.player_page.right_bar.set_reveal_child (false);
                });
                dialogimport.destroy.connect (()=>{
                    dialogimport = null;
                });
            }
        }

        private void playlist_edit () {
            Idle.add (()=> {
                if (!NikiApp.settings.get_boolean ("edit-playlist")) {
                    ((Gtk.Image) remove_button.image).icon_name = "list-remove-symbolic";
                    remove_button.tooltip_text = _("Remove Playlists");
                    header_label.label = @"$(playerpage.update_current ()) " + _("Playlist");
                } else {
                    ((Gtk.Image) remove_button.image).icon_name = "go-previous-symbolic";
                    remove_button.tooltip_text = _("Back Playlist");
                    header_label.label = _("Select Remove");
                }
                return false;
            });
        }

        private void size_flexible () {
            int width;
            NikiApp.window.get_size (out width, null);
            playlist_scrolled.set_min_content_width ((int)(width * 0.25));
        }

        public void reveal_control (bool button = true) {
            if (button) {
                set_reveal_child (!child_revealed? true : false);
            }
            if (!NikiApp.settings.get_boolean ("make-lrc")) {
                content_box.margin = 4;
                margin_top = (int)playerpage.top_actor.height;
                margin_bottom = (int)playerpage.bottom_actor.height;
            }
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
