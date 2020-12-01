/*
* Copyright (c) {2019} torikulhabib (https://github.com/torikulhabib)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@Gmail.com>
*/

namespace niki {
    public class OtherGrid : Gtk.Grid {
        private Gtk.Grid combox_container;
        private const string [] SETTINGALL = {"Video Flip","Video Render","Color Effects","Audio Render","Audio Visualisation","Visualisation Mode","Visualisation Shader","Visualisation Amount"};
        private const string [] FLIPVIDEO = {"None","Rotate 90 Right","Rotate 180","Rotate 90 Left","Flip_Horizontal","Flip Vertical","Across Upper Left","Across Upper Right","Automatic"};
        private const string [] FLIPVIDEO_ICON = {"system-shutdown-symbolic", "object-rotate-right-symbolic", "com.github.torikulhabib.niki.refresh-180-symbolic", "object-rotate-left-symbolic", "object-flip-horizontal-symbolic", "object-flip-vertical-symbolic", "com.github.torikulhabib.niki.refresh-left-symbolic", "com.github.torikulhabib.niki.refresh-right-symbolic", "com.github.torikulhabib.niki.auto-symbolic"};
        private const string [] VISUALISATION = {"Disabled","Enabled"};
        private const string [] VISUALISATION_ICON = {"system-shutdown-symbolic", "video-x-generic-symbolic"};
        private const string [] VISUALMODE = {"GOOM","GOOM 2","MONOSCOPE"};
        private const string [] SHADER = {"None","Fade","Fade Move UP","Fade Move Down","Fade Move Left","Fade Move Right","Fade Vertical Out","Fade Vertical In"};
        private const string [] VIDEORENDER = {"Auto", "Vaapi", "Ximage", "Xvimage"};
        private const string [] AUDIORENDER = {"Auto","Alsa","Pulse"};
        private const string [] COLOREFFECTS = {"Disabled","Heat","Sepia","X-Ray","X-Pro","Yellow Blue"};

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
                    case "Video Flip":
                        int i = 0;
                        foreach (string flipvideo in FLIPVIDEO) {
                            settingcombox.appending (FLIPVIDEO_ICON [i], flipvideo);
                            i++;
                        }
                        NikiApp.settings.bind ("flip-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case "Video Render":
                        settingcombox.tooltip_text = "Need Restart niki";
                        int i = 0;
                        foreach (string videorender in VIDEORENDER) {
                            settingcombox.appending (i < 1? "com.github.torikulhabib.niki.auto-symbolic" : "com.github.torikulhabib.niki.video-device-symbolic", videorender);
                            i++;
                        }
                        NikiApp.settings.bind ("videorender-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case "Color Effects":
                        int i = 0;
                        foreach (string color_effect in COLOREFFECTS) {
                            settingcombox.appending (COLOREFFECTS [i] == COLOREFFECTS [0]? "system-shutdown-symbolic" : "com.github.torikulhabib.niki.color-symbolic", color_effect);
                            i++;
                        }
                        NikiApp.settings.bind ("coloreffects-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case "Audio Render":
                        settingcombox.tooltip_text = "Need Restart niki";
                        int i = 0;
                        foreach (string audiorender in AUDIORENDER) {
                            settingcombox.appending (i < 1? "com.github.torikulhabib.niki.auto-symbolic" : "audio-card-symbolic", audiorender);
                            i++;
                        }
                        NikiApp.settings.bind ("audiorender-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case "Audio Visualisation":
                        int i = 0;
                        foreach (string visualisation in VISUALISATION) {
                            settingcombox.appending (VISUALISATION_ICON[i], visualisation);
                            i++;
                        }
                        NikiApp.settings.bind ("visualisation-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        break;
                    case "Visualisation Mode":
                        foreach (string visualmode in VISUALMODE) {
                            settingcombox.appending ("emblem-photos-symbolic", visualmode);
                        }
                        NikiApp.settings.bind ("visualmode-options", settingcombox, "active", GLib.SettingsBindFlags.DEFAULT);
                        NikiApp.settings.changed["visualisation-options"].connect (() => {
                            settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0? false : true;
                        });
                        settingcombox.sensitive = NikiApp.settings.get_int ("visualisation-options") == 0? false : true;
                        break;
                    case "Visualisation Shader":
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
                    case "Visualisation Amount":
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
                label.get_style_context ().add_class ("selectedlabel");
                label.ellipsize = Pango.EllipsizeMode.END;
                label.halign = Gtk.Align.START;
                var holder = new Gtk.Grid ();
                holder.orientation = Gtk.Orientation.HORIZONTAL;
                holder.column_homogeneous = true;
                holder.row_spacing = 6;
                holder.add (label);
                if (setingall == "Visualisation Amount") {
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
