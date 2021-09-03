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
        private EngineMegalobiz? enginemegalobiz;
        private EngineSubtittle4Songs? enginesubtittle4songs;
        private uint hiding_timer = 0;

        public SearchDialog () {
            Object (
                resizable: true,
                deletable: false,
                use_header_bar: 1,
                skip_taskbar_hint: true,
                transient_for: NikiApp.window,
                destroy_with_parent: true
            );
        }

        construct {
            var open_menu = new ButtonRevealer ("open-menu-symbolic") {
                transition_type = Gtk.RevealerTransitionType.CROSSFADE,
                transition_duration = 500
            };
            var back_download = new ButtonRevealer ("open-menu-symbolic") {
                transition_type = Gtk.RevealerTransitionType.CROSSFADE,
                transition_duration = 500
            };
            var tittle_header = new Gtk.Label ("Lyric Downloader") {
                halign = Gtk.Align.CENTER,
                hexpand = true
            };
            tittle_header.get_style_context ().add_class ("h4");

            var header = get_header_bar ();
            header.pack_start (back_download);
            header.set_custom_title (tittle_header);
            header.pack_end (open_menu);

            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");

            enginesubtittle4songs = new EngineSubtittle4Songs ();
            enginemegalobiz = new EngineMegalobiz ();
            engineviewlrc = new EngineViewlyrics ();
            enginenetease = new EngineNetease ();
            title_entry = new Gtk.Entry () {
                text = NikiApp.settings.get_string ("title-playing")
            };
            artist_entry = new Gtk.Entry () {
                text = NikiApp.settings.get_string ("artist-music")
            };
            album_entry = new Gtk.Entry () {
                text = NikiApp.settings.get_string ("album-music")
            };

            listmodel = new Gtk.ListStore (SearchLyric.N_COLUMNS, typeof (string), typeof (string), typeof (string), typeof (string), typeof (string));

            tree_view = new Gtk.TreeView () {
                model = listmodel,
                headers_visible = true,
                expand = true
            };
            tree_view.append_column (tree_view_column (_("Title"), SearchLyric.TITLE));
            tree_view.append_column (tree_view_column (_("Artist"), SearchLyric.ARTIST));
            tree_view.append_column (tree_view_column (_("Type File"), SearchLyric.TYPEFILE));
            tree_view.append_column (tree_view_column (_("Server"), SearchLyric.SERVER));

            tree_view.row_activated.connect ((path, column) => {
                Gtk.TreeIter iter;
                listmodel.get_iter (out iter, path);
                get_iter_select (NikiApp.window.player_page.playback.uri, iter);
            });
            var scr_lyric = new Gtk.ScrolledWindow (null, null) {
                expand = true,
                width_request = 350,
                height_request = 250
            };
            scr_lyric.add (tree_view);
            var frame = new Gtk.Frame (null);
            frame.add (scr_lyric);

            var title_label = new Gtk.Label (_("Title:")) {
                halign = Gtk.Align.START
            };
            var artist_label = new Gtk.Label (_("Artist:")) {
                halign = Gtk.Align.START
            };
            var album_label = new Gtk.Label (_("Album:")) {
                halign = Gtk.Align.START
            };
            album_label.halign = Gtk.Align.START;

            var grid_combine = new Gtk.Grid () {
                expand = true,
                margin_start = 10,
                margin_end = 10,
                column_spacing = 5,
                row_spacing = 5
            };
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

            label = new Gtk.Label (null) {
                valign = Gtk.Align.CENTER,
                ellipsize = Pango.EllipsizeMode.END
            };
            spinner = new Gtk.Spinner ();
            spinner.margin_end = 5;
            spinner.valign = Gtk.Align.CENTER;

            var prog_grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                valign = Gtk.Align.CENTER
            };
            prog_grid.add (spinner);
            prog_grid.add (label);

            prog_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_UP,
                margin_top = 5,
                margin_start = 10
            };
            prog_revealer.add (prog_grid);

            var box_action = new Gtk.Grid () {
                column_spacing = 5,
                margin_top = 5,
                margin_start = 10,
                margin_bottom = 10,
                margin_end = 10,
                column_homogeneous = true
            };
            box_action.orientation = Gtk.Orientation.HORIZONTAL;
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.add (download_button);
            box_action.add (search_button);
            box_action.add (close_button);

            var grid_ver = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL
            };
            grid_ver.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid_ver.add (grid_combine);
            grid_ver.add (prog_revealer);
            grid_ver.add (box_action);

            get_content_area ().add (grid_ver);

            show.connect (()=> {
                NikiApp.window.player_page.bottom_bar.set_reveal_child (false);
            });
            enginesubtittle4songs.send_data.connect (get_engindata);
            enginemegalobiz.send_data.connect (get_engindata);
            enginenetease.send_data.connect (get_engindata);
            engineviewlrc.send_data.connect (get_engindata);
            enginenetease.send_lrc.connect (save_to_file);
            engineviewlrc.send_lrc.connect (save_to_file);
            enginemegalobiz.send_lrc.connect (save_to_file);
            enginesubtittle4songs.send_lrc.connect (save_to_file);
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
            return server_coll;
        }

        private void get_iter_select (string uri, Gtk.TreeIter iter) {
            string linkfile, ext, server;
            listmodel.get (iter, SearchLyric.LINKFILE, out linkfile, SearchLyric.TYPEFILE, out ext, SearchLyric.SERVER, out server);
            save_lrc (uri, linkfile, ext, server);
        }

        private void search_lrc () {
            listmodel.clear ();
            send_notification (_("Searching…"));
            enginenetease.search_lyrics (title_entry.text, artist_entry.text);
            engineviewlrc.search_lyrics (title_entry.text, artist_entry.text);
            enginemegalobiz.search_lyrics (title_entry.text, artist_entry.text);
            enginesubtittle4songs.search_lyrics (title_entry.text, artist_entry.text);
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
            send_notification ("Downloading…");
            if (server == "NetEase") {
                enginenetease.download_lyric (link, uri);
            } else if (server == "ViewLRC") {
                engineviewlrc.download_lyric (link, uri);
            } else if (server == "MegaLobiz") {
                enginemegalobiz.download_lyric (link, uri);
            } else if (server == "Subtittle4Songs") {
                enginesubtittle4songs.download_lyric (link, uri);
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
