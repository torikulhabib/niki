namespace niki {
    public class LyricParser : Object {
        private LyricChain lirycchain;

        construct {
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
                    lirycchain.parse (lyric, ln.strip ());
                }
            } catch (Error e) {
                critical ("%s", e.message);
            }
            return lyric;
        }
    }
}
