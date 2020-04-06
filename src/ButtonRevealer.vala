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
    public class ButtonRevealer : Gtk.Revealer {
        public Gtk.Button revealer_button;
        public signal void clicked ();

        public ButtonRevealer (string image) {
            revealer_button = new Gtk.Button.from_icon_name (image, Gtk.IconSize.BUTTON);
            revealer_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            revealer_button.clicked.connect (() => {
                clicked ();
            });
            add (revealer_button);
            change_icon (image);
        }
        public void change_icon (string change) {
            ((Gtk.Image) revealer_button.image).icon_name = change;
        }
    }
}
