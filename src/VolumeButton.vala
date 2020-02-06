namespace niki {
    public class VolumeButton : Gtk.Button {
        private Gtk.Image volume_image;

        construct {
            get_style_context ().add_class ("button_action");
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            volume_image = new Gtk.Image.from_icon_name ("audio-volume-high-symbolic", Gtk.IconSize.BUTTON);
            volume_image.valign = Gtk.Align.CENTER;
            margin_top = 2;
            add (volume_image);
            NikiApp.settings.changed["volume-adjust"].connect (() => {
                volume_icon ();
            });
            NikiApp.settings.changed["status-muted"].connect (() => {
                Idle.add (volume_icon);
                volume_mute ();
            });
            volume_mute ();
            volume_icon ();
        }
        public bool volume_icon () {
            if (!NikiApp.settings.get_boolean ("status-muted")) {
                if (NikiApp.settings.get_double ("volume-adjust") > 0.1 && NikiApp.settings.get_double ("volume-adjust") <= 0.35) {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-low-symbolic";
                } else if (NikiApp.settings.get_double ("volume-adjust") > 0.35 && NikiApp.settings.get_double ("volume-adjust") <= 0.75) {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-medium-symbolic";
                } else if (NikiApp.settings.get_double ("volume-adjust") > 0.75){
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-high-symbolic";
                } else {
                    ((Gtk.Image) volume_image).icon_name = "audio-volume-muted-symbolic";
                }
            }
            return false;
        }
        private void volume_mute () {
            ((Gtk.Image) volume_image).icon_name = NikiApp.settings.get_boolean ("status-muted")? "audio-volume-muted-blocking-symbolic" : "audio-volume-high-symbolic";
            volume_image.tooltip_text = NikiApp.settings.get_boolean ("status-muted")? StringPot.Muted : double_to_percent (NikiApp.settings.get_double ("volume-adjust"));
        }
    }
}
