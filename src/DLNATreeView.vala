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
    public class DLNATreeView : Gtk.TreeView {
        private WelcomePage? welcompage;
        public DLNAServer? serverdlna;
        private ObjectPixbuf? objectpixbuf;
        private GUPnP.DeviceInfo device_all;
        private Gtk.TreeStore treestore;
        private Gtk.TreeIter active_iter;
        private Gtk.TreeIter root_device;
        private Gtk.TreeIter selected_iter;
        private Gtk.TreeIter tree_all;
        private bool inseted = false;
        public bool downloaded = false;
        public bool next_uri = false;
        private uint time_out = 0;
        private uint time_outs = 0;
        public signal void reload_device ();

        public DLNATreeView (WelcomePage welcompage) {
            get_style_context ().add_class ("dlnaplaylist");
            this.welcompage = welcompage;
            serverdlna = new DLNAServer();
            objectpixbuf = new ObjectPixbuf ();
            treestore = new Gtk.TreeStore (DlnaTreeColumns.N_COLUMNS, typeof (Gdk.Pixbuf), typeof (string), typeof (GUPnP.DeviceInfo), typeof (GUPnP.ServiceProxy), typeof (string), typeof (int), typeof (string));
            insert_column_with_attributes (-1, "pixbuf", new Gtk.CellRendererPixbuf (), "pixbuf", DlnaTreeColumns.ICON);
            insert_column_with_attributes (-1, "text", new Gtk.CellRendererText (), "text", DlnaTreeColumns.TITLE);
            model = treestore;
            columns_autosize ();
            expand = show_expanders = show_expanders = true;
            can_focus = headers_visible = activate_on_single_click = false;
            NikiApp.settings.set_boolean ("spinner-wait", true);
            row_activated.connect ((path, column) => {
                string id, upnp_class;
                treestore.get_iter (out active_iter, path);
                treestore.get (active_iter, DlnaTreeColumns.ID, out id, DlnaTreeColumns.DEVICEINFO, out device_all, DlnaTreeColumns.UPNPCLASS, out upnp_class);
                if (upnp_class == "object.item.videoItem" || upnp_class == "object.item.audioItem.musicTrack" || upnp_class == "object.item.imageItem.photo") {
                    browse_metadata (id);
                }
            });

            cursor_changed.connect (() => {
                if (!get_selection().get_selected(null, out selected_iter)) {
                    return;
                }
                string id;
                int container;
                treestore.get (selected_iter, DlnaTreeColumns.ID, out id, DlnaTreeColumns.DEVICEINFO, out device_all, DlnaTreeColumns.CONTAINER, out container);
                if (treestore.iter_n_children (selected_iter) < 1 && container > 0) {
                    NikiApp.settings.set_boolean ("spinner-wait", sensitive = false);
                    browse (id);
                }
            });
            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_SECONDARY && event.type != Gdk.EventType.2BUTTON_PRESS) {
                    Idle.add (() => {
                        var menu = new Gtk.Menu ();
                        var playing = new Gtk.MenuItem ();
                        playing.add (new MenuLabel ("media-playback-start-symbolic", "Play"));
                        var next_playing = new Gtk.MenuItem ();
                        next_playing.add (new MenuLabel ("com.github.torikulhabib.niki.next-symbolic", "Play Next"));
                        var save_to = new Gtk.MenuItem ();
                        save_to.add (new MenuLabel ("drive-harddisk-symbolic", "Save to My Computer"));
                        var rescan_device = new Gtk.MenuItem ();
                        rescan_device.add (new MenuLabel ("view-refresh-symbolic", "Rescan"));
                        if (get_selection().get_selected(null, out selected_iter)) {
                            string upnp_class;
                            treestore.get (selected_iter, DlnaTreeColumns.UPNPCLASS, out upnp_class);
                            if (upnp_class == "object.item.videoItem" || upnp_class == "object.item.audioItem.musicTrack" || upnp_class == "object.item.imageItem.photo") {
                                menu.add (playing);
                                if (!welcompage.dlnarendercontrol.get_selected_device ()) {
                                    menu.add (next_playing);
                                }
                                menu.add (save_to);
                            }
                        }
                        menu.add (rescan_device);
                        menu.popup_at_pointer (event);
                        playing.activate.connect (() => {
                            string id;
                            treestore.get (selected_iter, DlnaTreeColumns.ID, out id, DlnaTreeColumns.DEVICEINFO, out device_all);
                            browse_metadata (id);
                            if (!get_selection().get_selected(null, out active_iter)) {
                                return;
                            }
                            get_selection().select_iter (active_iter);
                            menu.hide ();
                        });
                        next_playing.activate.connect (() => {
                            string id;
                            treestore.get (selected_iter, DlnaTreeColumns.ID, out id, DlnaTreeColumns.DEVICEINFO, out device_all);
                            browse_metadata (id);
                            next_uri = true;
                            menu.hide ();
                        });
                        save_to.activate.connect (() => {
                            downloaded = true;
                            string id;
                            treestore.get (selected_iter, DlnaTreeColumns.ID, out id);
                            browse_metadata (id);
                            menu.hide ();
                        });
                        rescan_device.activate.connect (() => {
                            int b = model.iter_n_children (null);
                            for (int i = 0; i < b; i++) {
                                Gtk.TreeIter iter;
                                if (treestore.get_iter_first (out iter)){
                                    treestore.remove (ref iter);
                                }
                            }
                            Timeout.add (500,() => {
                                reload_device ();
                                return false;
                            });
                            menu.hide ();
                        });
                        menu.show_all ();
                        return false;
                    });
                }
                return Gdk.EVENT_PROPAGATE;
            });

            show_all ();
            NikiApp.settings.changed["home-signal"].connect (() => {
                if (time_outs > 0) {
                    Source.remove (time_outs);
                    time_outs = 0;
                }
            });
            serverdlna.browse_metadata_finish.connect (browse_metadata_cb);
            serverdlna.browse_finish.connect ((didl_xml) => {
                NikiApp.settings.set_boolean ("spinner-wait", sensitive = true);
                browse_cb (didl_xml);
            });
        }
        public void next_signal () {
            string id;
            if (!treestore.iter_is_valid (active_iter)) {
                if (!get_selection().get_selected (null, out active_iter)) {
                    return;
                }
            }
            if (model.iter_next (ref active_iter)) {
                get_selection().select_iter (active_iter);
            }
            if (!treestore.iter_is_valid (active_iter)) {
                return;
            }
            treestore.get (active_iter, DlnaTreeColumns.ID, out id, DlnaTreeColumns.DEVICEINFO, out device_all);
            browse_metadata (id);
        }
        public void previous_signal () {
            string id;
            if (!treestore.iter_is_valid (active_iter)) {
                if (!get_selection().get_selected (null, out active_iter)) {
                    return;
                }
            }
            if (model.iter_previous (ref active_iter)) {
                get_selection().select_iter (active_iter);
            }
            if (!treestore.iter_is_valid (active_iter)) {
                return;
            }
            treestore.get (active_iter, DlnaTreeColumns.ID, out id, DlnaTreeColumns.DEVICEINFO, out device_all);
            browse_metadata (id);
        }
        private void append_didl_object (GUPnP.DIDLLiteObject object, GUPnP.DeviceInfo info) {
            string id = object.get_id ();
            string title = object.get_title ();
            string upnp_class = object.get_upnp_class ();

            Gdk.Pixbuf icon = objectpixbuf.icon_from_type (upnp_class, 30);
            if (id == null || title == null) {
                return;
            }
            int child_count = ((GUPnP.DIDLLiteContainer)object).get_child_count ();
            if (!treestore.iter_is_valid (tree_all)) {
                return;
            }
            treestore.set (tree_all, DlnaTreeColumns.ICON, icon, DlnaTreeColumns.TITLE, title, DlnaTreeColumns.ID, id, DlnaTreeColumns.DEVICEINFO, info, DlnaTreeColumns.CONTAINER, child_count, DlnaTreeColumns.UPNPCLASS, upnp_class);
        }

        private void on_didl_object_available (GUPnP.DIDLLiteParser parser, GUPnP.DIDLLiteObject object) {
            if (!get_selection().get_selected(null, out selected_iter)) {
                treestore.append (out tree_all, root_device);
            } else {
                if (inseted) {
                    treestore.append (out tree_all, root_device);
                } else {
                    treestore.append (out tree_all, selected_iter);
                }
            }
            append_didl_object (object, device_all);
            added_media ();
        }
        public void added_media () {
            if (time_out != 0) {
                Source.remove (time_out);
            }
            time_out = GLib.Timeout.add (50, () => {
                inseted = false;
                time_out = 0;
                return false;
            });
        }

        private void browse_cb (string didl_xml) {
            if (didl_xml != null) {
                var parser = new GUPnP.DIDLLiteParser ();
                    parser.object_available.connect (on_didl_object_available);
                try {
                    parser.parse_didl (didl_xml);
	            } catch (Error e) {
                    GLib.warning (e.message);
	            }
            }
        }

        public void browse_metadata_cb (string didl_xml) {
            if (!welcompage.dlnarendercontrol.get_selected_device ()) {
                welcompage.dlnarendercontrol.set_av_transport_uri (didl_xml, next_uri);
            } else {
                GUPnP.DIDLLiteResource resource = null;
                string title = null;
                string preview_uri = null;
                string upnp_class = null;
                string artist = null;
                string get_album = null;
                int mediatype = 0;
                bool playnow = false;
                var parser = new GUPnP.DIDLLiteParser ();
                parser.object_available.connect ((parser, object) => {
                    resource = object.get_compat_resource (protocol_Info (), false);
                    title = object.get_title ();
                    upnp_class = object.get_upnp_class ();
                    get_album = object.get_album ();
                    artist = object.get_artists_xml_string ();
                    Xml.Node* node = object.get_xml_node ();
	                for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
		                if (iter->type == Xml.ElementType.ELEMENT_NODE) {
	                        string? get_content = iter->get_content ();
	                        if (get_content != null) {
	                            if (get_content.has_prefix ("http") && get_content.has_suffix ("png")) {
	                                preview_uri = get_content;
		                        }
	                        }
		                }
	                }
                });
                try {
                    parser.parse_didl (didl_xml);
                } catch (Error err) {
                    critical ("%s", err.message);
                }

                string uri = resource.get_uri ();
                string size_file = int64_to_size (resource.get_size64 ());

                if (uri == null) {
                    return;
                }
                if (title == null) {
                    title = "";
                }
                if (get_album == null) {
                    get_album = "";
                }
                if (artist == null) {
                    artist = "";
                } else {
                    string [] split_start = artist.split ("<upnp:artist>");
                    string [] split_end = split_start[1].split ("</upnp:artist>");
                    artist = split_end [0];
                }
                if (upnp_class == "object.item.videoItem") {
                    mediatype = 0;
                    playnow = true;
                } else if (upnp_class == "object.item.audioItem.musicTrack") {
                    mediatype = 2;
                    playnow = true;
                } else if (upnp_class == "object.item.imageItem.photo") {
                    mediatype = 4;
                    playnow = false;
                } else {
                    mediatype = 0;
                    playnow = true;
                }

                if (!NikiApp.settings.get_boolean ("stream-mode")) {
                    NikiApp.settings.set_boolean ("stream-mode", true);
                }

                if (downloaded) {
                    var download_dialog = new DownloadDialog (uri, title, mediatype);
                    download_dialog.show_all ();
                    downloaded = false;
                    return;
                } else {
                    window.player_page.playlist_widget ().add_dlna (uri, title, get_album, artist, mediatype, playnow, upnp_class, size_file);
		            if (window.main_stack.visible_child_name == "welcome" && welcompage.dlnarendercontrol.get_selected_device ()) {
                        window.player_page.play_first_in_playlist ();
                    }
                    time_outs = GLib.Timeout.add (100, () => {
                        if (NikiApp.settings.get_boolean("home-signal")) {
                            return false;
                        }
                        next_signal ();
                        time_outs = 0;
                        return false;
                    });
                }
            }
        }
        private void browse (string container_id) {
            serverdlna.get_content_directory (device_all);
            serverdlna.browse_async (container_id);
        }

        private void browse_metadata (string id) {
            serverdlna.get_content_directory (device_all);
            serverdlna.browse_metadata_async (id);
        }

        private void append_media_server (GUPnP.DeviceProxy proxy) {
            GUPnP.DeviceInfo info = (GUPnP.DeviceInfo)proxy;
            string friendly_name = info.get_friendly_name ();
            GUPnP.ServiceProxy content_dir = serverdlna.get_content_directory (info);
            Gdk.Pixbuf icon = null;
            string nameimage = cache_image (proxy.get_udn ());
            if (!FileUtils.test (nameimage, FileTest.EXISTS)) {
                icon = align_and_scale_pixbuf (objectpixbuf.get_pixbuf_device_info (info), 30);
            } else {
                try {
                    icon = new Gdk.Pixbuf.from_file_at_scale (nameimage, 30, 30, true);
	            } catch (Error e) {
                    GLib.warning (e.message);
	            }
	        }
            if (friendly_name != null && content_dir != null) {
                inseted = true;
                device_all = info;
                treestore.append (out root_device, null);
                treestore.set (root_device, DlnaTreeColumns.ICON, icon, DlnaTreeColumns.TITLE, friendly_name, DlnaTreeColumns.DEVICEINFO, info, DlnaTreeColumns.SERVICEPROXY, content_dir, DlnaTreeColumns.ID, "0");
                browse ("0");
            }
        }

        public void add_media_server (GUPnP.DeviceProxy proxy) {
            bool exist = false;
            treestore.foreach ((model, path, iter) => {
                GUPnP.DeviceInfo proxys;
                model.get (iter, DlnaTreeColumns.DEVICEINFO, out proxys);
                if (proxy.get_udn () == proxys.get_udn ()) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }
            append_media_server (proxy);
        }

        public void remove_media_server (GUPnP.DeviceProxy proxy) {
            string udn = proxy.get_udn ();
            Gtk.TreeIter iter;
            for (int i = 0; treestore.get_iter_from_string (out iter, i.to_string ()); ++i) {
                if (!treestore.iter_is_valid (iter)) {
                    return;
                }
                GUPnP.DeviceInfo proxys;
                treestore.get (iter, DlnaTreeColumns.DEVICEINFO, out proxys);
                if (udn == proxys.get_udn ()) {
                    treestore.remove (ref iter);
                }
            }
        }
    }
}
