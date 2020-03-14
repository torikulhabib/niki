namespace niki {
    public class OtherGrid : Gtk.Grid {
        private Gtk.Grid combox_container;
        private const string [] SETTINGALL = { StringPot.Video_Flip, StringPot.Video_Render, StringPot.Color_Effects, StringPot.Audio_Render, StringPot.Audio_Visualisation, StringPot.Visualisation_Mode, StringPot.Visualisation_Shader, StringPot.Visualisation_Amount};
        private const string [] FLIPVIDEO = {StringPot.NNone, StringPot.Rotate_90_Right, StringPot.Rotate_180, StringPot.Rotate_90_Left, StringPot.Flip_Horizontal, StringPot.Flip_Vertical, StringPot.Across_Upper_Left, StringPot.Across_Upper_Right, StringPot.Automatic};
        private const string [] FLIPVIDEO_ICON = {"system-shutdown-symbolic", "object-rotate-right-symbolic", "com.github.torikulhabib.niki.refresh-180-symbolic", "object-rotate-left-symbolic", "object-flip-horizontal-symbolic", "object-flip-vertical-symbolic", "com.github.torikulhabib.niki.refresh-left-symbolic", "com.github.torikulhabib.niki.refresh-right-symbolic", "com.github.torikulhabib.niki.auto-symbolic"};
        private const string [] VISUALISATION = {StringPot.OFF, StringPot.ON};
        private const string [] VISUALISATION_ICON = {"system-shutdown-symbolic", "video-x-generic-symbolic"};
        private const string [] VISUALMODE = {StringPot.Goom, StringPot.Goom2k1, StringPot.Spacescope, StringPot.Spectrascope, StringPot.Synaescope, StringPot.Wavescope, StringPot.Monoscope};
        private const string [] SHADER = {StringPot.NNone, StringPot.Fade, StringPot.Fade_Move_Up, StringPot.Fade_Move_Down, StringPot.Fade_Move_Left, StringPot.Fade_Move_Right, StringPot.Fade_Vertical_Out, StringPot.Fade_Vertical_In};
        private const string [] VIDEORENDER = {"Auto Videosink", "Vaapisink", "Ximagesink", "Xvimagesink"};
        private const string [] AUDIORENDER = {StringPot.Auto_Audiosink, StringPot.Alsasink, StringPot.Pulsesink};
        private const string [] COLOREFFECTS = {StringPot.NNone, StringPot.Heat, StringPot.Sepia, StringPot.Xray, StringPot.Xpro, StringPot.Yellow_Blue};

        construct {
            valign = Gtk.Align.END;
            height_request = 235;
            margin_bottom = 2;
            combox_container = new Gtk.Grid ();
            combox_container.vexpand = true;
            combox_container.row_spacing = 2;
            combox_container.margin_top = 4;

            foreach (string setingall in SETTINGALL) {
                var settingcombox = new ComboxImage ();
                settingcombox.hexpand = true;
                settingcombox.get_style_context ().add_class ("combox");
                var number_entry = new Gtk.SpinButton.with_range (0, 1000000, 1);
                number_entry.get_style_context ().add_class ("spinbut");

                switch (setingall) {
                    case StringPot.Video_Flip:
                        int i = 0;
                        foreach (string flipvideo in FLIPVIDEO) {
                            settingcombox.appending (FLIPVIDEO_ICON [i], flipvideo);
                            i++;
                        }
                        NikiApp.settings.bind ("flip-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case StringPot.Video_Render:
                        settingcombox.tooltip_text = "Need Restart niki";
                        int i = 0;
                        foreach (string videorender in VIDEORENDER) {
                            settingcombox.appending (i < 1? "com.github.torikulhabib.niki.auto-symbolic" : "com.github.torikulhabib.niki.video-device-symbolic", videorender);
                            i++;
                        }
                        NikiApp.settings.bind ("videorender-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case StringPot.Color_Effects:
                        int i = 0;
                        foreach (string color_effect in COLOREFFECTS) {
                            settingcombox.appending (COLOREFFECTS [i] == COLOREFFECTS [0]? "system-shutdown-symbolic" : "com.github.torikulhabib.niki.color-symbolic", color_effect);
                            i++;
                        }
                        NikiApp.settings.bind ("coloreffects-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case StringPot.Audio_Render:
                        settingcombox.tooltip_text = "Need Restart niki";
                        int i = 0;
                        foreach (string audiorender in AUDIORENDER) {
                            settingcombox.appending (i < 1? "com.github.torikulhabib.niki.auto-symbolic" : "audio-card-symbolic", audiorender);
                            i++;
                        }
                        NikiApp.settings.bind ("audiorender-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case StringPot.Audio_Visualisation:
                        int i = 0;
                        foreach (string visualisation in VISUALISATION) {
                            settingcombox.appending (VISUALISATION_ICON[i], visualisation);
                            i++;
                        }
                        NikiApp.settings.bind ("visualisation-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case StringPot.Visualisation_Mode:
                        foreach (string visualmode in VISUALMODE) {
                            settingcombox.appending ("emblem-photos-symbolic", visualmode);
                        }
                        NikiApp.settings.bind ("visualmode-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        NikiApp.settings.changed["visualisation-options"].connect (() => {
                            settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0? false : true;
                        });
                        settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0? false : true;
                        break;
                    case StringPot.Visualisation_Shader:
                        int i = 0;
                        foreach (string shader in SHADER) {
                            settingcombox.appending (i < 1? "system-shutdown-symbolic" : "insert-object-symbolic", shader);
                            i++;
                        }
                        NikiApp.settings.bind ("shader-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        NikiApp.settings.changed["visualisation-options"].connect (() => {
                            settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0 || VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] == VISUALMODE [6] ? false : true;
                        });
                        NikiApp.settings.changed["visualmode-options"].connect (() => {
                            settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0 || VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] == VISUALMODE [6] ? false : true;
                        });
                        settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0 || VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] == VISUALMODE [6] ? false : true;
                        break;
                    case StringPot.Visualisation_Amount:
                        number_entry.hexpand = true;
                        number_entry.value = NikiApp.settings.get_int ("amount-entry");
		                number_entry.value_changed.connect (() => {
			                NikiApp.settings.set_int ("amount-entry", number_entry.get_value_as_int ());
		                });
                        NikiApp.settings.changed["visualisation-options"].connect (() => {
                            number_entry.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0 || VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] == VISUALMODE [6] ? false : true;
                        });
                        NikiApp.settings.changed["visualmode-options"].connect (() => {
                            number_entry.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0 || VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] == VISUALMODE [6] ? false : true;
                        });
                        number_entry.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0 || VISUALMODE [NikiApp.settings.get_int ("visualmode-options")] == VISUALMODE [6] ? false : true;
                        break;
                }
                var label = new Gtk.Label (setingall + " :");
                label.ellipsize = Pango.EllipsizeMode.END;
                label.halign = Gtk.Align.START;
                var holder = new Gtk.Grid ();
                holder.orientation = Gtk.Orientation.HORIZONTAL;
                holder.column_homogeneous = true;
                holder.row_spacing = 6;
                holder.add (label);
                if (setingall == StringPot.Visualisation_Amount) {
                    holder.add (number_entry);
                } else {
                    holder.add (settingcombox);
                }
                combox_container.add (holder);
                combox_container.orientation = Gtk.Orientation.VERTICAL;
            }
            add (combox_container);
            show_all ();
        }
    }
}
