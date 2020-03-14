namespace niki {
    public class LyricContentParser : LyricChain {
        private LyricFormatter lyric_formatter;

        construct {
            lyric_formatter = new LyricFormatter ();
        }

        public override bool can_parse (string item) {
            return lyric_formatter.is_simplified_lrc (item) || lyric_formatter.is_lrc (item);
        }

        public override void process (Gtk.ListStore lrc_store, string ln) {
            var lns = lyric_formatter.split (ln);
            if (lns[1] == null) {
                return;
            }
            var text = lyric_formatter.remove_word_timing (lns[1]);
            if (text.length > 0) {
                Gtk.TreeIter iter;
                lrc_store.append (out iter);
                lrc_store.set (iter, 0, time_to_int (lns[0]), 1, text, 2, "", 3, "");
            }
        }

        private int64 time_to_int (string time) {
            int minutes = int.parse (time [1:3]);
            int seconds = int.parse (time [4:6]);
            int milli = !(lyric_formatter.is_simplified_lrc (time)) ? int.parse (time [7:9]) : 0;
            return (minutes*60*1000 + seconds*1000 + milli)*1000;
        }
    }
}
