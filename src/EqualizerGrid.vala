namespace niki {
    public class EqualizerGrid : Gtk.Grid {
        private PlayerPage? playerpage;
        private Gtk.Entry new_preset_entry;
        private Gtk.Grid side_list;
        private Gtk.Grid scale_container;
        public EqualizerPresetList? equalizerpresetlist;
        private Gee.ArrayList<Gtk.Label> label_values;
        private Gee.ArrayList<Gtk.Scale> scales;
        private Gee.ArrayList<int> target_levels;
        private string new_preset_name;
        private bool apply_changes = false;
        private bool adding_preset = false;
        private bool in_transition = false;
        private const string [] DECIBELS = { "32", "64", "125", "250", "500", "1k", "2k", "4k", "8k", "16k" };

        public EqualizerGrid (PlayerPage playerpage) {
            this.playerpage = playerpage;
            equalizerpresetlist = new EqualizerPresetList ();
            equalizerpresetlist.hexpand = true;
            scales = new Gee.ArrayList<Gtk.Scale> ();
            label_values = new Gee.ArrayList<Gtk.Label> ();
            target_levels = new Gee.ArrayList<int> ();
            NikiApp.settings.changed["settings-button"].connect (() => {
                if (!NikiApp.settings.get_boolean ("settings-button")) {
                    closed_save ();
                }
            });
        }

        public void init () {
            build_ui ();
            load_presets ();
            var preset = NikiApp.settingsEq.get_string ("selected-preset");
            if (preset != null) {
                equalizerpresetlist.select_preset (preset);
            }
            on_eq_switch ();
            apply_changes = true;
        }

        public void closed_save () {
            if (in_transition) {
                set_target_levels ();
            } else if (adding_preset) {
                add_new_preset ();
            }
            save_presets ();
            save_close ();
        }
        private void save_close () {
            var selected_preset = equalizerpresetlist.get_selected_preset ();
            NikiApp.settingsEq.set_string ("selected-preset", selected_preset != null ? selected_preset.name : "");
        }
        public bool verify_preset_name (string preset_name) {
            if (preset_name == null) {
                return false;
            }

            foreach (var preset in equalizerpresetlist.get_presets ()) {
                if (preset_name == preset.name) {
                    return false;
                }
            }
            return true;
        }

        private void build_ui () {
            height_request = 200;
            scale_container = new Gtk.Grid ();
            scale_container.hexpand = true;
            scale_container.column_spacing = 10;
            scale_container.margin_top = 2;
            scale_container.margin_bottom = 2;

            foreach (string decibel in DECIBELS) {
                var scale = new Gtk.Scale.with_range (Gtk.Orientation.VERTICAL, -85, 85, 0.1);
                scale.get_style_context ().add_class ("volume");
                scale.add_mark (0, Gtk.PositionType.LEFT, null);
                scale.draw_value = false;
                scale.inverted = true;
                scale.vexpand = true;
                scale.enter_notify_event.connect (() => {
                    cursor_hand_mode (3);
                    return false;
                });
                scale.leave_notify_event.connect (() => {
                    cursor_hand_mode (2);
                    return false;
                });
                scale.motion_notify_event.connect (() => {
                    cursor_hand_mode (3);
                    return false;
                });
                var label_value = new Gtk.Label (null);
                label_value.get_style_context ().add_class ("selectedlabel");
                var label = new Gtk.Label (decibel);
                label.get_style_context ().add_class ("selectedlabel");
                var holder = new Gtk.Grid ();
                holder.orientation = Gtk.Orientation.VERTICAL;
                holder.row_spacing = 6;
                holder.add (label);
                holder.add (scale);
                holder.add (label_value);
                scale_container.add (holder);
                scales.add (scale);
                label_values.add (label_value);
                scale.value_changed.connect (() => {
                    if (apply_changes) {
                        int index = scales.index_of (scale);
                        int val = (int) scale.get_value ();
                        label_value.label = val.to_string ();
                        playerpage.playback.audiomix.setgain (index, val);
                        if (!in_transition) {
                            var selected_preset = equalizerpresetlist.get_selected_preset ();
                            if (selected_preset.is_default) {
                                on_default_preset_modified ();
                            } else {
                                selected_preset.set_gain (index, val);
                            }
                        }
                    }
                });
            }

            side_list = new Gtk.Grid ();
            side_list.add (equalizerpresetlist);

            new_preset_entry = new Gtk.Entry ();
            new_preset_entry.hexpand = true;
            new_preset_entry.secondary_icon_name = "document-save-symbolic";
            new_preset_entry.secondary_icon_tooltip_text = _("Save Preset");

            var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.BOTH);
            size_group.add_widget (equalizerpresetlist);
            size_group.add_widget (new_preset_entry);

            var layout = new Gtk.Grid ();
            layout.orientation = Gtk.Orientation.VERTICAL;
            layout.row_spacing = 0;
            layout.margin_bottom = 2;
            layout.add (scale_container);
            layout.add (side_list);
            layout.show_all ();
            add (layout);
            show_all ();

            NikiApp.settingsEq.bind ("equalizer-enabled", scale_container, "sensitive", GLib.SettingsBindFlags.GET);
            NikiApp.settingsEq.changed["equalizer-enabled"].connect (on_eq_switch);

            equalizerpresetlist.delete_preset_chosen.connect (remove_preset_clicked);
            equalizerpresetlist.preset_selected.connect (preset_selected);
            new_preset_entry.activate.connect (add_new_preset);
            new_preset_entry.icon_press.connect (new_preset_entry_icon_pressed);
            new_preset_entry.focus_out_event.connect (on_entry_focus_out);
        }

        private bool on_entry_focus_out () {
            new_preset_entry.grab_focus ();
            return false;
        }

        private void on_eq_switch () {
            in_transition = false;
            if (NikiApp.settingsEq.get_boolean ("equalizer-enabled")) {
                var selected_preset = equalizerpresetlist.get_selected_preset ();
                if (selected_preset != null) {
                    for (int i = 0; i < scales.size; ++i) {
                        playerpage.playback.audiomix.setgain (i, selected_preset.get_gain (i));
                    }
                }
            } else {
                for (int i = 0; i < scales.size; ++i) {
                    playerpage.playback.audiomix.setgain (i, 0);
                }
            }
            notify_current_preset ();
        }

        private void load_presets () {
            foreach (var preset in AudioMix.get_default_presets ()) {
                preset.is_default = true;
                equalizerpresetlist.add_preset (preset);
            }

            foreach (var preset in playerpage.playback.audiomix.get_presets ()) {
                equalizerpresetlist.add_preset (preset);
            }
        }

        private void save_presets () {
            var val = new string[0];
            foreach (var preset in equalizerpresetlist.get_presets ()) {
                if (!preset.is_default) {
                    val += preset.to_string ();
                }
            }
            NikiApp.settingsEq.set_strv ("custom-presets", val);
        }

        private void preset_selected (EqualizerPreset p) {
            scale_container.sensitive = true;
            target_levels.clear ();

            foreach (int i in p.gains) {
                target_levels.add (i);
            }

            if ((!apply_changes) || adding_preset) {
                set_target_levels ();
            } else if (!in_transition) {
                in_transition = true;
                Timeout.add (20, transition_scales);
            }
        }

        private void set_target_levels () {
            in_transition = false;
            for (int index = 0; index < scales.size; ++index) {
                var scale = scales.get (index);
                scale.set_value (target_levels.get (index));
                var label_value = label_values.get (index);
                label_value.label = ((int)target_levels.get (index)).to_string ();
            }
        }

        private bool transition_scales () {
            if (!in_transition) {
                return false;
            }
            bool is_finished = true;
            for (int index = 0; index < scales.size; ++index) {
                var scale = scales.get (index);
                var label_value = label_values.get (index);
                double current_level = scale.get_value ();
                double target_level = target_levels.get (index);
                double difference = target_level - current_level;
                if (Math.fabs (difference) <= 1) {
                    scale.set_value (target_level);
                    label_value.label = ((int)target_level).to_string ();
                    notify_current_preset ();
                    if (target_level == 0) {
                        playerpage.playback.audiomix.setgain (index, 0);
                    }
                } else {
                    scale.set_value (scale.get_value () + (difference / 0.8));
                    label_value.label = ((int)(scale.get_value () + (difference / 0.8))).to_string ();
                    is_finished = false;
                }
            }
            if (is_finished) {
                in_transition = false;
                return false;
            }
            return true;
        }

        private void notify_current_preset () {
            if (NikiApp.settingsEq.get_boolean ("equalizer-enabled")) {
                NikiApp.settings.set_string ("tooltip-equalizer", equalizerpresetlist.get_selected_preset ().name);
            } else {
                NikiApp.settings.set_string ("tooltip-equalizer", _("Off"));
            }
            playerpage.string_notify (NikiApp.settings.get_string ("tooltip-equalizer"));
            save_close ();
        }

        private void on_default_preset_modified () {
            if (adding_preset) {
                return;
            }
            adding_preset = true;
            side_list.remove (equalizerpresetlist);
            side_list.add (new_preset_entry);
            side_list.show_all ();
            new_preset_name = create_new_preset_name (true);
            new_preset_entry.set_text (new_preset_name);
            new_preset_entry.grab_focus ();
        }

        private void new_preset_entry_icon_pressed (Gtk.EntryIconPosition pos, Gdk.Event event) {
            if (pos != Gtk.EntryIconPosition.SECONDARY && !adding_preset) {
                return;
            }
            add_new_preset ();
            notify_current_preset ();
        }

        private void add_new_preset () {
            if (!adding_preset) {
                return;
            }
            var new_name = new_preset_entry.get_text ();
            if (verify_preset_name (new_name)){
                new_preset_name = new_name;
            }

            int[] gains = new int[scales.size];

            for (int i = 0; i < scales.size; i++){
                gains[i] = (int) scales.get (i).get_value ();
            }

            var new_preset = new EqualizerPreset.with_gains (new_preset_name, gains);
            equalizerpresetlist.add_preset (new_preset);
            side_list.add (equalizerpresetlist);
            side_list.set_focus_child (equalizerpresetlist);
            side_list.remove (new_preset_entry);
            side_list.show_all ();
            adding_preset = false;
        }

        private string create_new_preset_name (bool from_current) {
            string current_preset_name = from_current ? equalizerpresetlist.get_selected_preset ().name : "";
            string preset_name = "";
            bool is_valid = false;
            int i = 0;

            do {
                if (from_current) {
                    if (i < 1) {
                        preset_name = _("%s (%s)").printf (current_preset_name, _("Custom"));
                    } else {
                        preset_name = _("%s (%s %i)").printf (current_preset_name, _("Custom"), i);
                    }
                } else {
                    if (i < 1) {
                        preset_name = _("Custom Preset");
                    } else {
                        preset_name = _("%s %i").printf (_("Custom Preset"), i);
                    }
                }
                i++;
                is_valid = verify_preset_name (preset_name);
            } while (!is_valid);
            return preset_name;
        }

        private void remove_preset_clicked () {
            equalizerpresetlist.remove_current_preset ();
        }
    }
}
