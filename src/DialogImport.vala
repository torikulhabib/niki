/*
* Copyright (c) {2020} torikulhabib (https://github.com/torikulhabib)
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
    public class DialogImport : MessageDialog {
        private PlayerPage? playerpage;
        public Welcome? welcome_rigth;
        public Welcome? welcome_left;
        public ScanFolder? scanfolder;
        private string [] audio_video = {};
        private uint content_count = 0;
        private Gtk.ProgressBar progress_bar;
        public Gtk.ListStore liststore;
        private Gtk.Revealer progress_rev;

        public DialogImport (PlayerPage playerpage) {
            Object (
                text_image: "com.github.torikulhabib.niki",
                header: _("Import File"),
                primary_text: _("Select Media"),
                secondary_text: _("Select a source to playing."),
                selectable_text: false,
                deletable: false,
                resizable: false,
                border_width: 0,
                use_header_bar: 1,
                transient_for: (Gtk.Window) playerpage.get_toplevel (),
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
            this.playerpage = playerpage;
            liststore = new Gtk.ListStore (ColumnScanF.N_COLUMNS, typeof (string));
            scanfolder = new ScanFolder ();
            welcome_rigth = new Welcome () {
                focus_on_click = false
            };
            welcome_rigth.append ("applications-multimedia", _("Open File"), _("Open File"));
            welcome_rigth.append ("edit-paste", _("Paste URL"), _("Play Stream"));
            welcome_rigth.append ("document-open", _("Open Folder"), _("Open Folder"));

            welcome_left = new Welcome () {
                valign = Gtk.Align.START,
                focus_on_click = false
            };
            welcome_left.append ("folder-videos", _("Browse Library"), _("Movie Library"));
            welcome_left.append ("folder-music", _("Browse Library"), _("Music Library"));

            var grid_home = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL
            };
            grid_home.get_style_context ().add_class ("widget_background");
            grid_home.add (welcome_rigth);
            grid_home.add (welcome_left);

            progress_bar = new Gtk.ProgressBar () {
                hexpand = true
            };
            progress_bar.get_style_context ().add_class ("progress_bar");

            progress_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
                transition_duration = 100
            };
            progress_rev.add (progress_bar);

            var vertical_grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                valign = Gtk.Align.CENTER
            };
            vertical_grid.get_style_context ().add_class ("widget_background");
            vertical_grid.get_style_context ().add_class ("card");
            vertical_grid.add (grid_home);
            vertical_grid.add (progress_rev);
            vertical_grid.show_all ();

            custom_bin.add (vertical_grid);
            custom_bin.show_all ();

            scanfolder.signal_succes.connect ((store_uri)=>{
                count_uri (store_uri);
            });
            move_widget (this);
            welcome_rigth.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        remove_all ();
                        var files = run_open_file (this, true, 1);
                        if (files != null) {
                            foreach (var file in files) {
                                list_append (file.get_uri ());
                            }
                            count_uri (liststore);
                        }
                        break;
                    case 1:
                        Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD);
                        string text = clipboard.wait_for_text ().strip ();
                        if (text == null) {
                            return;
                        }
                        NikiApp.window.welcome_page.getlink.get_link_stream (text);
                        welcome_left.sensitive = false;
                        welcome_rigth.sensitive = false;
                        break;
                    case 2:
                        var file = run_open_folder (this);
                        if (file != null) {
                            scanfolder.remove_all ();
                            scanfolder.scanning (file.get_path (), 0);
                        }
                        break;
                }
            });
            welcome_left.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        scanfolder.remove_all ();
                        scanfolder.scanning (GLib.Environment.get_user_special_dir (UserDirectory.VIDEOS), 1);
                        break;
                    case 1:
                        scanfolder.remove_all ();
                        scanfolder.scanning (GLib.Environment.get_user_special_dir (UserDirectory.MUSIC), 2);
                        break;
                }
            });
            var close_dialog = new Gtk.Button.with_label (_("Close"));
            close_dialog.clicked.connect (() => {
                destroy ();
            });

            var box_action = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                margin_top = 5,
                margin_start = 10,
                margin_bottom = 10,
                margin_end = 10,
                hexpand = true,
                column_homogeneous = true
            };
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.add (close_dialog);
            get_content_area ().add (box_action);
        }
        private void list_append (string path) {
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, ColumnScanF.FILENAME, path);
        }
        public void remove_all () {
            if (liststore.iter_n_children (null) > 0) {
                liststore.clear ();
            }
        }
        public void count_uri (Gtk.ListStore liststore) {
            progress_bar.fraction = 0.0;
            int n_child = liststore.iter_n_children (null);
            double count_to = 0.0;
            int pers_to = 0;
            if (n_child <= 100) {
                count_to = 100 / (double) n_child;
                pers_to = 100;
            } else if (n_child > 100 && n_child <= 1000) {
                count_to = 1000 / (double) n_child;
                pers_to = 1000;
            } else if (n_child > 1000 && n_child <= 10000) {
                count_to = 10000 / (double) n_child;
                pers_to = 10000;
            } else if (n_child > 10000 && n_child <= 100000) {
                count_to = 100000 / (double) n_child;
                pers_to = 100000;
            }

            int count = 1;
            double count_pro = count_to;
            liststore.foreach ((model, path, lisiter) => {
                string filenames;
                model.get (lisiter, ColumnScanF.FILENAME, out filenames);
                    audio_video += filenames;
                    if (content_count != 0) {
                        Source.remove (content_count);
                    }
                    content_count = GLib.Timeout.add (50, () => {
                        int content_av = n_child;
                        foreach (string mime_content in audio_video) {
                            var paths = File.new_for_uri (mime_content);
                            if (get_mime_type (paths).has_prefix ("video/")) {
                                if (videos_file_exists (mime_content)) {
                                    if (content_av > 0) {
                                        content_av --;
                                    }
                                }
                            } else if (get_mime_type (paths).has_prefix ("audio/")) {
                                if (music_file_exists (mime_content)) {
                                    if (content_av > 0) {
                                        content_av --;
                                    }
                                }
                            }
                        }
                        progress_rev.set_reveal_child (true);
                        GLib.Timeout.add (content_av == 0? 15 : 215, () => {
                            progress_bar.fraction = count_pro / pers_to;
                            string filename;
                            Gtk.TreeIter iter;
                            liststore.get_iter_from_string (out iter, (count - 1).to_string ());
                            if (liststore.iter_is_valid (iter)) {
                                liststore.get (iter, ColumnScanF.FILENAME, out filename);
                                if (filename != null) {
                                    playerpage.right_bar.playlist.add_item (File.new_for_uri (filename));
                                }
                            }
                            count ++;
                            count_pro = count_pro + count_to;
                            if (count > n_child) {
                                progress_rev.set_reveal_child (false);
                                destroy ();
                                return false;
                            } else {
                                return true;
                            }
                        });
                        audio_video = {};
                        content_count = 0;
                        return false;
                    });
                return false;
            });
        }
    }
}
