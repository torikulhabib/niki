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

[DBus (name = "org.freedesktop.thumbnails.Thumbnailer1")]
private interface Tumbler : GLib.Object {
    public signal void finished (uint32 handle);
    public abstract uint32 queue (string[] uris, string [] mime_types, string flavor, string scheduler, uint32 dequeue) throws GLib.Error;
}

namespace niki {
    public class DbusThumbnailer : GLib.Object {
        private Tumbler tumbler = null;
        public signal void load_finished ();
        private static DbusThumbnailer _instance = null;
        public static DbusThumbnailer instance {
            get {
                if (_instance == null) {
                    _instance = new DbusThumbnailer ();
                }
                return _instance;
            }
        }
        construct {
            try {
                tumbler = Bus.get_proxy_sync (BusType.SESSION, "org.freedesktop.thumbnails.Thumbnailer1", "/org/freedesktop/thumbnails/Thumbnailer1");
                tumbler.finished.connect ((handle) => {
                    load_finished ();
                });
            } catch (Error e) {
                warning (e.message);
            }
        }

        public void instand_thumbler (File filename, string size){
            Gee.ArrayList<string> uris = new Gee.ArrayList<string> ();
            Gee.ArrayList<string> mimes = new Gee.ArrayList<string> ();
            uris.add (filename.get_uri ());
            mimes.add (get_mime_type (filename));
            try {
                tumbler.queue (uris.to_array (), mimes.to_array (), size, "default", 0);
            } catch (Error e) {
                warning ("Error loading thumbnail for: %s",  e.message);
            }
        }
    }
}
