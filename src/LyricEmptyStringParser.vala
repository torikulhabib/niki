namespace niki {
    public class LyricEmptyStringParser : LyricChain {
        public override bool can_parse (string item) {
            return item == "";
        }

        public override void process (Gtk.ListStore lrc_store, string ln) {
            return;
        }
    }
}
