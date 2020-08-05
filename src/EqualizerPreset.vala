namespace niki {
    public class EqualizerPreset : Object {
        public string name { get; construct set; }
        public Gee.ArrayList<int> gains = new Gee.ArrayList<int> ();
        public bool is_default { get; set; default = false; }

        public EqualizerPreset.basic (string name) {
            Object (name: name);
            for (int i = 0; i < 10; i++) {
                gains.add (0);
            }
        }

        public EqualizerPreset.with_gains (string name, int[] items) {
            Object (name: name);
            for (int i = 0; i < 10; i++) {
                gains.add (items[i]);
            }
        }

        public EqualizerPreset.from_string (string data) {
            var vals = data.split ("/", 0);
            Object (name: vals[0]);
            for (int i = 1; i < vals.length; i++) {
                gains.add (int.parse (vals[i]));
            }
        }

        public string to_string () {
            string str_preset = "";
            if (name != null && name != "") {
                str_preset = name;
                for (int i = 0; i < 10; i++) {
                    str_preset += "/" + get_gain (i).to_string ();
                }
            }
            return str_preset;
        }

        public void set_gain (int index, int val) {
            if (index > 9) {
                return;
            }
            gains[index] = val;
        }

        public int get_gain (int index) {
            return gains[index];
        }
    }
}
