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
    public class NikiApp : Gtk.Application {
        private static NikiApp _instance = null;
        public static NikiApp instance {
            get {
                if (_instance == null) {
                    _instance = new NikiApp ();
                }
                return _instance;
            }
        }
        public NikiApp () {
            Object(
                application_id: "com.github.torikulhabib.niki",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE
            );
            Unix.signal_add ( Posix.Signal.HUP, on_sigint, Priority.DEFAULT );
            Unix.signal_add ( Posix.Signal.TERM, on_sigint, Priority.DEFAULT );
        }
        public static Sqlite.Database db;
        public static Window? window;
        public static KeyboardInfo? keyboardinfo;
        public static GLib.Settings settings = new GLib.Settings ("com.github.torikulhabib.niki");
        public static GLib.Settings settingsEq = new GLib.Settings ("com.github.torikulhabib.equalizer");
        public static GLib.Settings settingsVf = new GLib.Settings ("com.github.torikulhabib.videofilter");
        public static GLib.Settings settingsCv = new GLib.Settings ("com.github.torikulhabib.videocamera");

        construct {
            startup.connect (on_startup);
            shutdown.connect (on_shutdown);
        }
        private bool on_sigint () {
            return Source.REMOVE;
        }

        private void on_startup () {
            Contractor.create_contract ();
        }
        private void on_shutdown () {
            window.player_page.initbitor.uninhibit ();
            Contractor.remove_contract ();
        }

        public void active () {
            if (window == null) {
                window = new Window ();
                add_window (window);
                window.show_all ();
                if (open_database (out db) != Sqlite.OK) {
                    notify_app (_("Database Error"),
                                _("Can't open database: %s\n").printf(db.errmsg ())
                    );
                }
            } else {
                if (NikiApp.settings.get_boolean ("audio-video") && window.main_stack.visible_child_name == "player") {
                    window.show ();
                    return_hide_mode = false;
                    if (NikiApp.settings.get_int ("window-x") != -1 && NikiApp.settings.get_int ("window-y") != -1) {
                        window.move (NikiApp.settings.get_int ("window-x"), NikiApp.settings.get_int ("window-y"));
                    }
                }
            }
        }
        public void keyboard_keys () {
            if (keyboardinfo == null) {
                keyboardinfo = new KeyboardInfo ();
                if (window != null) {
                    keyboardinfo.transient_for = window;
                }
                add_window (keyboardinfo);
                keyboardinfo.show_all ();
                keyboardinfo.destroy.connect (() => {
                    keyboardinfo = null;
                });
            }
        }
        [CCode (array_length = false, array_null_terminated = true)]
        private string []? arg_files = {};
        public override int command_line (ApplicationCommandLine command) {
            string [] args_cmd = command.get_arguments ();
            unowned string [] args = args_cmd;
            bool playlist = false;
            bool showkey = false;
            GLib.OptionEntry [] options = new OptionEntry [4];
            options [0] = { "playlist", 0, 0, OptionArg.NONE, ref playlist, "playlist", null };
            options [1] = { "showkey", 0, 0, OptionArg.NONE, ref showkey, "showkey", null };
            options [2] = { "", 0, 0, OptionArg.STRING_ARRAY, ref arg_files, null, null };
            options [3] = { null };
            var opt_context = new OptionContext (null);
            opt_context.add_main_entries (options, null);
            try {
                opt_context.parse (ref args);
            } catch (Error err) {
                warning (err.message);
            }

            File [] files = null;
            foreach (string arg_file in arg_files) {
                if (GLib.FileUtils.test (arg_file, GLib.FileTest.EXISTS)) {
                    files += (File.new_for_path (arg_file));
                }
            }
            if (playlist) {
                window.open_files (files, false, false);
                arg_files = {};
            } else if (showkey) {
                keyboard_keys ();
            } else {
                active ();
                if (files != null) {
                    window.open_files (files, true);
                    arg_files = {};
                } else {
                    window.position_window ();
                }
            }
            return 0;
        }
    }
}

public static int main (string []? args) {
    var app = new niki.NikiApp ().instance;
    ClutterGst.init (ref args);
    return app.run (args);
}
