namespace niki {
    public class InfoBar : Gtk.Revealer {
        private Gtk.Label notification_label;
        private uint hiding_timer = 0;
        private string _title;
        public string title {
            get {
                return _title;
            }
            construct set {
                if (notification_label != null) {
                    notification_label.label = value;
                }
                _title = value;
            }
        }

        construct {
            margin = 3;
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.START;
            margin_top = 4;
            margin_start = 4;
            margin_end = 4;
            notification_label = new Gtk.Label (null);
            notification_label.ellipsize = Pango.EllipsizeMode.END;

            var notification_box = new Gtk.Grid ();
            notification_box.margin_top = 15;
            notification_box.margin_start = 4;
            notification_box.margin_end = 4;
            notification_box.add (notification_label);

            var notification_frame = new Gtk.EventBox ();
            notification_frame.get_style_context ().add_class ("app-notification");
            notification_frame.add (notification_box);
            add (notification_frame);
        }

        public void send_notification () {
            reveal_child = true;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add_seconds (2, () => {
                reveal_child = false;
                hiding_timer = 0;
                return false;
            });
        }
    }
}
