namespace niki {
    public class VideoPresetList : Gtk.ComboBox {
        public signal void preset_selected (VideoPreset p);
        public signal void delete_preset_chosen ();
        public VideoPreset? video_preset;
        private Gtk.ListStore store;
        private const string SEPARATOR_NAME = "<separator_item_unique_name>";
        private static string OFF_MODE = _("OFF");
        private static string DELETE_PRESET = _("Delete Current");
        private int ncustompresets {get; set;}
        private bool modifying_list;

        construct {
            get_style_context ().add_class ("combox");
            ncustompresets = 0;
            modifying_list = false;
            store = new Gtk.ListStore (ComboColumns.N_COLUMNS, typeof (GLib.Object), typeof (string), typeof (Icon));
            model = store;
            set_id_column (1);
            set_row_separator_func ((model, iter) => {
                string content = "";
                model.get (iter, 1, out content);
                return content == SEPARATOR_NAME;
            });
		    var cell = new Gtk.CellRendererText ();
		    cell.ellipsize = Pango.EllipsizeMode.END;
		    var cell_pb = new Gtk.CellRendererPixbuf ();
		    pack_start (cell_pb, false);
		    pack_start (cell, false);
		    set_attributes (cell_pb, "gicon", 2);
		    set_attributes (cell, "text", 1);
            changed.connect (selection_change);
            show_all ();
            store.clear ();

            Gtk.TreeIter iter;
            store.append (out iter);
            store.set (iter, ComboColumns.OBJECT, null, ComboColumns.STRING, OFF_MODE, ComboColumns.ICON, new ThemedIcon ("system-shutdown-symbolic"));
            add_separator ();
        }

        public void add_separator () {
            Gtk.TreeIter iter;
            store.append (out iter);
            store.set (iter, ComboColumns.OBJECT, null, ComboColumns.STRING, SEPARATOR_NAME, ComboColumns.ICON, null);
        }

        public void add_preset (VideoPreset ep) {
            modifying_list = true;
            if (!ep.is_default) {
                if (ncustompresets < 1) {
                    add_separator ();
                }
                ncustompresets++;
            }
            Gtk.TreeIter iter;
            store.append (out iter);
            if (verify_preset_name (ep.name)) {
                store.set (iter, ComboColumns.OBJECT, ep, ComboColumns.STRING, ep.name, ComboColumns.ICON, new ThemedIcon ("com.github.torikulhabib.niki.video-filter-on-symbolic"));
            } else {
                store.set (iter, ComboColumns.OBJECT, ep, ComboColumns.STRING, ep.name, ComboColumns.ICON, new ThemedIcon ("document-save-symbolic"));
            }
            modifying_list = false;
            set_active_iter (iter);
        }
        public bool verify_preset_name (string preset_name) {
            if (preset_name == null) {
                return false;
            }
            foreach (var preset in VideoMix.get_default_presets ()) {
                if (preset_name == preset.name) {
                    return false;
                }
            }
            return true;
        }
        public void remove_current_preset () {
            modifying_list = true;

            Gtk.TreeIter iter;
            for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                GLib.Object o;
                store.get (iter, ComboColumns.OBJECT, out o);

                if (o != null && o is VideoPreset && ((VideoPreset)o) == video_preset) {
                    if (!((VideoPreset)o).is_default) {
                        ncustompresets--;
                        store.remove (ref iter);
                        break;
                    }
                }
            }

            if (ncustompresets < 1) {
                remove_separator_item (-1);
            }
            modifying_list = false;
            select_delete_preset ();
        }
        public void keyboard_press () {
            Gtk.TreeIter iter;
            get_active_iter (out iter);
            model.iter_next (ref iter);
            if (store.iter_is_valid (iter)) {
                string option;
                store.get (iter, ComboColumns.STRING, out option);
                if (option == SEPARATOR_NAME) {
                    set_active (get_active () + 2);
                } else {
                    set_active_iter (iter);
                }
            } else {
                set_active (0);
            }
        }
        public void selection_change () {
            if (!NikiApp.settingsVf.get_boolean ("videofilter-enabled")) {
                NikiApp.settingsVf.set_boolean ("videofilter-enabled", true);
            }
            if (modifying_list) {
                return;
            }
            Gtk.TreeIter it;
            get_active_iter (out it);
            selected_iters (it);
        }
        private void selected_iters (Gtk.TreeIter it) {
            GLib.Object o;
            store.get (it, ComboColumns.OBJECT, out o);
            if (o != null && o is VideoPreset) {
                video_preset = o as VideoPreset;
                if (!((VideoPreset)o).is_default) {
                    add_delete_preset_option ();
                } else {
                    remove_delete_option ();
                }
                preset_selected (o as VideoPreset);
                return;
            }

            string option;
            store.get (it, ComboColumns.STRING, out option);
            if (option == OFF_MODE) {
                NikiApp.settingsVf.set_boolean ("videofilter-enabled", false);
                remove_delete_option ();
            } else if (option == DELETE_PRESET) {
                delete_preset_chosen ();
            }
        }

        public void select_delete_preset () {
            set_active (0);
        }

        public void select_preset (string? preset_name) {
            if (!(preset_name == null || preset_name.length < 1)) {
                Gtk.TreeIter iter;
                for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                    GLib.Object o;
                    store.get (iter, ComboColumns.OBJECT, out o);
                    if (o != null && o is VideoPreset && ((VideoPreset)o).name == preset_name) {
                        set_active_iter (iter);
                        preset_selected (o as VideoPreset);
                        return;
                    }
                }
            }
            select_delete_preset ();
        }

        public VideoPreset? get_selected_preset () {
            Gtk.TreeIter it;
            get_active_iter (out it);
            GLib.Object o;
            store.get (it, ComboColumns.OBJECT, out o);
            if (o != null && o is VideoPreset) {
                return o as VideoPreset;
            } else {
                return null;
            }
        }

        public Gee.Collection<VideoPreset> get_presets () {
            var rv = new Gee.LinkedList<VideoPreset> ();
            Gtk.TreeIter iter;
            for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                GLib.Object o;
                store.get (iter, ComboColumns.OBJECT, out o);

                if (o != null && o is VideoPreset) {
                    rv.add (o as VideoPreset);
                }
            }
            return rv;
        }

        private void remove_delete_option () {
            Gtk.TreeIter iter;
            for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                string text;
                store.get (iter, ComboColumns.STRING, out text);

                if (text != null && text == DELETE_PRESET) {
                    store.remove (ref iter);
                    remove_separator_item (1);
                }
            }
        }

        private void remove_separator_item (int index) {
            int count = 0, nitems = store.iter_n_children (null);
            Gtk.TreeIter iter;

            for (int i = nitems - 1; store.get_iter_from_string (out iter, i.to_string ()); --i) {
                count++;
                string text;
                store.get (iter, ComboColumns.STRING, out text);

                if ((nitems - index == count || index == -1) && text != null && text == SEPARATOR_NAME) {
                    store.remove (ref iter);
                    break;
                }
            }
        }

        private void add_delete_preset_option () {
            bool already_added = false;
            Gtk.TreeIter last_iter, new_iter;

            for (int i = 0; store.get_iter_from_string (out last_iter, i.to_string ()); ++i) {
                string text;
                store.get (last_iter, ComboColumns.STRING, out text);

                if (text != null && text == SEPARATOR_NAME) {
                    new_iter = last_iter;

                    if (store.iter_next (ref new_iter)) {
                        store.get (new_iter, ComboColumns.STRING, out text);
                        already_added = (text == DELETE_PRESET);
                    }
                    break;
                }
            }

            if (already_added) {
                return;
            }
            store.insert_after (out new_iter, last_iter);
            store.set (new_iter, ComboColumns.OBJECT, null, ComboColumns.STRING, DELETE_PRESET, ComboColumns.ICON, new ThemedIcon ("edit-delete-symbolic"));
            last_iter = new_iter;
            store.insert_after (out new_iter, last_iter);
            store.set (new_iter, ComboColumns.OBJECT, null, ComboColumns.STRING, SEPARATOR_NAME, ComboColumns.ICON, null);
        }
    }
}
