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
