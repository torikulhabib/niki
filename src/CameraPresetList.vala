namespace niki {
    public class CameraPresetList : Gtk.ComboBox {
        public signal void preset_selected (CameraPreset p);
        public signal void delete_preset_chosen ();
        public CameraPreset? camera_preset;
        private Gtk.ListStore store;
        private const string SEPARATOR_NAME = "<separator_item_unique_name>";
        private static string OFF_MODE = StringPot.OFF;
        private static string DELETE_PRESET = StringPot.Delete_Current;
        private int ncustompresets {get; set;}
        private bool modifying_list;

        construct {
            get_style_context ().add_class ("combox");
            ncustompresets = 0;
            modifying_list = false;
            store = new Gtk.ListStore (3, typeof (GLib.Object), typeof (string), typeof (Icon));
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
            changed.connect (list_selection_change);
            show_all ();
            store.clear ();

            Gtk.TreeIter iter;
            store.append (out iter);
            store.set (iter, 0, null, 1, OFF_MODE, 2, new ThemedIcon ("system-shutdown-symbolic"));
            add_separator ();
        }

        public void add_separator () {
            Gtk.TreeIter iter;
            store.append (out iter);
            store.set (iter, 0, null, 1, SEPARATOR_NAME, 2, null);
        }

        public void add_preset (CameraPreset ep) {
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
                store.set (iter, 0, ep, 1, ep.name, 2,  new ThemedIcon ("com.github.torikulhabib.niki.video-filter-on-symbolic"));
            } else {
                store.set (iter, 0, ep, 1, ep.name, 2,  new ThemedIcon ("document-save-symbolic"));
            }
            modifying_list = false;
            set_active_iter (iter);
        }
        public bool verify_preset_name (string preset_name) {
            if (preset_name == null) {
                return false;
            }
            foreach (var preset in CameraPlayer.get_default_presets ()) {
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
                store.get (iter, 0, out o);

                if (o != null && o is CameraPreset && ((CameraPreset)o) == camera_preset) {
                    if (!((CameraPreset)o).is_default) {
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

        public virtual void list_selection_change () {
            if (!NikiApp.settingsCv.get_boolean ("videocamera-enabled")) {
                NikiApp.settingsCv.set_boolean ("videocamera-enabled", true);
            }
            if (modifying_list) {
                return;
            }

            Gtk.TreeIter it;
            get_active_iter (out it);

            GLib.Object o;
            store.get (it, 0, out o);
            if (o != null && o is CameraPreset) {
                camera_preset = o as CameraPreset;
                if (!(o as CameraPreset).is_default) {
                    add_delete_preset_option ();
                } else {
                    remove_delete_option ();
                }
                preset_selected (o as CameraPreset);
                return;
            }

            string option;
            store.get (it, 1, out option);

            if (option == OFF_MODE) {
                NikiApp.settingsCv.set_boolean ("videocamera-enabled", false);
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
                    store.get (iter, 0, out o);
                    if (o != null && o is CameraPreset && (o as CameraPreset).name == preset_name) {
                        set_active_iter (iter);
                        preset_selected (o as CameraPreset);
                        return;
                    }
                }
            }
            select_delete_preset ();
        }

        public CameraPreset? get_selected_preset () {
            Gtk.TreeIter it;
            get_active_iter (out it);

            GLib.Object o;
            store.get (it, 0, out o);

            if (o != null && o is CameraPreset) {
                return o as CameraPreset;
            } else {
                return null;
            }
        }

        public Gee.Collection<CameraPreset> get_presets () {
            var rv = new Gee.LinkedList<CameraPreset> ();
            Gtk.TreeIter iter;
            for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                GLib.Object o;
                store.get (iter, 0, out o);

                if (o != null && o is CameraPreset) {
                    rv.add (o as CameraPreset);
                }
            }
            return rv;
        }

        private void remove_delete_option () {
            Gtk.TreeIter iter;
            for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                string text;
                store.get (iter, 1, out text);

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
                store.get (iter, 1, out text);

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
                store.get (last_iter, 1, out text);

                if (text != null && text == SEPARATOR_NAME) {
                    new_iter = last_iter;

                    if (store.iter_next (ref new_iter)) {
                        store.get (new_iter, 1, out text);
                        already_added = (text == DELETE_PRESET);
                    }
                    break;
                }
            }

            if (already_added) {
                return;
            }
            store.insert_after (out new_iter, last_iter);
            store.set (new_iter, 0, null, 1, DELETE_PRESET, 2,  new ThemedIcon ("edit-delete-symbolic"));
            last_iter = new_iter;
            store.insert_after (out new_iter, last_iter);
            store.set (new_iter, 0, null, 1, SEPARATOR_NAME, 2, null);
        }
    }
}
