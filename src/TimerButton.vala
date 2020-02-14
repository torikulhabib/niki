namespace niki {
    public class TimerButton : Gtk.Button {
        private Gtk.Label timer_label;
        private Gtk.Revealer label_revealer;
        private Gtk.Image timer_image;

        construct {
            get_style_context ().add_class ("button_action");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            timer_image = new Gtk.Image.from_icon_name ("tools-timer-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            timer_image.valign = Gtk.Align.CENTER;
            timer_label = new Gtk.Label (null);
            timer_label.valign = Gtk.Align.END;
            label_revealer = new Gtk.Revealer ();
            label_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            label_revealer.add (timer_label);

            clicked.connect (() => {
                cameradelay.switch_delay ();
            });
            load_label ();
            var main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.HORIZONTAL;
            main_grid.valign = Gtk.Align.CENTER;
            main_grid.add (timer_image);
            main_grid.add (label_revealer);
            add (main_grid);
            NikiApp.settings.changed["camera-delay"].connect (load_label);
        }
        private void load_label () {
            string text_in = ngettext ("%d Sec", "%d Sec", NikiApp.settings.get_enum ("camera-delay")).printf (NikiApp.settings.get_enum ("camera-delay"));
            switch (NikiApp.settings.get_enum ("camera-delay")) {
                case CameraDelay.DISABLED :
                    timer_image.icon_name = "com.github.torikulhabib.niki.timer-off-symbolic";
                    break;
                case CameraDelay.3SEC :
                    timer_image.icon_name = "com.github.torikulhabib.niki.timer-3-symbolic";
                    break;
                case CameraDelay.5SEC :
                    timer_image.icon_name = "com.github.torikulhabib.niki.timer-5-symbolic";
                    break;
                case CameraDelay.10SEC :
                    timer_image.icon_name = "tools-timer-symbolic";
                    break;
            }

            timer_label.label = text_in;
            tooltip_text = NikiApp.settings.get_enum ("camera-delay") != CameraDelay.DISABLED? StringPot.Timer + text_in : StringPot.Timer_Disabled;
            label_revealer.reveal_child = NikiApp.settings.get_enum ("camera-delay") != CameraDelay.DISABLED? true : false;
        }
    }
}
