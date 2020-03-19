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
        public int current = 0;
        public int total = 0;
        public Gtk.Menu menu;

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

            menu = new Gtk.Menu ();
            var playing = new Gtk.MenuItem ();
            playing.add (new MenuLabel ("media-playback-start-symbolic", StringPot.Play));
            playing.activate.connect (() => {
                send_iter_to (selected_iter ());
            });
            var from_list = new Gtk.MenuItem ();
            from_list.add (new MenuLabel ("list-remove-symbolic", StringPot.Remove_Playlist));
            from_list.activate.connect (() => {
                remove_iter ();
            });
            var from_device = new Gtk.MenuItem ();
            from_device.add (new MenuLabel ("edit-delete-symbolic", StringPot.Remove_Device));
            from_device.activate.connect (() => {
                create_dialog (selected_iter ());
            });
            var info_details = new Gtk.MenuItem ();
            info_details.add (new MenuLabel ("dialog-information-symbolic", StringPot.Details));
            info_details.activate.connect (() => {
                edit_info ();
            });
            var save_to = new Gtk.MenuItem ();
            save_to.add (new MenuLabel ("drive-harddisk-symbolic", StringPot.Save_MyComputer));
            save_to.activate.connect (() => {
                save_to_computer (selected_iter ());
            });

            var menu_sub = new Gtk.MenuItem ();
            menu_sub.add (new MenuLabel ("go-jump-symbolic", StringPot.Sort_by));

            var title_short = new Gtk.MenuItem ();
            var sub_tit = new MenuLabelRadio ("com.github.torikulhabib.niki.title-symbolic", StringPot.Title);
            title_short.add (sub_tit);
            title_short.activate.connect (() => {
                NikiApp.settings.set_int ("sort-by", 0);
            });
            var artist_short = new Gtk.MenuItem ();
            var sub_art = new MenuLabelRadio ("avatar-default-symbolic", StringPot.Artist);
            artist_short.add (sub_art);
            artist_short.activate.connect (() => {
                NikiApp.settings.set_int ("sort-by", 1);
            });

            var album_short = new Gtk.MenuItem ();
            var sub_alb = new MenuLabelRadio ("media-optical-symbolic", StringPot.Album);
            album_short.add (sub_alb);
            album_short.activate.connect (() => {
                NikiApp.settings.set_int ("sort-by", 2);
            });

            var costum_short = new Gtk.MenuItem ();
            var sub_cus = new MenuLabelRadio ("edit-symbolic", StringPot.Custom);
            costum_short.add (sub_cus);
            costum_short.activate.connect (() => {
                NikiApp.settings.set_int ("sort-by", 3);
            });

            var spart_short = new Gtk.MenuItem ();
            spart_short.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            var ascending_short = new Gtk.MenuItem ();
            var sub_asc = new MenuLabelRadio ("view-sort-descending-symbolic", StringPot.Ascending);
            ascending_short.add (sub_asc);
            ascending_short.activate.connect (() => {
                NikiApp.settings.set_boolean("ascen-descen", true);
            });

            var descending_short = new Gtk.MenuItem ();
            var sub_des = new MenuLabelRadio ("view-sort-ascending-symbolic", StringPot.Descending);
            descending_short.add (sub_des);
            descending_short.activate.connect (() => {
                NikiApp.settings.set_boolean("ascen-descen", false);
            });
            var submenu_menu2 = new Gtk.Menu ();
            submenu_menu2.add (title_short);
            submenu_menu2.add (artist_short);
            submenu_menu2.add (album_short);
            submenu_menu2.add (costum_short);
            submenu_menu2.add (spart_short);
            submenu_menu2.add (ascending_short);
            submenu_menu2.add (descending_short);
            menu_sub.submenu = submenu_menu2;

            menu.append (playing);
            menu.append (menu_sub);
            menu.append (from_list);
            menu.append (from_device);
            menu.append (info_details);
            menu.append (save_to);
            menu.show_all ();

            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    if (NikiApp.settings.get_boolean ("edit-playlist")) {
                        Idle.add (remove_iter);
                    }
                }
                if (event.button == Gdk.BUTTON_SECONDARY && event.type != Gdk.EventType.2BUTTON_PRESS) {
                    sub_tit.radio_but = NikiApp.settings.get_int ("sort-by") == 0;
                    sub_art.radio_but = NikiApp.settings.get_int ("sort-by") == 1;
                    sub_alb.radio_but = NikiApp.settings.get_int ("sort-by") == 2;
                    sub_cus.radio_but = NikiApp.settings.get_int ("sort-by") == 3;
                    sub_asc.radio_but = NikiApp.settings.get_boolean ("ascen-descen");
                    sub_des.radio_but = !NikiApp.settings.get_boolean ("ascen-descen");
                    Gtk.TreeIter iter = selected_iter ();
                    if (!liststore.iter_is_valid (iter)) {
                        return Gdk.EVENT_PROPAGATE;
                    }
                    int input_mode, mediatype;
                    liststore.get (iter, PlaylistColumns.INPUTMODE, out input_mode, PlaylistColumns.MEDIATYPE, out mediatype);
                    if (input_mode == 0) {
                        from_device.show ();
                    } else {
                        from_device.hide ();
                    }
                    if (input_mode == 0 && mediatype == 1) {
                        info_details.show ();
                    } else if (input_mode == 0 && mediatype == 0) {
                        info_details.show ();
                    } else {
                        info_details.hide ();
                    }
                    if (input_mode == 2) {
                        save_to.show ();
                    } else {
                        save_to.hide ();
                    }
                    menu.popup_at_pointer (event);
                }
                return Gdk.EVENT_PROPAGATE;
            });
            show_all ();
            ((Gtk.TreeSortable) liststore).sort_column_changed.connect (()=> {
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
        private bool remove_iter () {
            Gtk.TreeIter iter = selected_iter ();
            if (!liststore.iter_is_valid (iter)) {
                return Gdk.EVENT_PROPAGATE;
            }
            liststore.remove (ref iter);
            update_playlist (50);
            return Gdk.EVENT_PROPAGATE;
        }
        public Gtk.TreeIter selected_iter () {
            Gtk.TreeIter iter;
            get_selection().get_selected(null, out iter);
            return iter;
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
            NikiApp.settings.set_string ("title-playing", titlename);
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

        public void add_dlna (string input_url, string input_title, string input_album, string input_artist, int mediatype, bool playnow, string upnp_class, string size_file) {
            bool exist = false;
            if (mediatype == 4) {
                mediatype = 0;
            }
            string filenamein = Markup.escape_text (input_title);
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
            liststore.set (iter, PlaylistColumns.PLAYING, null, PlaylistColumns.PREVIEW, preview, PlaylistColumns.TITLE, input_title, PlaylistColumns.ARTISTTITLE, mediatype == 2? "<b>" + Markup.escape_text (input_title) + "</b>" + "\n" + Markup.escape_text (input_artist) + " - " + Markup.escape_text (input_album) : Markup.escape_text (input_title), PlaylistColumns.FILENAME, input_url, PlaylistColumns.FILESIZE, size_file, PlaylistColumns.MEDIATYPE, mediatype, PlaylistColumns.ALBUMMUSIC, input_album, PlaylistColumns.ARTISTMUSIC, input_artist, PlaylistColumns.PLAYNOW, playnow, PlaylistColumns.INPUTMODE, 2);
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
                NikiApp.settings.set_string ("title-playing", titlename);
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
                NikiApp.settings.set_string ("title-playing", titlename);
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
    }
}
