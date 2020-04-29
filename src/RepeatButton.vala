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
    public class RepeatButton : Gtk.Button {
        private Gtk.Image repeat_image;
        construct {
            get_style_context ().add_class ("button_action");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            focus_on_click = false;
            repeat_image = new Gtk.Image.from_icon_name ("tools-timer-symbolic", Gtk.IconSize.BUTTON);
            repeat_image.valign = Gtk.Align.CENTER;
            repeat_image.halign = Gtk.Align.CENTER;
            clicked.connect (() => {
                repeatmode.switch_repeat_mode ();
            });
            add (repeat_image);
            repeat_icon ();
            NikiApp.settings.changed["repeat-mode"].connect (repeat_icon);
        }
        public void repeat_icon () {
            switch (NikiApp.settings.get_enum ("repeat-mode")) {
                case RepeatMode.ALL :
                    ((Gtk.Image) repeat_image).icon_name = "media-playlist-repeat-symbolic";
                    set_tooltip_text (StringPot.Repeat_All);
                    break;
                case RepeatMode.ONE :
                    ((Gtk.Image) repeat_image).icon_name = "media-playlist-repeat-one-symbolic";
                    set_tooltip_text (StringPot.Repeat_One);
                    break;
                case RepeatMode.OFF :
                    ((Gtk.Image) repeat_image).icon_name = "media-playlist-no-repeat-symbolic";
                    set_tooltip_text (StringPot.Disable_Repeat);
                    break;
            }
        }
    }
}
