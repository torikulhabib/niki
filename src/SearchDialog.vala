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
    public class SearchDialog : Gtk.Dialog {
        private Gtk.Entry title_entry;
        private Gtk.Entry artist_entry;
        private Gtk.Entry album_entry;
        private Gtk.TreeView tree_view;
        private Gtk.ListStore listmodel;
        private Gtk.Label label;
        private Gtk.Spinner spinner;
        private Gtk.Revealer prog_revealer;
        private EngineViewlyrics? engineviewlrc;
        private EngineNetease? enginenetease;
        private uint hiding_timer = 0;

        public SearchDialog (string playfile) {
            Object (
                resizable: true,
                deletable: false,
                use_header_bar: 1,
                skip_taskbar_hint: true,
                transient_for: NikiApp.window,
                destroy_with_parent: true
            );
            var header_action = new Gtk.Label ("Lyric Downloader");
            header_action.get_style_context ().add_class ("h4");
            header_action.halign = Gtk.Align.CENTER;
            header_action.hexpand = true;
            get_header_bar ().set_custom_title (header_action);
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            engineviewlrc = new EngineViewlyrics ();
            enginenetease = new EngineNetease ();
            title_entry = new Gtk.Entry ();
            artist_entry = new Gtk.Entry ();
            album_entry = new Gtk.Entry ();
            var path = File.new_for_uri (playfile);
            title_entry.text = get_song_info (path);
            artist_entry.text = get_artist_music (path);
            album_entry.text = get_album_music (path);

            tree_view = new Gtk.TreeView ();
            listmodel = new Gtk.ListStore (SearchLyric.N_COLUMNS, typeof (string), typeof (string), typeof (string), typeof (string), typeof (string));
            tree_view.model = listmodel;
            tree_view.headers_visible = true;
            tree_view.expand = true;
            tree_view.append_column (tree_view_column (_("Title"), SearchLyric.TITLE));
            tree_view.append_column (tree_view_column (_("Artist"), SearchLyric.ARTIST));
            tree_view.append_column (tree_view_column (_("Type File"), SearchLyric.TYPEFILE));
            tree_view.append_column (tree_view_column (_("Server"), SearchLyric.SERVER));

            tree_view.row_activated.connect ((path, column) => {
                Gtk.TreeIter iter;
                listmodel.get_iter (out iter, path);
                get_iter_select (NikiApp.window.player_page.playback.uri, iter);
            });
            var scr_lyric = new Gtk.ScrolledWindow (null, null);
            scr_lyric.expand = true;
            scr_lyric.width_request = 350;
            scr_lyric.height_request = 250;
            scr_lyric.add (tree_view);
            var frame = new Gtk.Frame (null);
            frame.add (scr_lyric);

            var title_label = new Gtk.Label (_("Title:"));
            title_label.halign = Gtk.Align.START;
            var artist_label = new Gtk.Label (_("Artist:"));
            artist_label.halign = Gtk.Align.START;
            var album_label = new Gtk.Label (_("Album:"));
            album_label.halign = Gtk.Align.START;

            var grid_combine = new Gtk.Grid ();
            grid_combine.expand = true;
            grid_combine.margin_start = 10;
            grid_combine.margin_end = 10;
            grid_combine.column_spacing = 5;
            grid_combine.row_spacing = 5;
            grid_combine.attach (title_label, 0, 0);
            grid_combine.attach (title_entry, 1, 0);
            grid_combine.attach (artist_label, 0, 1);
            grid_combine.attach (artist_entry, 1, 1);
            grid_combine.attach (album_label, 0, 2);
            grid_combine.attach (album_entry, 1, 2);
            grid_combine.attach (frame, 0, 3, 2, 2);

            var search_button = new Gtk.Button.with_label (_("Search"));
            search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            search_button.clicked.connect (search_lrc);

            var close_button = new Gtk.Button.with_label (_("Close"));
            close_button.clicked.connect (()=>{
                destroy ();
            });

            var download_button = new Gtk.Button.with_label (_("Download"));
            download_button.clicked.connect (()=>{
                Gtk.TreeIter iter;
                if (!tree_view.get_selection ().get_selected (null, out iter)) {
                    return;
                }
                get_iter_select (NikiApp.window.player_page.playback.uri, iter);
            });

            move_widget (this);

            label = new Gtk.Label (null);
            label.valign = Gtk.Align.CENTER;
            label.ellipsize = Pango.EllipsizeMode.END;
            spinner = new Gtk.Spinner ();
            spinner.margin_end = 5;
            spinner.valign = Gtk.Align.CENTER;

            var prog_grid = new Gtk.Grid ();
            prog_grid.orientation = Gtk.Orientation.HORIZONTAL;
            prog_grid.valign = Gtk.Align.CENTER;
            prog_grid.add (spinner);
            prog_grid.add (label);

            prog_revealer = new Gtk.Revealer ();
            prog_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            prog_revealer.add (prog_grid);

		    var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.spacing = 5;
            box_action.margin_top = 5;
            box_action.margin_start = 10;
            box_action.margin_end = 10;
            box_action.margin_bottom = 10;
            box_action.pack_end (close_button, false, true, 0);
            box_action.pack_end (search_button, false, true, 0);
            box_action.pack_end (download_button, false, true, 0);
            box_action.pack_start (prog_revealer, false, false, 0);

		    var grid_ver = new Gtk.Grid ();
            grid_ver.orientation = Gtk.Orientation.VERTICAL;
            grid_ver.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid_ver.add (grid_combine);
            grid_ver.add (box_action);

            get_content_area ().add (grid_ver);

            show.connect(()=>{
                NikiApp.window.player_page.bottom_bar.set_reveal_child (false);
            });
            enginenetease.send_data.connect (get_engindata);
            engineviewlrc.send_data.connect (get_engindata);
            enginenetease.send_lrc.connect (save_to_file);
            engineviewlrc.send_lrc.connect (save_to_file);
        }
        public void send_notification (string text) {
            spinner.active = true;
            prog_revealer.reveal_child = true;
            label.label = text;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add_seconds (2, () => {
                spinner.active = false;
                prog_revealer.reveal_child = false;
                hiding_timer = 0;
                return false;
            });
        }
        private Gtk.TreeViewColumn tree_view_column (string title, SearchLyric column) {
            var server_coll = new Gtk.TreeViewColumn.with_attributes (title, new Gtk.CellRendererText (), "text", column);
            server_coll.resizable = true;
            server_coll.clickable = true;
            server_coll.expand = true;
            server_coll.reorderable = true;
            server_coll.sort_indicator = true;
            server_coll.sort_column_id = column;
            server_coll.min_width = 20;
            server_coll.sizing = Gtk.TreeViewColumnSizing.GROW_ONLY;
            return server_coll;
        }

        private void get_iter_select (string uri, Gtk.TreeIter iter) {
            string linkfile, ext, server;
            listmodel.get (iter, SearchLyric.LINKFILE, out linkfile, SearchLyric.TYPEFILE, out ext, SearchLyric.SERVER, out server);
            save_lrc (uri, linkfile, ext, server);
        }
        private void search_lrc () {
            listmodel.clear ();
            send_notification ("Searching...");
            enginenetease.search_lyrics (title_entry.text, artist_entry.text);
            engineviewlrc.search_lyrics (title_entry.text, artist_entry.text);
        }
        private void get_engindata (string title, string artist, string type, string linkfile, string server) {
            bool exist = false;
            listmodel.foreach ((model, path, iter) => {
                string link;
                model.get (iter, SearchLyric.LINKFILE, out link);
                if (link == linkfile) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }
            Gtk.TreeIter iter;
            listmodel.append (out iter);
            listmodel.set (iter, SearchLyric.TITLE, title, SearchLyric.ARTIST, artist, SearchLyric.TYPEFILE, type, SearchLyric.LINKFILE, linkfile, SearchLyric.SERVER, server);
            send_notification (@"Found $(server)");
        }
        private void save_lrc (string uri, string link, string ext, string server) {
            switch (NikiApp.settings.get_int ("location-save")) {
                case 0 :
                    var lrc_file = Path.build_filename (get_path_noname (uri), @"$(get_name_noext (uri)).$(ext.down ())");
                    down_load (lrc_file, link, server);
                    break;
                case 1 :
                    var lrc_file = Path.build_filename (NikiApp.settings.get_string ("lyric-location"), @"$(get_name_noext (uri)).$(ext.down ())");
                    down_load (lrc_file, link, server);
                    break;
                case 2 :
                    var file = run_open_folder (this);
                    if (file != null) {
                        var lrc_file = Path.build_filename (file.get_path (), @"$(get_name_noext (uri)).$(ext.down ())");
                    	down_load (lrc_file, link, server);
                    }
                    break;
            }
        }

        private void down_load (string uri, string link, string server) {
            send_notification ("Downloading...");
            if (server == "NetEase") {
                enginenetease.download_lyric (link, uri);
            } else if (server == "ViewLRC") {
                engineviewlrc.download_lyric (link, uri);
            }
        }

        private void save_to_file (string lrc, string uri) {
            try {
                File file = File.new_for_path (uri);
                permanent_delete (file);
            	FileOutputStream out_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
            	out_stream.write (lrc.data);
                send_notification ("Downloaded");
                NikiApp.window.player_page.reloadlrc ();
            } catch (Error e) {
                send_notification (e.message);
            }
        }
    }
}
