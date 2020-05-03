namespace niki {
    public class LyricMetadataParser : LyricChain {
        public override bool can_parse (string item) {
            return Regex.match_simple ("\\[\\D\\D", item);
        }

        public override void process (Gtk.ListStore lrc_store, string ln) {
            if (ln.has_prefix ("[") && ln.has_suffix ("]")) {
                var md = ln[1:-1];
                var tag = md.split (":", 2);
                Gtk.TreeIter iter;
                lrc_store.append (out iter);
                lrc_store.set (iter, 0, -1, 1, "-1", 2, tag[0], 3, tag[1]);
            } else {
                warning (@"$ln");
            }
        }
    }
}
