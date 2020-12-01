namespace niki {
    public class VideoGrid : Gtk.Grid {
        private PlayerPage? playerpage;
        private Gtk.Entry new_preset_entry;
        private Gtk.Grid side_list;
        private Gtk.Grid scale_container;
        public VideoPresetList? videopresetlist;
        private Gee.ArrayList<Gtk.Scale> scales;
        private Gee.ArrayList<int> target_levels;
        private string new_preset_name;
        private bool apply_changes = false;
        private bool adding_preset = false;
        private bool in_transition = false;
        private const string [] CHROMA = {"Gamma", "Brightness", "Contrast", "Saturation", "Hue"};

        public VideoGrid (PlayerPage playerpage) {
            this.playerpage = playerpage;
            videopresetlist = new VideoPresetList ();
            videopresetlist.hexpand = true;
            scales = new Gee.ArrayList<Gtk.Scale> ();
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
            var preset = NikiApp.settingsVf.get_string ("selected-preset");
            if (preset != null) {
                videopresetlist.select_preset (preset);
            }
            video_switch ();
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
            var selected_preset = videopresetlist.get_selected_preset ();
            NikiApp.settingsVf.set_string ("selected-preset", selected_preset != null ? selected_preset.name : "");
        }

        public bool verify_preset_name (string preset_name) {
            if (preset_name == null) {
                return false;
            }

            foreach (var preset in videopresetlist.get_presets ()) {
                if (preset_name == preset.name) {
                    return false;
                }
            }
            return true;
        }

        private void build_ui () {
            height_request = 200;
            scale_container = new Gtk.Grid ();
            scale_container.orientation = Gtk.Orientation.VERTICAL;
            scale_container.vexpand = true;
            scale_container.margin_top = 2;
            scale_container.margin_bottom = 2;

            foreach (string croma in CHROMA) {
                var scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, -100, 100, 0.1);
                scale.get_style_context ().add_class ("volume");
                scale.add_mark (0, Gtk.PositionType.LEFT, null);
                scale.set_margin_start (2);
                scale.set_margin_end (2);
                scale.draw_value = false;
                scale.hexpand = true;
                var label_name = new Gtk.Label (croma);
                label_name.get_style_context ().add_class ("selectedlabel");
                bool in_scale = false;
                scale.tooltip_text = croma;
                scale.enter_notify_event.connect (() => {
                    in_scale = true;
                    cursor_hand_mode (0);
                    label_name.label = ((int)scale.get_value ()).to_string ();
                    return false;
                });
                scale.leave_notify_event.connect (() => {
                    in_scale = false;
                    cursor_hand_mode (2);
                    label_name.label = croma;
                    return false;
                });
                scale.motion_notify_event.connect (() => {
                    in_scale = true;
                    cursor_hand_mode (0);
                    return false;
                });
                if (croma == "Hue") {
                    scale.has_origin = false;
                }

                scale_container.add (label_name);
                scale_container.add (scale);
                scale_container.show_all ();
                scales.add (scale);
                scale.value_changed.connect (() => {
                    if (apply_changes) {
                        var index = scales.index_of (scale);
                        var val = ((int)scale.get_value ());
                        if (in_scale) {
                            label_name.label = ((int)scale.get_value ()).to_string ();
                        }
                        playerpage.playback.videomix.setvalue (index, val);
                        if (!in_transition) {
                            var selected_preset = videopresetlist.get_selected_preset ();
                            if (selected_preset.is_default) {
                                on_default_preset_modified ();
                            } else {
                                selected_preset.setvalue (index, val);
                            }
                        }
                    }
                });
            }

            side_list = new Gtk.Grid ();
            side_list.add (videopresetlist);

            new_preset_entry = new Gtk.Entry ();
            new_preset_entry.hexpand = true;
            new_preset_entry.secondary_icon_name = "document-save-symbolic";
            new_preset_entry.secondary_icon_tooltip_text = _("Save Preset");

            var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.BOTH);
            size_group.add_widget (videopresetlist);
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

            NikiApp.settingsVf.bind ("videofilter-enabled", scale_container, "sensitive", GLib.SettingsBindFlags.GET);
            NikiApp.settingsVf.changed["videofilter-enabled"].connect (video_switch);

            videopresetlist.delete_preset_chosen.connect (remove_preset_clicked);
            videopresetlist.preset_selected.connect (preset_selected);
            new_preset_entry.activate.connect (add_new_preset);
            new_preset_entry.icon_press.connect (new_preset_entry_icon_pressed);
            new_preset_entry.focus_out_event.connect (on_entry_focus_out);
        }

        private bool on_entry_focus_out () {
            new_preset_entry.grab_focus ();
            return false;
        }

        private void video_switch () {
            in_transition = false;
            if (NikiApp.settingsVf.get_boolean ("videofilter-enabled")) {
                var selected_preset = videopresetlist.get_selected_preset ();
                if (selected_preset != null) {
                    for (int i = 0; i < scales.size; ++i) {
                        playerpage.playback.videomix.setvalue (i, selected_preset.getvalue (i));
                    }
                }
            } else {
                for (int i = 0; i < scales.size; ++i) {
                    playerpage.playback.videomix.setvalue (i, 0);
                }
            }
            notify_current_preset ();
        }

        private void load_presets () {
            foreach (var preset in VideoMix.get_default_presets ()) {
                preset.is_default = true;
                videopresetlist.add_preset (preset);
            }

            foreach (var preset in playerpage.playback.videomix.get_presets ()) {
                videopresetlist.add_preset (preset);
            }
        }

        private void save_presets () {
            var val = new string[0];
            foreach (var preset in videopresetlist.get_presets ()) {
                if (!preset.is_default) {
                    val += preset.to_string ();
                }
            }
            NikiApp.settingsVf.set_strv ("custom-presets", val);
        }

        private void preset_selected (VideoPreset videoprest) {
            scale_container.sensitive = true;
            target_levels.clear ();

            foreach (int i in videoprest.gains) {
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
            }
        }

        private bool transition_scales () {
            if (!in_transition) {
                return false;
            }
            bool is_finished = true;
            for (int index = 0; index < scales.size; ++index) {
                var scale = scales.get (index);
                int current_level = (int) scale.get_value ();
                int target_level = target_levels.get (index);
                int difference = target_level - current_level;
                if (Math.fabs (difference) <= 1) {
                    scale.set_value (target_level);
                    notify_current_preset ();
                    if (target_level == 0) {
                        playerpage.playback.videomix.setvalue (index, 0);
                    }
                } else {
                    scale.set_value (scale.get_value () + (difference / 1.0));
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
            if (NikiApp.settingsVf.get_boolean ("videofilter-enabled")) {
                NikiApp.settings.set_string ("tooltip-videos", videopresetlist.get_selected_preset ().name);
            } else {
                NikiApp.settings.set_string ("tooltip-videos", _("Off"));
            }
            playerpage.string_notify (NikiApp.settings.get_string ("tooltip-videos"));
            save_close ();
        }

        private void on_default_preset_modified () {
            if (adding_preset) {
                return;
            }
            adding_preset = true;
            side_list.remove (videopresetlist);
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

            int[] gains = new int [scales.size];

            for (int i = 0; i < scales.size; i++){
                gains[i] = (int) scales.get (i).get_value ();
            }

            var new_preset = new VideoPreset.with_value (new_preset_name, gains);
            videopresetlist.add_preset (new_preset);
            side_list.add (videopresetlist);
            side_list.set_focus_child (videopresetlist);
            side_list.remove (new_preset_entry);
            side_list.show_all ();
            adding_preset = false;
        }

        private string create_new_preset_name (bool from_current) {
            string current_preset_name = from_current ? videopresetlist.get_selected_preset ().name : "";
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
            videopresetlist.remove_current_preset ();
        }
    }
}
