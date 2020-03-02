namespace niki {
    public class LyricParser : Object {
        private LyricChain lirycchain;
        private Gtk.ListStore lrc_store;

        construct {
            lrc_store = new Gtk.ListStore (4, typeof (int64), typeof (string), typeof (string), typeof (string));
            ((Gtk.TreeSortable)lrc_store).set_sort_column_id (0, Gtk.SortType.ASCENDING);
            lirycchain = new LyricEmptyStringParser ();
            lirycchain.add_parser_to_chain (new LyricMetadataParser ());
            lirycchain.add_parser_to_chain (new LyricCompressedParser ());
            lirycchain.add_parser_to_chain (new LyricContentParser ());
        }

        public Lyric parse (File file) {
            var lyric = new Lyric ();
            try {
                DataInputStream dis = new DataInputStream (file.read ());
                dis.newline_type = DataStreamNewlineType.ANY;
                string ln;
                while ((ln = dis.read_line_utf8 ()) != null) {
                    lirycchain.parse (lrc_store, ln.strip ());
                }
            } catch (Error e) {
                critical ("%s", e.message);
            }
            lrc_store.foreach ((model, path, iter) => {
                string lrc_str, tag1, tag2;
                int64 time_lrc;
                model.get (iter, 0, out time_lrc, 1, out lrc_str, 2, out tag1, 3, out tag2);
                if (time_lrc != -1 && lrc_str != "-1") {
                    lyric.add_line (time_lrc, lrc_str);
                }
                if (tag1.char_count () > 0 && tag2.char_count () > 0) {
                    lyric.add_metadata (tag1, tag2);
                }
                return false;
            });
            return lyric;
        }
    }
}
