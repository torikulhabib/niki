namespace Niki {
    public class WelcomeButton : Gtk.Button {
        public string title {get; construct;}
        public string description {get; construct;}
        public string image_text {get; construct;}

        public WelcomeButton (string image_text, string option_text, string description_text) {
            Object (title: option_text, description: description_text, image_text: image_text);
        }

        construct {
            get_style_context ().add_class ("widget_background");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            focus_on_click = false;
            var button_title = new Gtk.Label (title);
            button_title.get_style_context ().add_class ("h3");
            button_title.halign = Gtk.Align.START;
            button_title.valign = Gtk.Align.END;

            var button_description = new Gtk.Label (description);
            button_description.halign = Gtk.Align.START;
            button_description.valign = Gtk.Align.START;
            button_description.set_line_wrap (true);
            button_description.set_line_wrap_mode (Pango.WrapMode.WORD);
            button_description.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            var image_menu = new Gtk.Image ();
            image_menu.set_from_gicon (new ThemedIcon (image_text), Gtk.IconSize.BUTTON);
            image_menu.set_pixel_size (48);
            image_menu.halign = Gtk.Align.CENTER;
            image_menu.valign = Gtk.Align.CENTER;

            var button_grid = new Gtk.Grid ();
            button_grid.column_spacing = 10;
            button_grid.attach (button_title, 1, 0, 1, 1);
            button_grid.attach (button_description, 1, 1, 1, 1);
            button_grid.attach (image_menu, 0, 0, 1, 2);
            add (button_grid);
            enter_notify_event.connect (() => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    get_style_context ().remove_class ("widget_background");
                    get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                }
                return Gdk.EVENT_PROPAGATE;
            });

            leave_notify_event.connect (() => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                    get_style_context ().add_class ("widget_background");
                }
                return Gdk.EVENT_PROPAGATE;
            });
            focus_in_event.connect (() => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    get_style_context ().remove_class ("widget_background");
                    get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                }
                return Gdk.EVENT_PROPAGATE;
            });

            focus_out_event.connect (() => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    get_style_context ().remove_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                    get_style_context ().add_class ("widget_background");
                }
                return Gdk.EVENT_PROPAGATE;
            });
        }
    }
}
