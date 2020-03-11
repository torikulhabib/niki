namespace niki {
    public abstract class LyricChain : Object {
        public LyricChain? lirycchainroot { get; set; }
        private LyricChain? lirycchain;

        public void add_parser_to_chain (LyricChain parser, LyricChain? lirycchainroot = null) {
            if (lirycchain == null) {
                lirycchain = parser;
                lirycchain.lirycchainroot = lirycchainroot ?? this;
                return;
            }
            lirycchain.add_parser_to_chain (parser);
        }

        public void parse (Gtk.ListStore lrc_store, string ln) {
            if (can_parse (ln)) {
                process (lrc_store, ln);
            } else if (lirycchain != null) {
                lirycchain.parse (lrc_store, ln);
            } else{
                warning (@"$ln\n");
            }
        }

        public abstract bool can_parse (string item);
        public abstract void process (Gtk.ListStore lrc_store, string ln);
    }
}
