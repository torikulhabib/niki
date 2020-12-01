/*
* Copyright (c) {2019} torikulhabib (https://github.com/torikulhabib)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@Gmail.com>
*/

namespace niki {
    public class EqualizerPresetList : Gtk.ComboBox {
        public signal void preset_selected (EqualizerPreset preset);
        public signal void delete_preset_chosen ();
        public EqualizerPreset? equalizer_preset;
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

        public void add_preset (EqualizerPreset ep) {
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
                store.set (iter, ComboColumns.OBJECT, ep, ComboColumns.STRING, ep.name, ComboColumns.ICON, new ThemedIcon ("com.github.torikulhabib.niki.equalizer-on-symbolic"));
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
            foreach (var preset in AudioMix.get_default_presets ()) {
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
                GLib.Object objets;
                store.get (iter, ComboColumns.OBJECT, out objets);

                if (objets != null && objets is EqualizerPreset && ((EqualizerPreset)objets) == equalizer_preset) {
                    if (!((EqualizerPreset)objets).is_default) {
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
            if (!NikiApp.settingsEq.get_boolean ("equalizer-enabled")) {
                NikiApp.settingsEq.set_boolean ("equalizer-enabled", true);
            }
            if (modifying_list) {
                return;
            }
            Gtk.TreeIter it;
            get_active_iter (out it);
            selected_iters (it);
        }
        private void selected_iters (Gtk.TreeIter it) {
            GLib.Object objets;
            store.get (it, ComboColumns.OBJECT, out objets);
            if (objets != null && objets is EqualizerPreset) {
                equalizer_preset = objets as EqualizerPreset;
                if (!((EqualizerPreset)objets).is_default) {
                    add_delete_preset_option ();
                } else {
                    remove_delete_option ();
                }
                preset_selected (objets as EqualizerPreset);
                return;
            }

            string option;
            store.get (it, ComboColumns.STRING, out option);
            if (option == OFF_MODE) {
                NikiApp.settingsEq.set_boolean ("equalizer-enabled", false);
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
                    GLib.Object objets;
                    store.get (iter, ComboColumns.OBJECT, out objets);
                    if (objets != null && objets is EqualizerPreset && ((EqualizerPreset) objets).name == preset_name) {
                        set_active_iter (iter);
                        preset_selected (objets as EqualizerPreset);
                        return;
                    }
                }
            }
            select_delete_preset ();
        }

        public EqualizerPreset? get_selected_preset () {
            Gtk.TreeIter it;
            get_active_iter (out it);
            GLib.Object objets;
            store.get (it, ComboColumns.OBJECT, out objets);
            if (objets != null && objets is EqualizerPreset) {
                return objets as EqualizerPreset;
            } else {
                return null;
            }
        }

        public Gee.Collection<EqualizerPreset> get_presets () {
            var rv = new Gee.LinkedList<EqualizerPreset> ();
            Gtk.TreeIter iter;
            for (int i = 0; store.get_iter_from_string (out iter, i.to_string ()); ++i) {
                GLib.Object objets;
                store.get (iter, ComboColumns.OBJECT, out objets);

                if (objets != null && objets is EqualizerPreset) {
                    rv.add (objets as EqualizerPreset);
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
