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
    public class ComboxImage : Gtk.ComboBox {
        private Gtk.ListStore store;

        construct {
            store = new Gtk.ListStore (2, typeof (Icon), typeof (string));
            model = store;
		    var cell = new Gtk.CellRendererText ();
		    cell.ellipsize = Pango.EllipsizeMode.END;
		    var cell_pb = new Gtk.CellRendererPixbuf ();
		    pack_start (cell_pb, false);
		    pack_start (cell, false);
		    set_attributes (cell_pb, "gicon", 0);
		    set_attributes (cell, "text", 1);
        }
        public void appending (string image_icon, string label_text) {
            Gtk.TreeIter iter;
            store.append (out iter);
            store.set (iter, 0, new ThemedIcon (image_icon), 1, label_text);
        }
        public int get_active_int () {
            return active;
        }
        public string get_active_name () {
            Gtk.TreeIter iter;
            string name_col = null;
            if (!get_active_iter (out iter)) {
                return name_col;
            }
            store.get (iter, 1, out name_col);
            if (name_col == null) {
                return name_col;
            }
            return name_col;
        }
        public void remove_all () {
            int b = model.iter_n_children (null);
            for (int i = 0; i < b; i++) {
                Gtk.TreeIter iter;
                if (store.get_iter_first (out iter)){
                    store.remove (ref iter);
                }
            }
        }
    }
}
