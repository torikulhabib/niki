[DBus (name = "org.freedesktop.thumbnails.Thumbnailer1")]
private interface Tumbler : GLib.Object {
    public abstract async uint Queue (string [] uris, string [] mime_types, string flavor, string sheduler, uint handle_to_dequeue) throws GLib.IOError, GLib.DBusError;
}

namespace niki {
    public class DbusThumbnailer : GLib.Object {
        private Tumbler tumbler;

        construct {
            try {
                tumbler = Bus.get_proxy_sync (BusType.SESSION, "org.freedesktop.thumbnails.Thumbnailer1", "/org/freedesktop/thumbnails/Thumbnailer1");
            } catch (Error e) {
                warning (e.message);
            }
        }

        public void Instand (Gee.ArrayList<string> uris, Gee.ArrayList<string> mimes, string size){
            tumbler.Queue.begin (uris.to_array (), mimes.to_array (), size, "default", 0);
        }
    }
}
