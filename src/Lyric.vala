namespace Niki {
    public class Lyric : Gee.TreeMap<int64?, string> {
        private Gee.BidirMapIterator<int64?, string> lrc_iterator;
        private int offset = 0;

        public void add_metadata (string _tag, string _info) {
            if (_tag == "offset") {
                offset = int.parse (_info);
            }
        }

        public void add_line (int64 time, string text) {
            set (time + offset, text);
        }

        private Gee.BidirMapIterator<int64?, string> iterator_get () {
            if (lrc_iterator == null || !lrc_iterator.valid) {
                lrc_iterator = bidir_map_iterator ();
                lrc_iterator.first ();
            }
            return lrc_iterator;
        }

        public int64 get_lyric_timestamp (int64 time_in_us, bool cur_pos) {
            return iterator_lyric (time_in_us, cur_pos).get_key ();
        }
        public bool is_map_valid () {
            return iterator_get ().valid;
        }
        public bool is_map_prev () {
            return iterator_get ().has_previous ();
        }

        private Gee.BidirMapIterator<int64?, string> iterator_lyric (int64 time_in_us, bool cur_pos) {
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
