namespace niki {
    public class RepeatButton : Gtk.Button {
        private Gtk.Image repeat_image;
        construct {
            get_style_context ().add_class ("button_action");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            repeat_image = new Gtk.Image.from_icon_name ("tools-timer-symbolic", Gtk.IconSize.BUTTON);
            repeat_image.valign = Gtk.Align.CENTER;
            clicked.connect (() => {
                repeatmode.switch_repeat_mode ();
                repeat_icon ();
            });
            add (repeat_image);
            repeat_icon ();
            NikiApp.settings.changed["repeat-mode"].connect (repeat_icon);
        }
        public void repeat_icon () {
            switch (NikiApp.settings.get_enum ("repeat-mode")) {
                case RepeatMode.ALL :
                    ((Gtk.Image) repeat_image).icon_name = "media-playlist-repeat-symbolic";
                    set_tooltip_text (StringPot.Repeat_All);
                    break;
                case RepeatMode.ONE :
                    ((Gtk.Image) repeat_image).icon_name = "media-playlist-repeat-one-symbolic";
                    set_tooltip_text (StringPot.Repeat_One);
                    break;
                case RepeatMode.OFF :
                    ((Gtk.Image) repeat_image).icon_name = "media-playlist-no-repeat-symbolic";
                    set_tooltip_text (StringPot.Disable_Repeat);
                    break;
            }
        }
    }
}
