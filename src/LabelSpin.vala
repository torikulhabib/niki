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

namespace Niki {
    private class LabelSpin : Gtk.Grid {
        public string slabel {get; construct;}
        public int max_spin {get; construct;}
        public Gtk.SpinButton number_entry {get; construct;}

        public LabelSpin (string slabel, int max_spin) {
            Object (
                slabel: slabel,
                max_spin: max_spin
            );
        }

        construct {
            var label = new Gtk.Label (slabel) {
                halign = Gtk.Align.START
            };
            number_entry = new Gtk.SpinButton.with_range (0, max_spin, 1);
            orientation = Gtk.Orientation.HORIZONTAL;
            column_homogeneous = true;
            add (label);
            add (number_entry);
            show_all ();
        }
    }
}
