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
    public class DLNAVolumeButton : Gtk.Button {
        private Gtk.Image volume_image;

        construct {
            get_style_context ().add_class ("transparantbg");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            volume_image = new Gtk.Image.from_icon_name ("audio-volume-high-symbolic", Gtk.IconSize.BUTTON);
            volume_image.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            volume_image.valign = Gtk.Align.CENTER;
            volume_image.halign = Gtk.Align.CENTER;
            margin_top = 2;
            add (volume_image);
            NikiApp.settings.changed["dlna-volume"].connect (() => {
                volume_icon ();
            });
            NikiApp.settings.changed["dlna-muted"].connect (() => {
                Idle.add (volume_icon);
                volume_mute ();
            });
            volume_mute ();
            volume_icon ();
        }
        public bool volume_icon () {
            if (!NikiApp.settings.get_boolean ("dlna-muted")) {
                if (NikiApp.settings.get_int ("dlna-volume") > 10 && NikiApp.settings.get_int ("dlna-volume") <= 35) {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-low-symbolic";
                } else if (NikiApp.settings.get_int ("dlna-volume") > 35 && NikiApp.settings.get_int ("dlna-volume") <= 75) {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-medium-symbolic";
                } else if (NikiApp.settings.get_int ("dlna-volume") > 75) {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-high-symbolic";
                } else {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-muted-symbolic";
                }
            }
            return false;
        }
        private void volume_mute () {
            ((Gtk.Image) volume_image).icon_name = NikiApp.settings.get_boolean ("dlna-muted")? "audio-volume-muted-blocking-symbolic" : "audio-volume-high-symbolic";
            volume_image.tooltip_text = NikiApp.settings.get_boolean ("dlna-muted")? _("Muted") : double_to_percent ((double)NikiApp.settings.get_int ("dlna-volume") / 100);
        }
    }
}
