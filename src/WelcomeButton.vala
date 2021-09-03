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
            var button_title = new Gtk.Label (title) {
                halign = Gtk.Align.START,
                valign = Gtk.Align.END
            };
            button_title.get_style_context ().add_class ("h3");

            var button_description = new Gtk.Label (description) {
                halign = Gtk.Align.START,
                valign = Gtk.Align.START,
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD
            };
            button_description.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            var image_menu = new Gtk.Image () {
                pixel_size = 48,
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            image_menu.set_from_gicon (new ThemedIcon (image_text), Gtk.IconSize.BUTTON);

            var button_grid = new Gtk.Grid () {
                column_spacing = 10
            };
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
