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
    public class CircularGrid : Gtk.Grid {
        private CircularProgressBar circularprogressbar;
        private string [] audio_video = {};
        private uint content_count = 0;


        construct {
            circularprogressbar = new CircularProgressBar ();
            circularprogressbar.radius_filled = true;
            valign = Gtk.Align.CENTER;
            halign = Gtk.Align.CENTER;
            add (circularprogressbar);
        }
        public void circular_clear () {
            circularprogressbar.percentage = 0.0;
            circularprogressbar.count_file = 0;
            circularprogressbar.total_file = 0;
        }
        public void count_uri (Gtk.ListStore liststore) {
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
            circularprogressbar.total_file = n_child;
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

                        GLib.Timeout.add (content_av == 0? 15 : 215, () => {
                            circularprogressbar.percentage = count_pro / pers_to;
                            circularprogressbar.count_file = count;
                            string filename;
                            Gtk.TreeIter iter;
                            liststore.get_iter_from_string (out iter, (count - 1).to_string ());
                            if (liststore.iter_is_valid (iter)) {
                                liststore.get (iter, ColumnScanF.FILENAME, out filename);
                                if (filename != null) {
                                    NikiApp.window.player_page.right_bar.playlist.add_item (File.new_for_uri (filename));
                                }
                            }

                            count ++;
                            count_pro = count_pro + count_to;
                            if (count > n_child) {
                                if (NikiApp.window.main_stack.visible_child_name == "welcome") {
                                    if (NikiApp.window.welcome_page.index_but == 2) {
                                        NikiApp.window.main_stack.visible_child_name = "player";
                                        NikiApp.window.player_page.get_first ();
                                    } else {
                                        NikiApp.window.player_page.right_bar.playlist.play_first ();
                                    }
                                    NikiApp.window.welcome_page.index_but = 0;
                                }
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
