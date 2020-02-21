namespace niki {
    public class AudioMix : Gst.Bin {
        private dynamic Gst.Element audiosink;
        private dynamic Gst.Element audioqueue;
        private dynamic Gst.Element audiotee;
        private dynamic Gst.Element capsfilter;
        private dynamic Gst.Element equalizer;
        private dynamic Gst.Element audioamplify;
        private const string [] AUDIORENDER = {"autoaudiosink", "alsasink", "pulsesink"};

        construct {
            audiotee = Gst.ElementFactory.make("tee", "tee");
            audioqueue = Gst.ElementFactory.make("queue", "queue");
            capsfilter = Gst.ElementFactory.make("capsfilter", "capsfilter");
            Gst.Util.set_object_arg ((GLib.Object) capsfilter, "caps", "audio/x-raw, format={ S16LE, F32LE, F64LE }");
            equalizer = Gst.ElementFactory.make("equalizer-10bands", "equalizer-10bands");
            double [] freqs = {30, 60, 119, 238, 475, 947, 1890, 3771, 7524, 15012};
            double last_freq = -30;
            uint index = 0;
            foreach (double freq in freqs) {
                GLib.Object? band = ((Gst.ChildProxy) equalizer).get_child_by_index (index);
                band["freq"] = freq;
                double bandwidth = freq - last_freq;
                last_freq = freq;
                band["bandwidth"] = bandwidth;
                index++;
            }
            audioamplify = Gst.ElementFactory.make("audioamplify", "audioamplify");
            audioamplify["amplification"] = 1.15;
            audiosink = Gst.ElementFactory.make(AUDIORENDER [NikiApp.settings.get_int ("audiorender-options")], AUDIORENDER [NikiApp.settings.get_int ("audiorender-options")]);
            add_many (audioqueue, audiotee, capsfilter, equalizer, audioamplify, audiosink);
            add_pad (new Gst.GhostPad ("sink", audiotee.get_static_pad ("sink")));
            audioqueue.link_many(capsfilter, equalizer, audioamplify, audiosink);
            Gst.Pad sinkpad = audioqueue.get_static_pad ("sink");
            Gst.Pad pad = audiotee.get_request_pad ("src_%u");
            pad.link(sinkpad);
            audiotee["alloc-pad"] = pad;
        }
        public void setgain (int index, double gain) {
            GLib.Object? band = ((Gst.ChildProxy)equalizer).get_child_by_index (index);
            if (gain < 0) {
                gain *= 0.28f;
            } else {
                gain *= 0.14f;
            }
            band["gain"] = gain;
        }
        public Gee.Collection<EqualizerPreset> get_presets () {
            var presets_data = new Gee.TreeSet<string> ();
            if (NikiApp.settingsEq.get_strv ("custom-presets") != null) {
                foreach (string preset in NikiApp.settingsEq.get_strv ("custom-presets")) {
                    presets_data.add (preset);
                }
            }
            var equalizer_preset = new Gee.TreeSet<EqualizerPreset>();
            foreach (var preset_str in presets_data) {
                equalizer_preset.add (new EqualizerPreset.from_string (preset_str));
            }
            return equalizer_preset;
        }

        private static Gee.TreeSet<EqualizerPreset>? default_presets = null;
        public static Gee.Collection<EqualizerPreset> get_default_presets () {
            if (default_presets != null) {
                return default_presets;
            }

            default_presets = new Gee.TreeSet<EqualizerPreset> ();
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Flat, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Classical, {0, 0, 0, 0, 0, 0, -40, -40, -40, -50}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Club, {0, 0, 20, 30, 30, 30, 20, 0, 0, 0}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Dance, {50, 35, 10, 0, 0, -30, -40, -40, 0, 0}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Full_Bass, {55, 55, 55, 30, 0, -25, -50, -50, -50, -50}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Full_Treble, {-50, -50, -50, -30, -5, 5, 25, 45, 55, 55}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Bass_Treble, {70, 70, 0, -40, -25, 20, 45, 55, 60, 60}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Headphones, {0, 45, -35, -35, -55, -35, -40, -40, 0, 0}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Large_Hall, {50, 50, 30, 30, 0, -25, -25, -25, 0, 0}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Live, {-25, 0, 20, 25, 30, 30, 20, 15, 15, 10}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Party, {35, 35, 0, 0, 0, 0, 0, 0, 35, 35}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Pop, {-10, 25, 35, 40, 25, -5, -15, -15, -10, -10}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Reggae, {0, 0, -5, -30, 0, -35, -35, 0, 0, 0}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Rock, {40, 25, -30, -40, -20, 20, 45, 55, 55, 55}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Soft, {25, 10, -5, -15, -5, 20, 45, 50, 55, 60}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Ska, {-15, -25, -25, -5, 20, 30, 45, 50, 55, 50}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Soft_Rock, {20, 20, 10, -5, -25, -30, -20, -5, 15, 45}));
            default_presets.add (new EqualizerPreset.with_gains (StringPot.Techno, {40, 30, 0, -30, -25, 0, 40, 50, 50, 45}));

            return default_presets;
        }
    }
}
