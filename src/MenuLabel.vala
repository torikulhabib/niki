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
    private class MenuLabel : Gtk.Grid {
        public string image_name { get; construct; }
        public string label { get; construct; }

        public MenuLabel (string image_name, string label) {
            Object (
                image_name: image_name,
                label: label
            );
        }

        construct {
            var label = new Gtk.Label (label) {
                hexpand = true,
                xalign = 0
            };

            var image_menu = new Gtk.Image ();
            image_menu.set_from_gicon (new ThemedIcon (image_name), Gtk.IconSize.BUTTON);
            column_spacing = 3;
            add (image_menu);
            add (label);
        }
    }
}
