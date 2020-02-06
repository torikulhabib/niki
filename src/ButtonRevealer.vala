namespace niki {
    public class ButtonRevealer : Gtk.Revealer {
        public Gtk.Button revealer_button;
        public signal void clicked ();

        public ButtonRevealer (string image) {
            revealer_button = new Gtk.Button.from_icon_name (image, Gtk.IconSize.BUTTON);
            revealer_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            revealer_button.clicked.connect (() => {
                clicked ();
            });
            add (revealer_button);
            change_icon (image);
        }
        public void change_icon (string change) {
            ((Gtk.Image) revealer_button.image).icon_name = change;
        }
    }
}
