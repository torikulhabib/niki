namespace niki {
    public class CameraPreset : Object {
        public string name { get; construct set; }
        public Gee.ArrayList<int> gains = new Gee.ArrayList<int> ();

        public bool is_default { get; set; default = false; }

        public CameraPreset.basic (string name) {
            Object (name: name);
            for (int i = 0; i < 6; i++) {
                gains.add (0);
            }
        }

        public CameraPreset.with_value (string name, int[] items) {
            Object (name: name);
            for (int i = 0; i < 6; i++) {
                gains.add (items[i]);
            }
        }

        public CameraPreset.from_string (string data) {
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
                for (int i = 0; i < 6; i++) {
                    str_preset += "/" + getvalue (i).to_string ();
                }
            }
            return str_preset;
        }

        public void setvalue (int index, int val) {
            if (index > 5) {
                return;
            }
            gains[index] = val;
        }

        public int getvalue (int index) {
            return gains[index];
        }
    }
}
