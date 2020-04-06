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
    public class KeyboardPage : Object {
        public bool match_keycode (uint keyval, uint code) {
            Gdk.KeymapKey [] keys;
            Gdk.Keymap keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
            if (keymap.get_entries_for_keyval (keyval, out keys)) {
                foreach (var key in keys) {
                    if (code == key.keycode) {
                        return true;
                    }
                }
            }
            return false;
        }

        public bool key_press (Gdk.EventKey e, Window window) {
            uint keycode = e.hardware_keycode;
            bool ctrl_pressed = (e.state & Gdk.ModifierType.CONTROL_MASK) != 0;
            bool shift_pressed = Gdk.ModifierType.SHIFT_MASK in e.state;
            if (match_keycode (Gdk.Key.space, keycode) && window.main_stack.visible_child_name == "player" && !NikiApp.settings.get_boolean ("make-lrc")) {
                window.player_page.playback.playing = !window.player_page.playback.playing;
                window.player_page.string_notify (window.player_page.playback.playing? StringPot.Play : StringPot.Pause);
            } else if (match_keycode (Gdk.Key.f, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                if (NikiApp.settings.get_boolean ("fullscreen")) {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }
            } else if (ctrl_pressed && match_keycode (Gdk.Key.o, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                window.run_open_file ();
            } else if (match_keycode (Gdk.Key.q, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                destroy_mode ();
            } else if (match_keycode (Gdk.Key.m, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                NikiApp.settings.set_boolean ("status-muted", !NikiApp.settings.get_boolean ("status-muted"));
                window.player_page.string_notify (NikiApp.settings.get_boolean ("status-muted")? StringPot.Muted : double_to_percent (NikiApp.settings.get_double ("volume-adjust")));
            } else if (match_keycode (Gdk.Key.n, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                if (NikiApp.settings.get_boolean("next-status")) {
                    window.player_page.next ();
                    GLib.Timeout.add (250, () => {
                        window.player_page.string_notify (StringPot.Next);
                        return Source.REMOVE;
                    });
                }
            } else if (match_keycode (Gdk.Key.b, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                if (NikiApp.settings.get_boolean ("previous-status")) {
                    window.player_page.previous ();
                    GLib.Timeout.add (250, () => {
                        window.player_page.string_notify (StringPot.Previous);
                        return Source.REMOVE;
                    });
                }
            } else if (match_keycode (Gdk.Key.p, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                window.player_page.right_bar.reveal_control ();
            } else if (match_keycode (Gdk.Key.l, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                NikiApp.settings.set_boolean ("lyric-button", !NikiApp.settings.get_boolean ("lyric-button"));
            } else if (match_keycode (Gdk.Key.i, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                NikiApp.settings.set_boolean ("information-button", !NikiApp.settings.get_boolean ("information-button"));
            } else if (match_keycode (Gdk.Key.s, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                NikiApp.settings.set_boolean ("settings-button", !NikiApp.settings.get_boolean ("settings-button"));
            } else if (match_keycode (Gdk.Key.r, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
                repeatmode.switch_repeat_mode ();
            } else if (match_keycode (Gdk.Key.h, keycode) && !NikiApp.settings.get_boolean ("make-lrc")) {
		        if (window.main_stack.visible_child_name == "player") {
                    window.player_page.top_bar.button_home ();
                } else if (window.welcome_page.stack.visible_child_name == "dlna" && window.main_stack.visible_child_name != "player") {
                    window.welcome_page.stack.visible_child_name = "home";
                } else if (window.main_stack.visible_child_name == "camera") {
                    window.main_stack.visible_child_name = "welcome";
		            window.camera_page.cameraplayer.set_null ();
                }
            }

            switch (e.keyval) {
                case Gdk.Key.Escape:
                    if (!NikiApp.settings.get_boolean ("fullscreen")) {
                        NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                    } else {
                        destroy_mode ();
                    }
                    break;
                case Gdk.Key.Down:
                    if (!window.player_page.right_bar.hovered && !NikiApp.settings.get_boolean ("settings-button") && !NikiApp.settings.get_boolean ("make-lrc")) {
                        window.player_page.seek_jump_seconds (shift_pressed? -60 : -30);
                    }
                    break;
                case Gdk.Key.Left:
                    if (!NikiApp.settings.get_boolean ("make-lrc")) {
                        window.player_page.seek_jump_seconds (shift_pressed? -10 : -5);
                    }
                    break;
                case Gdk.Key.Right:
                    if (!NikiApp.settings.get_boolean ("make-lrc")) {
                        window.player_page.seek_jump_seconds (shift_pressed? 10 : 5);
                    }
                    break;
                case Gdk.Key.Up:
                    if (!window.player_page.right_bar.hovered && !NikiApp.settings.get_boolean ("settings-button") && !NikiApp.settings.get_boolean ("make-lrc")) {
                        window.player_page.seek_jump_seconds (shift_pressed? 60 : 30);
                    }
                    break;
                case Gdk.Key.Page_Down:
                    window.player_page.seek_volume (-0.049999999990000000);
                    break;
                case Gdk.Key.Page_Up:
                    window.player_page.seek_volume (0.050000000111111111);
                    break;
            }
            return false;
        }
    }
}
