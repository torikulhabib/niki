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
            if (match_keycode (Gdk.Key.space, keycode) && window.main_stack.visible_child_name == "player") {
                window.player_page.playback.playing = !window.player_page.playback.playing;
                window.player_page.string_notify (window.player_page.playback.playing? StringPot.Play : StringPot.Pause);
            } else if (match_keycode (Gdk.Key.f, keycode)) {
                if (NikiApp.settings.get_boolean ("fullscreen")) {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }
            } else if (ctrl_pressed && match_keycode (Gdk.Key.o, keycode)) {
                window.run_open_file ();
            } else if (match_keycode (Gdk.Key.q, keycode)) {
                destroy_mode ();
            } else if (match_keycode (Gdk.Key.m, keycode)) {
                NikiApp.settings.set_boolean ("status-muted", !NikiApp.settings.get_boolean ("status-muted"));
                window.player_page.string_notify (NikiApp.settings.get_boolean ("status-muted")? StringPot.Muted : double_to_percent (NikiApp.settings.get_double ("volume-adjust")));
            } else if (match_keycode (Gdk.Key.n, keycode)) {
                if (NikiApp.settings.get_boolean("next-status")) {
                    window.player_page.next ();
                    GLib.Timeout.add (250, () => {
                        window.player_page.string_notify (StringPot.Next);
                        return Source.REMOVE;
                    });
                }
            } else if (match_keycode (Gdk.Key.b, keycode)) {
                if (NikiApp.settings.get_boolean ("previous-status")) {
                    window.player_page.previous ();
                    GLib.Timeout.add (250, () => {
                        window.player_page.string_notify (StringPot.Previous);
                        return Source.REMOVE;
                    });
                }
            } else if (match_keycode (Gdk.Key.p, keycode)) {
                window.player_page.right_bar.reveal_control ();
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
                    if (!window.player_page.right_bar.hovered && !NikiApp.settings.get_boolean ("settings-button")) {
                        window.player_page.seek_jump_seconds (shift_pressed? -60 : -30);
                    }
                    break;
                case Gdk.Key.Left:
                    window.player_page.seek_jump_seconds (shift_pressed? -10 : -5);
                    break;
                case Gdk.Key.Right:
                    window.player_page.seek_jump_seconds (shift_pressed? 10 : 5);
                    break;
                case Gdk.Key.Up:
                    if (!window.player_page.right_bar.hovered && !NikiApp.settings.get_boolean ("settings-button")) {
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
