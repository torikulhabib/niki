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
    public class KeyboardInfo : Gtk.Window {

        construct {
            var type_grid = new Gtk.Grid ();
            type_grid.margin_start = type_grid.margin_end = 8;
            type_grid.row_spacing = 4;
            type_grid.attach (new HeaderLabel (StringPot.Type_Keys, 150), 0, 0, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Fullscreen, "F"), 0, 1, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Quit, "Q"), 0, 2, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Muted, "M"), 0, 3, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Next, "N"), 0, 4, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Previous, "B"), 0, 5, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Playlist, "P"), 0, 6, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Show, "I"), 0, 7, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Lyric, "L"), 0, 8, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Settings, "S"), 0, 9, 1, 1);
            type_grid.attach (new Granite.AccelLabel (StringPot.Home, "H"), 0, 10, 1, 1);
            var cont_grid = new Gtk.Grid ();
            cont_grid.margin_end = cont_grid.margin_start = 8;
            cont_grid.row_spacing = 4;
            cont_grid.attach (new HeaderLabel (StringPot.Control_Keys, 150), 0, 0, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Exit_Fullscreen, "Escape"), 0, 1, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Volume_UP, "Page_Up"), 0, 2, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Volume_DOWN, "Page_Down"), 0, 3, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_U5, "Right"), 0, 4, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_M5, "Left"), 0, 5, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_U30, "Up"), 0, 6, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_M30, "Down"), 0, 7, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_U10, "<Shift>Right"), 0, 8, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_M10, "<Shift>Left"), 0, 9, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_U60, "<Shift>Up"), 0, 10, 1, 1);
            cont_grid.attach (new Granite.AccelLabel (StringPot.Seek_M60, "<Shift>Down"), 0, 11, 1, 1);

            var main_grid = new Gtk.Grid ();
            main_grid.margin = 8;
            main_grid.attach (type_grid, 0, 0, 1, 1);
            main_grid.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
            main_grid.attach (cont_grid, 2, 0, 1, 1);
            var scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.add (main_grid);
            scrolled_window.width_request = 600;
            scrolled_window.height_request = 440;
            move_widget (this, this);
            set_keep_above (true);
            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.show_close_button = true;
            headerbar.title = StringPot.Niki_Keys;
            headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            headerbar.get_style_context ().add_class ("default-decoration");
            set_titlebar (headerbar);
            get_style_context ().add_class ("rounded");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            resizable = false;
            add (scrolled_window);
            show_all ();
        }
    }
}
