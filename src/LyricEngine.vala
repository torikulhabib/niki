/*
* Copyright (c) {2021} torikulhabib (https://github.com/torikulhabib)
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
    public class LyricEngine : Object {
        private const string SIMPLIFIED_LYRIC_PATTERN = "(\\[\\d\\d:\\d\\d\\])";
        private const string MILI_LYRIC_PATTERN = "(\\[\\d\\d:\\d\\d\\.\\d\\d\\d\\])";
        private const string LYRIC_PATTERN = "(\\[\\d\\d:\\d\\d\\.\\d\\d\\])";
        private const string METADATA_PATTERN = "\\[\\D.*?";
        private Gtk.ListStore lrc_store;

        public LyricEngine () {
            lrc_store = new Gtk.ListStore (4, typeof (int64), typeof (string), typeof (string), typeof (string));
            ((Gtk.TreeSortable)lrc_store).set_sort_column_id (0, Gtk.SortType.ASCENDING);
        }

        public Lyric parse (File file) {
            var lyric = new Lyric ();
            try {
                DataInputStream dis = new DataInputStream (file.read ());
                dis.newline_type = DataStreamNewlineType.ANY;
                string ln;
                while ((ln = dis.read_line_utf8 ()) != null) {
                    pattern_check (ln.strip ());
                }
            } catch (Error e) {
                critical ("%s", e.message);
            }
            lrc_store.foreach ((model, path, iter) => {
                string lrc_str, tag1, tag2;
                int64 time_lrc;
                model.get (iter, 0, out time_lrc, 1, out lrc_str, 2, out tag1, 3, out tag2);
                if (tag1.char_count () > 0 && tag2.char_count () > 0) {
                    lyric.add_metadata (tag1, tag2);
                }
                if (time_lrc != -1 && lrc_str != "-1") {
                    lyric.add_line (time_lrc, lrc_str);
                }
                return false;
            });
            return lyric;
        }

        private void pattern_check (string new_line) {
            if (is_match (METADATA_PATTERN, new_line)) {
                get_meta (new_line, METADATA_PATTERN);
            } else if (is_match (SIMPLIFIED_LYRIC_PATTERN, new_line)) {
                get_lyric (new_line, SIMPLIFIED_LYRIC_PATTERN);
            } else if (is_match (MILI_LYRIC_PATTERN, new_line)) {
                get_lyric (new_line, MILI_LYRIC_PATTERN);
            } else if (is_match (LYRIC_PATTERN, new_line)) {
                get_lyric (new_line, LYRIC_PATTERN);
            }
        }

        private void get_meta (string new_line, string pattern) {
            if (!is_match (LYRIC_PATTERN, new_line) && !is_match (MILI_LYRIC_PATTERN, new_line) && !is_match (SIMPLIFIED_LYRIC_PATTERN, new_line)) {
                string metadata = new_line.replace ("[", "").replace ("]", "");
                int last_time = metadata.index_of (":");
                if (last_time > 0) {
                    string id_meta = metadata.slice (0, last_time);
                    string cont_name = metadata.slice (last_time + 1, metadata.length);
                    Gtk.TreeIter iter;
                    lrc_store.append (out iter);
                    lrc_store.set (iter, 0, -1, 1, "-1", 2, id_meta, 3, cont_name);
                }
            }
        }

        private void get_lyric (string new_line, string pattern) {
            string[] split_lyric = Regex.split_simple (pattern, new_line);
            int last_time = new_line.last_index_of ("]");
            string only_lyric = new_line.slice (last_time + 1, new_line.length);
            foreach (string time_lyric in split_lyric) {
                if (is_match (pattern, time_lyric) && only_lyric != "") {
                    Gtk.TreeIter iter;
                    lrc_store.append (out iter);
                    lrc_store.set (iter, 0, int_from_time (time_lyric), 1, only_lyric, 2, "", 3, "");
                }
            }
        }

        private bool is_match (string pattern, string new_line) {
            return Regex.match_simple (pattern, new_line);
        }
    }
}
