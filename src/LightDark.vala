/*
* Copyright (C) 2018  Torikul habib <torik.habib@gmail.com>
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
* Authored by: torikulhabib <torik.habib@gmail.com>
*/

namespace niki {
    public class LightDark : Gtk.Button {
        private Gtk.Image icon_image;

        construct {
            get_style_context ().add_class ("transparantbg");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            icon_image = new Gtk.Image.from_icon_name ("display-brightness-symbolic", Gtk.IconSize.BUTTON);
            clicked.connect (() => {
                NikiApp.settings.set_boolean ("dark-style", !NikiApp.settings.get_boolean ("dark-style"));
                NikiApp.settings.set_string ("path-css", !NikiApp.settings.get_boolean ("dark-style")? "/com/github/torikulhabib/niki/css/applicationlight.css" : "/com/github/torikulhabib/niki/css/applicationdark.css");
                darklight ();
            });
            darklight ();
            add (icon_image);
        }
        private void darklight () {
            tooltip_text = !NikiApp.settings.get_boolean ("dark-style")? _("Light") : _("Dark");
            icon_image.icon_name = !NikiApp.settings.get_boolean ("dark-style")? "display-brightness-symbolic" : "weather-clear-night-symbolic";
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = NikiApp.settings.get_boolean ("dark-style");
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource (NikiApp.settings.get_string ("path-css"));
            Gtk.StyleContext.add_provider_for_screen ( Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION );
        }
    }
}
