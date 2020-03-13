namespace niki {
    public class Lyric : Gee.TreeMap<int64?, string> {
        public Gtk.ListStore meta_data;
        private Gee.BidirMapIterator<int64?, string> lrc_iterator;
        private int offset = 0;

        construct {
            meta_data = new Gtk.ListStore (2, typeof (string), typeof (string));
        }

        public void add_metadata (string _tag, string _info) {
            Gtk.TreeIter iter;
            meta_data.append (out iter);
            meta_data.set (iter, 0, _tag, 1, _info);
            if (_tag == "offset") {
                offset = int.parse (_info);
            }
        }

        public void add_line (int64 time, string text) {
            set (time, text);
        }

        private Gee.BidirMapIterator<int64?, string> iterator_get () {
            if (lrc_iterator == null || !lrc_iterator.valid) {
                lrc_iterator = bidir_map_iterator ();
                lrc_iterator.first ();
            }
            return lrc_iterator;
        }

        public int64 get_lyric_timestamp (int64 time_in_us, bool cur_pos = true) {
            var time_with_offset = time_in_us + offset;
            return iterator_lyric (time_with_offset, cur_pos).get_key ();
        }

        private Gee.BidirMapIterator<int64?, string> iterator_lyric (int64 time_in_us, bool cur_pos = true) {
            if (iterator_get ().get_key () > time_in_us) {
                iterator_get ().first ();
            }
            bool end_lrc = false;
            while (iterator_get ().get_key () < time_in_us && iterator_get ().has_next ()) {
                iterator_get ().next ();
                end_lrc = true;
            }
            if (cur_pos && end_lrc) {
                iterator_get ().previous ();
            }
            return iterator_get ();
        }
    }
}
