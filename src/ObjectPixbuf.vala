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
    public class ObjectPixbuf : Object {
        public Gdk.Pixbuf get_pixbuf_device_info (GUPnP.DeviceInfo info) {
            string udn = info.get_udn ();
            string icon_url = info.get_icon_url (null, 32, 25, 25, true, null, null, null, null);
            Gdk.Pixbuf? return_value = get_pixbuf_from_url (icon_url, udn);
            return return_value;
        }
        public Gdk.Pixbuf? get_pixbuf_from_url (string url, string filename) {
            Gdk.Pixbuf? return_value = null;
            if (!url.has_prefix ("http")) {
                return return_value;
            }

            var session = new Soup.Session.with_options ("user_agent", "Niki/0.9.0");
            var msg = new Soup.Message ("GET", url);
            session.send_message (msg);
            if (msg.status_code == 200) {
                string tmp_file = cache_image (filename);
                var file_stream = FileStream.open (tmp_file, "w");
                file_stream.write (msg.response_body.data, (size_t)msg.response_body.length);
                return_value = pix_file (tmp_file);
                File deleteunuse = File.new_for_path (tmp_file);
                deleteunuse.delete_async.begin ();
                Gdk.Pixbuf pixbuf = align_and_scale_pixbuf (return_value, return_value.get_width (), return_value.get_height ());
                pix_to_file (pixbuf, tmp_file);
            }
            return return_value;
        }

        public Gdk.Pixbuf icon_from_type (string icon_type, int size) {
            Gdk.Pixbuf pixbuf = null;
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
            try {
                if (icon_type == "object.item.videoItem") {
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("video-x-generic", 128, 0), size);
                } else if (icon_type == "object.item.audioItem.musicTrack") {
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("audio-x-generic", 128, 0), size);
                } else if (icon_type == "object.item.imageItem.photo") {
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("image-x-generic", 128, 0), size);
                } else {
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("folder-remote", 128, 0), size);
                }
	        } catch (Error e) {
                GLib.warning (e.message);
	        }
            return pixbuf;
        }
        public Gdk.Pixbuf icon_from_mediatype (int icon_type) {
            Gdk.Pixbuf pixbuf = null;
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
            try {
                switch (icon_type) {
                    case PlayerMode.VIDEO :
                        pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("video-x-generic", 128, 0), 48);
                        break;
                    case PlayerMode.AUDIO :
                        pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("audio-x-generic", 128, 0), 48);
                        break;
                    case PlayerMode.STREAMAUD :
                        pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("audio-x-generic", 128, 0), 48);
                        break;
                    case PlayerMode.STREAMVID :
                        pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("video-x-generic", 128, 0), 48);
                        break;
                }
	        } catch (Error e) {
                GLib.warning (e.message);
	        }
            return pixbuf;
        }
        public Gdk.Pixbuf from_theme_icon (string gicon_name, int resolution, int size) {
            Gdk.Pixbuf pixbuf = null;
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
            try {
                pixbuf = align_and_scale_pixbuf (icon_theme.load_icon (gicon_name, resolution, 0), size);
	        } catch (Error e) {
                GLib.warning (e.message);
	        }
            return pixbuf;
        }
    }
}
