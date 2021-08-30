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
    public class SearchEntry : Gtk.Entry {

        public SearchEntry (Playlist playlist) {
            hexpand = true;
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.PRIMARY) {
                    searchentry.switch_search_mode ();
                }
            });
            activates_default = true;
            NikiApp.settings.changed["search-entry"].connect (()=>{
                get_random (playlist);
            });
            get_random (playlist);
        }

        private void get_random (Playlist playlist) {
            switch (NikiApp.settings.get_enum ("search-entry")) {
                case 0:
                    primary_icon_name = "com.github.torikulhabib.niki.title-symbolic";
                    primary_icon_tooltip_markup = _("Title");
                    playlist.set_search_column (PlaylistColumns.TITLE);
                    break;
                case 1:
                    primary_icon_name = "avatar-default-symbolic";
                    primary_icon_tooltip_markup = _("Artist");
                    playlist.set_search_column (PlaylistColumns.ARTISTMUSIC);
                    break;
                case 2:
                    primary_icon_name = "media-optical-symbolic";
                    primary_icon_tooltip_markup = _("Album");
                    playlist.set_search_column (PlaylistColumns.ALBUMMUSIC);
                    break;
            }
        }
    }
}
