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
    public class MusicList : Gtk.Grid {
        private Gtk.TreeView tree_view;
        private Gtk.ListStore listmodel;
        private Gtk.Label label_album;
        private Gtk.Label album_name;
        private Gtk.Label label_artist;
        private Gtk.Label label_year;
        private AsyncImage? asyncimage;

        public MusicList () {
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            asyncimage = new AsyncImage (true);
            asyncimage.pixel_size = 85;
            asyncimage.margin_end = 5;
            asyncimage.set_from_pixbuf (align_and_scale_pixbuf (unknown_cover (), 85));
            asyncimage.show ();
            var openimage = new Gtk.Grid ();
            openimage.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            openimage.get_style_context ().add_class ("transparantbg");
            openimage.add (asyncimage);
            label_album = new Gtk.Label ("Album");
            label_album.halign = Gtk.Align.START;
            label_album.ellipsize = Pango.EllipsizeMode.END;
            album_name = new Gtk.Label ("Example Album");
            album_name.get_style_context ().add_class ("h2");
            album_name.halign = Gtk.Align.START;
            album_name.ellipsize = Pango.EllipsizeMode.END;
            label_artist = new Gtk.Label ("By Audi");
            label_artist.halign = Gtk.Align.START;
            label_artist.ellipsize = Pango.EllipsizeMode.END;
            label_year = new Gtk.Label ("2019");
            label_year.halign = Gtk.Align.START;
            label_year.ellipsize = Pango.EllipsizeMode.END;

            var grid_label = new Gtk.Grid ();
            grid_label.orientation = Gtk.Orientation.VERTICAL;
            grid_label.valign = Gtk.Align.CENTER;
            grid_label.add (label_album);
            grid_label.add (album_name);
            grid_label.add (label_artist);
            grid_label.add (label_year);
            grid_label.show_all ();

            var imagege_box = new Gtk.Grid ();
            imagege_box.get_style_context ().add_class ("ground_action_button");
            imagege_box.orientation = Gtk.Orientation.HORIZONTAL;
            imagege_box.valign = Gtk.Align.CENTER;
            imagege_box.halign = Gtk.Align.START;
            imagege_box.add (openimage);
            imagege_box.add (grid_label);

            var image_grid = new Gtk.Grid ();
            image_grid.orientation = Gtk.Orientation.HORIZONTAL;
            image_grid.valign = Gtk.Align.CENTER;
            image_grid.halign = Gtk.Align.START;
            image_grid.margin_start = 30;
            image_grid.margin_top = 30;
            image_grid.margin_bottom = 20;
            image_grid.add (imagege_box);
            tree_view = new Gtk.TreeView ();

            listmodel = new Gtk.ListStore (MusicColumns.N_COLUMNS, typeof (Icon), typeof (int), typeof (string), typeof (string), typeof (string), typeof (string), typeof (int), typeof (string));
            tree_view.model = listmodel;
            tree_view.headers_visible = true;
            tree_view.expand = true;
            tree_view.append_column (tree_view_column (_("Track"), MusicColumns.TRACK));
            tree_view.append_column (tree_view_column (_("Title"), MusicColumns.TITLE));
            tree_view.append_column (tree_view_column (_("Artist"), MusicColumns.ARTIST));
            tree_view.append_column (tree_view_column (_("Album"), MusicColumns.ALBUM));
            tree_view.append_column (tree_view_column (_("Genre"), MusicColumns.GENRE));
            tree_view.append_column (tree_view_column (_("Year"), MusicColumns.DATE));

            tree_view.row_activated.connect ((path, column) => {
                Gtk.TreeIter iter;
                listmodel.get_iter (out iter, path);
            });

            var scr_lyric = new Gtk.ScrolledWindow (null, null);
            scr_lyric.expand = true;
            scr_lyric.width_request = 350;
            scr_lyric.height_request = 250;
            scr_lyric.add (tree_view);
            var frame = new Gtk.Frame (null);
            frame.margin_start = 30;
            frame.margin_end = 20;
            frame.add (scr_lyric);
            var prog_grid = new Gtk.Grid ();
            prog_grid.orientation = Gtk.Orientation.VERTICAL;
            prog_grid.add (image_grid);
            prog_grid.add (frame);
            add (prog_grid);
        }

        private Gtk.TreeViewColumn tree_view_column (string title, MusicColumns column) {
            var server_coll = new Gtk.TreeViewColumn.with_attributes (title, new Gtk.CellRendererText (), "text", column);
            server_coll.resizable = true;
            server_coll.clickable = true;
            server_coll.expand = false;
            server_coll.reorderable = true;
            server_coll.sort_indicator = true;
            server_coll.sort_column_id = column;
            server_coll.min_width = 20;
            server_coll.sizing = Gtk.TreeViewColumnSizing.GROW_ONLY;
            return server_coll;
        }
    }
}
