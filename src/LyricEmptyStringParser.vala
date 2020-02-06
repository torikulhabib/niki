namespace niki {
    public class LyricEmptyStringParser : LyricChain {
        public override bool can_parse (string item) {
            return item == "";
        }

        public override void process (Lyric lyric, string ln) {
            return;
        }
    }
}
