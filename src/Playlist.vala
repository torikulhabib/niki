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
    public class Playlist : Gtk.TreeView {
        public signal void play (string path, string size, int mediatype, bool playnow);
        public signal void item_added ();
        private ObjectPixbuf? objectpixbuf;
        public Gtk.ListStore liststore;
        public Gtk.TreeIter select_iter;
        public int current = 0;
        public int total = 0;
        public bool visible_menu = false;
        public signal void visible_menus ();

        construct {
            get_style_context ().add_class ("playlist");
            objectpixbuf = new ObjectPixbuf ();
            liststore = new Gtk.ListStore (PlaylistColumns.N_COLUMNS, typeof (Icon), typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string), typeof (string), typeof (bool), typeof (int), typeof (int));
            model = liststore;
            expand = true;
            headers_visible = activate_on_single_click = false;

            var text_render = new Gtk.CellRendererText ();
            text_render.ellipsize = Pango.EllipsizeMode.END;
            text_render.text = null;

            insert_column_with_attributes (-1, "Playing", new Gtk.CellRendererPixbuf (), "gicon", PlaylistColumns.PLAYING);
            insert_column_with_attributes (-1, "Preview", new Gtk.CellRendererPixbuf (), "pixbuf", PlaylistColumns.PREVIEW);
            insert_column_with_attributes (-1, "Title", text_render, "markup", PlaylistColumns.ARTISTTITLE);
            set_tooltip_column (3);
		    set_enable_search (true);
            row_activated.connect ((path, column) => {
                if (!NikiApp.settings.get_boolean ("edit-playlist")) {
                    Gtk.TreeIter iter;
                    liststore.get_iter (out iter, path);
                    send_iter_to (iter);
                }
            });
            cursor_changed.connect (() => {
                if (!get_selection().get_selected(null, out select_iter)) {
                    return;
                }
            });

            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    if (NikiApp.settings.get_boolean ("edit-playlist")) {
                        Idle.add (() => {
                            if (!liststore.iter_is_valid (select_iter)) {
                                return Gdk.EVENT_PROPAGATE;
                            }
                            liststore.remove (ref select_iter);
                            update_playlist (50);
                            return Gdk.EVENT_PROPAGATE;
                        });
                    }
                }
                if (event.button == Gdk.BUTTON_SECONDARY && event.type != Gdk.EventType.2BUTTON_PRESS) {
                    Idle.add (() => {
                        var menu = new Gtk.Menu ();
                        var playing = new Gtk.MenuItem ();
                        playing.add (new MenuLabel ("media-playback-start-symbolic", StringPot.Play));
                        var from_list = new Gtk.MenuItem ();
                        from_list.add (new MenuLabel ("list-remove-symbolic", StringPot.Remove_Playlist));
                        var from_device = new Gtk.MenuItem ();
                        from_device.add (new MenuLabel ("edit-delete-symbolic", StringPot.Remove_Device));
                        var info_details = new Gtk.MenuItem ();
                        info_details.add (new MenuLabel ("dialog-information-symbolic", StringPot.Details));
                        var save_to = new Gtk.MenuItem ();
                        save_to.add (new MenuLabel ("drive-harddisk-symbolic", StringPot.Save_MyComputer));
                        menu.append (playing);
                        var menu_sub = new Gtk.MenuItem ();
                        menu_sub.add (new MenuLabel ("go-jump-symbolic", StringPot.Short_by));
                        var submenu_menu2 = new Gtk.Menu ();
                        var tittle_short = new Gtk.MenuItem ();
                        tittle_short.add (new MenuLabelRadio ("com.github.torikulhabib.niki.title-symbolic", StringPot.Titile, NikiApp.settings.get_int ("sort-by") == 0));
                        submenu_menu2.add (tittle_short);
                        var artist_short = new Gtk.MenuItem ();
                        artist_short.add (new MenuLabelRadio ("avatar-default-symbolic", StringPot.Artist, NikiApp.settings.get_int ("sort-by") == 1));
                        submenu_menu2.add (artist_short);
                        var album_short = new Gtk.MenuItem ();
                        album_short.add (new MenuLabelRadio ("media-optical-symbolic", StringPot.Album, NikiApp.settings.get_int ("sort-by") == 2));
                        submenu_menu2.add (album_short);
                        var costum_short = new Gtk.MenuItem ();
                        costum_short.add (new MenuLabelRadio ("edit-symbolic", StringPot.Custom, NikiApp.settings.get_int ("sort-by") == 3));
                        submenu_menu2.add (costum_short);
                        var spart_short = new Gtk.MenuItem ();
                        spart_short.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
                        submenu_menu2.add (spart_short);
                        var ascending_short = new Gtk.MenuItem ();
                        ascending_short.add (new MenuLabelRadio ("view-sort-descending-symbolic", StringPot.Ascending, NikiApp.settings.get_boolean ("ascen-descen")));
                        submenu_menu2.add (ascending_short);
                        var descending_short = new Gtk.MenuItem ();
                        descending_short.add (new MenuLabelRadio ("view-sort-ascending-symbolic", StringPot.Descending, !NikiApp.settings.get_boolean ("ascen-descen")));
                        submenu_menu2.add (descending_short);
                        menu_sub.submenu = (submenu_menu2);
                        menu.append (menu_sub);
                        menu.append (from_list);
                        tittle_short.activate.connect (() => {
                            NikiApp.settings.set_int ("sort-by", 0);
                        });
                        artist_short.activate.connect (() => {
                            NikiApp.settings.set_int ("sort-by", 1);
                        });
                        album_short.activate.connect (() => {
                            NikiApp.settings.set_int ("sort-by", 2);
                        });
                        costum_short.activate.connect (() => {
                            NikiApp.settings.set_int ("sort-by", 3);
                        });
                        ascending_short.activate.connect (() => {
                            NikiApp.settings.set_boolean("ascen-descen", true);
                        });
                        descending_short.activate.connect (() => {
                            NikiApp.settings.set_boolean("ascen-descen", false);
                        });
                        playing.activate.connect (() => {
                            send_iter_to (select_iter);
                            menu.hide ();
                        });
                        int input_mode, mediatype;
                        liststore.get (select_iter, PlaylistColumns.INPUTMODE, out input_mode, PlaylistColumns.MEDIATYPE, out mediatype);
                        if (input_mode == 0) {
                            menu.append (from_device);
                        }
                        if (input_mode == 0 && mediatype == 1) {
                            menu.append (info_details);
                        } else if (input_mode == 0 && mediatype == 0) {
                            menu.append (info_details);
                        }
                        if (input_mode == 2) {
                            menu.append (save_to);
                        }
                        menu.popup_at_pointer (event);
                        from_list.activate.connect (() => {
                            liststore.remove (ref select_iter);
                            update_playlist (50);
                            menu.hide ();
                        });
                        save_to.activate.connect (() => {
                            save_to_computer (select_iter);
                            menu.hide ();
                        });
                        from_device.activate.connect (() => {
                            create_dialog (select_iter);
                            menu.hide ();
                        });
                        info_details.activate.connect (() => {
                            edit_info ();
                            menu.hide ();
                        });
                        visible_menu = menu.visible;
                        menu.hide.connect (() => {
                            visible_menu = false;
                            visible_menus ();
                        });
                        menu.show_all ();
                        return Gdk.EVENT_PROPAGATE;
                    });
                }
                return Gdk.EVENT_PROPAGATE;
            });
            show_all ();
            ((Gtk.TreeSortable)liststore).sort_column_changed.connect (()=> {
                update_playlist (50);
            });
            model.row_inserted.connect (()=>{
                update_playlist (500);
            });
            NikiApp.settings.changed["repeat-mode"].connect (get_status_list);
            NikiApp.settings.changed["sort-by"].connect (get_random);
            NikiApp.settings.changed["shuffle-button"].connect (get_random);
            NikiApp.settings.changed["ascen-descen"].connect (get_random);
            get_random ();
        }
        private void get_random () {
            if (NikiApp.settings.get_boolean ("shuffle-button")) {
                ((Gtk.TreeSortable)liststore).set_sort_column_id (PlaylistColumns.FILESIZE, Gtk.SortType.ASCENDING);
            } else {
                switch (NikiApp.settings.get_int ("sort-by")) {
                    case 0:
                        reorderable = false;
                        ((Gtk.TreeSortable)liststore).set_sort_column_id (PlaylistColumns.TITLE, NikiApp.settings.get_boolean ("ascen-descen")? Gtk.SortType.ASCENDING : Gtk.SortType.DESCENDING);
                        break;
                    case 1:
                        reorderable = false;
                        ((Gtk.TreeSortable)liststore).set_sort_column_id (PlaylistColumns.ARTISTMUSIC, NikiApp.settings.get_boolean ("ascen-descen")? Gtk.SortType.ASCENDING : Gtk.SortType.DESCENDING);
                        break;
                    case 2:
                        reorderable = false;
                        ((Gtk.TreeSortable)liststore).set_sort_column_id (PlaylistColumns.ALBUMMUSIC, NikiApp.settings.get_boolean ("ascen-descen")? Gtk.SortType.ASCENDING : Gtk.SortType.DESCENDING);
                        break;
                    case 3:
                        reorderable = true;
                        break;
                }
            }
        }
        public bool next () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_from_string (out iter, (current + 1).to_string ())){
                send_iter_to (iter);
                return true;
            }
            return false;
        }

        public void previous () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_from_string (out iter, (current - 1).to_string ())){
                send_iter_to (iter);
            }
        }
        private void send_iter_to (Gtk.TreeIter iter) {
            string file_plying, titlename, album, artist, filesize;
            int mediatype;
            bool playnow;
            liststore.get (iter, PlaylistColumns.FILENAME, out file_plying, PlaylistColumns.TITLE, out titlename, PlaylistColumns.FILESIZE, out filesize, PlaylistColumns.MEDIATYPE, out mediatype, PlaylistColumns.ALBUMMUSIC, out album, PlaylistColumns.ARTISTMUSIC, out artist, PlaylistColumns.PLAYNOW, out playnow);
            NikiApp.settings.set_string ("tittle-playing", titlename);
            NikiApp.settings.set_string ("artist-music", artist);
            NikiApp.settings.set_string ("album-music", album);
            play (file_plying, filesize, mediatype, playnow);
        }
        private void create_dialog (Gtk.TreeIter iter_select) {
            string file_name, titlename;
            liststore.get (iter_select, PlaylistColumns.FILENAME, out file_name, PlaylistColumns.TITLE, out titlename);
            var message_dialog = new MessageDialog.with_image_from_icon_name (StringPot.Are_Sure_Remove, StringPot.Are_Sure, File.new_for_uri (file_name).get_path (), "user-trash");
            var move_trash = new Gtk.Button.with_label (StringPot.Move_Trash);
            var delete_permanent = new Gtk.Button.with_label (StringPot.Delete_Permanent);
            move_trash.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            delete_permanent.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            move_trash.show_all ();
            delete_permanent.show_all ();
            delete_permanent.clicked.connect (() => {
	            try {
		            File file = File.new_for_uri (file_name);
		            file.delete ();
	            } catch (Error e) {
		            print ("%s\n", e.message);
	            }
                liststore.remove (ref iter_select);
            });
            move_trash.clicked.connect (() => {
	            try {
		            File file = File.new_for_uri (file_name);
		            file.trash ();
	            } catch (Error e) {
		            print ("%s\n", e.message);
	            }
                liststore.remove (ref iter_select);
            });
            message_dialog.add_action_widget (move_trash, 0);
            message_dialog.add_button (StringPot.Close, Gtk.ButtonsType.CANCEL);
            message_dialog.add_action_widget (delete_permanent, 0);
            message_dialog.run ();
            message_dialog.show_all ();
            message_dialog.destroy ();
            update_playlist (50);
        }

        private void save_to_computer (Gtk.TreeIter iter_select) {
            string file_name, titlename;
            int mediatype;
            liststore.get (iter_select, PlaylistColumns.FILENAME, out file_name, PlaylistColumns.TITLE, out titlename, PlaylistColumns.MEDIATYPE, out mediatype);
            var download_dialog = new DownloadDialog (file_name, titlename, mediatype);
            download_dialog.show_all ();
        }

        private void edit_info () {
            var mediaeditor = new MediaEditor (this);
            mediaeditor.show_all ();
        }

        public void add_stream (string [] inputstream) {
            bool exist = false;
            string filenamein = Markup.escape_text (inputstream [2]);
            int mediatype = file_type (File.new_for_uri (inputstream [0]));
            Gtk.TreeIter iter;
            liststore.foreach ((model, path, iter) => {
                string filename;
                model.get (iter, PlaylistColumns.TITLE, out filename);
                if (filename == filenamein) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }
            Gdk.Pixbuf preview = align_and_scale_pixbuf (objectpixbuf.get_pixbuf_from_url (inputstream [1], inputstream [2]), 48);
            if (preview != null) {
                preview = objectpixbuf.icon_from_mediatype (mediatype);
            }
            liststore.append (out iter);
            liststore.set (iter, PlaylistColumns.PLAYING, null, PlaylistColumns.PREVIEW, preview, PlaylistColumns.TITLE, inputstream [2], PlaylistColumns.ARTISTTITLE, Markup.escape_text (inputstream [2]), PlaylistColumns.FILENAME, inputstream [0], PlaylistColumns.MEDIATYPE, mediatype, PlaylistColumns.FILESIZE, "", PlaylistColumns.ALBUMMUSIC, "", PlaylistColumns.ARTISTMUSIC, "", PlaylistColumns.PLAYNOW, true, PlaylistColumns.INPUTMODE, 1);
        }

        public void add_dlna (string input_url, string input_tittle, string input_album, string input_artist, int mediatype, bool playnow, string upnp_class, string size_file) {
            bool exist = false;
            if (mediatype == 4) {
                mediatype = 0;
            }
            string filenamein = Markup.escape_text (input_tittle);
            Gtk.TreeIter iter;
            liststore.foreach ((model, path, iter) => {
                string filename;
                model.get (iter, PlaylistColumns.TITLE, out filename);
                if (filename == filenamein) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }

            Gdk.Pixbuf preview = objectpixbuf.icon_from_type (upnp_class, 48);
            liststore.append (out iter);
            liststore.set (iter, PlaylistColumns.PLAYING, null, PlaylistColumns.PREVIEW, preview, PlaylistColumns.TITLE, input_tittle, PlaylistColumns.ARTISTTITLE, mediatype == 2? "<b>" + Markup.escape_text (input_tittle) + "</b>" + "\n" + Markup.escape_text (input_artist) + " - " + Markup.escape_text (input_album) : Markup.escape_text (input_tittle), PlaylistColumns.FILENAME, input_url, PlaylistColumns.FILESIZE, size_file, PlaylistColumns.MEDIATYPE, mediatype, PlaylistColumns.ALBUMMUSIC, input_album, PlaylistColumns.ARTISTMUSIC, input_artist, PlaylistColumns.PLAYNOW, playnow, PlaylistColumns.INPUTMODE, 2);
            update_playlist (50);
        }

        public void add_item (File path) {
            if (!path.query_exists ()) {
                return;
            }
            var file_name = path.get_uri ();
            bool exist = false;
            string album_music = "";
            string artist_music = "";
            string info_songs = get_song_info (path);
            Gtk.TreeIter iter;
            liststore.foreach ((model, path, iter) => {
                string filename;
                model.get (iter, PlaylistColumns.FILENAME, out filename);
                if (filename == file_name) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }

            Gdk.Pixbuf preview = null;
            if (get_mime_type (path).has_prefix ("video/")) {
                if (!FileUtils.test (normal_thumb (path), FileTest.EXISTS)) {
                    var dbus_Thum = new DbusThumbnailer ().instance;
                    dbus_Thum.instand_thumbler (path, "normal");
                }
                preview = pix_scale (normal_thumb (path), 48);
                if (preview == null) {
                    preview = objectpixbuf.icon_from_mediatype (0);
                }
            } else if (get_mime_type (path).has_prefix ("audio/")) {
                album_music = get_album_music (file_name);
                artist_music = get_artist_music (file_name);
                string nameimage = cache_image (info_songs + " " + artist_music);
                if (!FileUtils.test (nameimage, FileTest.EXISTS)) {
                    var audiocover = new AudioCover();
                    audiocover.import (path.get_uri ());
                    preview = audiocover.pixbuf_playlist;
                } else {
                    preview = pix_scale (nameimage, 48);
	            }
	        }
            liststore.append (out iter);
            liststore.set (iter, PlaylistColumns.PLAYING, null, PlaylistColumns.PREVIEW, preview, PlaylistColumns.TITLE,  info_songs, PlaylistColumns.ARTISTTITLE, file_type (path) == 0? Markup.escape_text (info_songs) : "<b>" + Markup.escape_text  (info_songs) + "</b>" + "\n" + Markup.escape_text (artist_music) + " - " + Markup.escape_text (album_music), PlaylistColumns.FILENAME, path.get_uri (), PlaylistColumns.FILESIZE, get_info_size (path.get_uri ()), PlaylistColumns.MEDIATYPE, file_type (path), PlaylistColumns.ALBUMMUSIC, album_music, PlaylistColumns.ARTISTMUSIC, artist_music, PlaylistColumns.PLAYNOW, true, PlaylistColumns.INPUTMODE, 0);
        }
        private uint finish_timer = 0;
        private void update_playlist (uint timeout) {
            if (finish_timer != 0) {
                Source.remove (finish_timer);
            }
            finish_timer = GLib.Timeout.add (timeout, () => {
                item_added ();
                finish_timer = 0;
                return Source.REMOVE;
            });
        }

        public void clear_items () {
            current = 0;
            liststore.clear ();
            NikiApp.settings.set_strv ("last-played-videos", {});
        }

        public string? first_filename () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_first (out iter)){
                string filename, titlename, album, artist;
                liststore.get (iter, PlaylistColumns.FILENAME, out filename, PlaylistColumns.TITLE, out titlename, PlaylistColumns.ALBUMMUSIC, out album, PlaylistColumns.ARTISTMUSIC, out artist);
                NikiApp.settings.set_string ("tittle-playing", titlename);
                NikiApp.settings.set_string ("album-music", album);
                NikiApp.settings.set_string ("artist-music", artist);
                return filename;
            }
            return null;
        }

        public string? first_filesize () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_first (out iter)){
                string filesize;
                liststore.get (iter, PlaylistColumns.FILESIZE, out filesize);
                return filesize;
            }
            return null;
        }

        public int? first_mediatype () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_first (out iter)){
                int mediatype;
                liststore.get (iter, PlaylistColumns.MEDIATYPE, out mediatype);
                return mediatype;
            }
            return 0;
        }

        public bool? first_playnow () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_first (out iter)){
                bool playnow;
                liststore.get (iter, PlaylistColumns.PLAYNOW, out playnow);
                return playnow;
            }
            return false;
        }

        public string? end_filename () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_from_string (out iter, (total - 1).to_string ())){
                string filename, titlename, album, artist;
                liststore.get (iter, PlaylistColumns.FILENAME, out filename, PlaylistColumns.TITLE, out titlename, PlaylistColumns.ALBUMMUSIC, out album, PlaylistColumns.ARTISTMUSIC, out artist);
                NikiApp.settings.set_string ("tittle-playing", titlename);
                NikiApp.settings.set_string ("album-music", album);
                NikiApp.settings.set_string ("artist-music", artist);
                return filename;
            }
            return null;
        }

        public string? end_filesize () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_from_string (out iter, (total - 1).to_string ())){
                string filesize;
                liststore.get (iter, PlaylistColumns.FILESIZE, out filesize);
                return filesize;
            }
            return null;
        }

        public int? end_mediatype () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_from_string (out iter, (total - 1).to_string ())){
                int mediatype;
                liststore.get (iter, PlaylistColumns.MEDIATYPE, out mediatype);
                return mediatype;
            }
            return 0;
        }

        public bool? end_playnow () {
            Gtk.TreeIter iter;
            if (liststore.get_iter_from_string (out iter, (total - 1).to_string ())){
                bool playnow;
                liststore.get (iter, PlaylistColumns.PLAYNOW, out playnow);
                return playnow;
            }
            return false;
        }

        public void set_current (string current_file) {
            total = 0;
            int current_played = 0;
            liststore.foreach ((model, path, iter) => {
                liststore.set (iter, PlaylistColumns.PLAYING, null);
                string filename;
                model.get (iter, PlaylistColumns.FILENAME, out filename);
                if (filename == current_file) {
                    current_played = total;
                }
                total++;
                return false;
            });

            Gtk.TreeIter new_iter;
            liststore.get_iter_from_string (out new_iter, current_played.to_string ());
            liststore.set (new_iter, PlaylistColumns.PLAYING, new ThemedIcon ("media-playback-start-symbolic"));
            current = current_played;
            get_status_list ();
        }
        public bool get_has_previous () {
            return current > 0;
        }
        public bool get_has_next () {
            return total - 1 > current && total > 0;
        }
        public void get_status_list () {
            if (get_has_previous () || NikiApp.settings.get_enum ("repeat-mode") == 1) {
                if (!NikiApp.settings.get_boolean("previous-status")) {
                    NikiApp.settings.set_boolean("previous-status", true);
                }
            } else {
                if (NikiApp.settings.get_boolean("previous-status")) {
                    NikiApp.settings.set_boolean("previous-status", false);
                }
            }
            if (get_has_next () || NikiApp.settings.get_enum ("repeat-mode") == 1) {
                if (!NikiApp.settings.get_boolean("next-status")) {
                    NikiApp.settings.set_boolean("next-status",  true);
                }
            } else {
                if (NikiApp.settings.get_boolean("next-status")) {
                    NikiApp.settings.set_boolean("next-status", false);
                }
            }
        }

        public void save_playlist () {
            var list = new List<string> ();
            liststore.foreach ((model, path, iter) => {
                string filename;
                model.get (iter, PlaylistColumns.FILENAME, out filename);
                list.append (filename);
                return false;
            });
            uint i = 0;
            var videos = new string[list.length ()];
            foreach (var filename in list) {
                videos[i] = filename;
                i++;
            }
            NikiApp.settings.set_strv ("last-played-videos", videos);
        }

        public void restore_playlist () {
            foreach (string restore_last in NikiApp.settings.get_strv ("last-played-videos")) {
                if (!restore_last.has_prefix ("http")) {
                    add_item (File.new_for_uri (restore_last));
                }
            }
        }
    }
}
