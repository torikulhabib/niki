namespace niki {
    public class Welcome : Gtk.Grid {
        public signal void activated (int index);
        protected new GLib.List<Gtk.Button> children = new GLib.List<Gtk.Button> ();
        protected Gtk.Grid options;

        construct {
            get_style_context ().add_class ("widget_background");
            options = new Gtk.Grid ();
            options.orientation = Gtk.Orientation.VERTICAL;
            options.row_spacing = 10;
            options.halign = Gtk.Align.CENTER;

            var content = new Gtk.Grid ();
            content.expand = true;
            content.margin = 10;
            content.orientation = Gtk.Orientation.VERTICAL;
            content.valign = Gtk.Align.CENTER;
            content.add (options);
            halign = Gtk.Align.CENTER;
            vexpand = false;
            add (content);
        }
        public void remove_item (uint index) {
            if (index < children.length () && children.nth_data (index) is Gtk.Widget) {
                var item = children.nth_data (index);
                item.destroy ();
                children.remove (item);
            }
        }
        public uint get_item () {
            return children.length ();
        }
        public int append (string icon_name, string option_text, string description_text) {
            var button = new WelcomeButton (icon_name, option_text, description_text);
            children.append (button);
            options.add (button);
            button.clicked.connect (() => {
                int index = this.children.index (button);
                activated (index);
            });
            return this.children.index (button);
        }

        public WelcomeButton? get_button_from_index (int index) {
            if (index >= 0 && index < children.length ()) {
                return children.nth_data (index) as WelcomeButton;
            }
            return null;
        }
    }
}
