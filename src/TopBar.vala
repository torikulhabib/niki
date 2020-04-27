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
    public class TopBar : Gtk.Revealer {
        public signal void button_home ();
        public Gtk.Button info_option;
        public Gtk.Button maximize_button;
        private Gtk.Button close_botton;
        private Gtk.Revealer menu_revealer;
        private Gtk.Stack stack;
        public ButtonRevealer? blur_button;
        public ButtonRevealer? crop_button;
        public Gtk.Label label_info;
        public Gtk.Label info_label_full;
        private Gtk.Label my_app;

        private uint hiding_timer = 0;
        private bool _hovered = false;
        public bool hovered {
            get {
                return _hovered;
            }
            set {
                _hovered = value;
                if (value) {
                    if (hiding_timer != 0) {
                        Source.remove (hiding_timer);
                        hiding_timer = 0;
                    }
                }
            }
        }

        public TopBar (PlayerPage playerpage) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            transition_duration = 500;
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            enter_notify_event.connect ((event) => {
              if (NikiApp.window.is_active) {
                    if (event.window == get_window ()) {
                        reveal_control ();
                        hovered = true;
                    }
                }
                return false;
            });
            motion_notify_event.connect (() => {
                if (NikiApp.window.is_active) {
                    reveal_control ();
                    hovered = true;
                }
                return false;
            });

            leave_notify_event.connect ((event) => {
              if (NikiApp.window.is_active) {
                    if (event.window == get_window ()) {
                        reveal_control ();
                        hovered = false;
                    }
                }
                return false;
            });
            if (!NikiApp.settings.get_boolean ("fullscreen")) {
                NikiApp.settings.set_boolean ("fullscreen", true);
            }
            maximize_button = new Gtk.Button.from_icon_name ("view-fullscreen-symbolic", Gtk.IconSize.BUTTON);
            maximize_button.get_style_context ().add_class ("button_action");
            maximize_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("maximize", !NikiApp.settings.get_boolean ("maximize"));
            });
            NikiApp.settings.changed["fullscreen"].connect (() => {
                maximize_button.sensitive = NikiApp.settings.get_boolean ("fullscreen")? true : false;
                stack_fulscreen ();
            });
            close_botton = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
            close_botton.tooltip_text = StringPot.Close;
            close_botton.get_style_context ().add_class ("button_action");
            close_botton.clicked.connect (() => {
                destroy_mode ();
            });

            var home_button = new Gtk.Button.from_icon_name ("go-home-symbolic", Gtk.IconSize.BUTTON);
            home_button.get_style_context ().add_class ("button_action");
            home_button.tooltip_text = StringPot.Home;
            home_button.clicked.connect (() => {
                button_home ();
            });
            info_option = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.BUTTON);
            info_option.get_style_context ().add_class ("button_action");
            info_option.clicked.connect (() => {
                NikiApp.settings.set_boolean ("information-button", !NikiApp.settings.get_boolean ("information-button"));
                info_button ();
            });
            blur_button = new ButtonRevealer ("view-paged-symbolic");
            blur_button.revealer_button.get_style_context ().add_class ("button_action");
            blur_button.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            blur_button.transition_duration = 500;
            blur_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("blur-mode", !NikiApp.settings.get_boolean ("blur-mode"));
                blured_button ();
            });
            crop_button = new ButtonRevealer ("image-crop-symbolic");
            crop_button.revealer_button.get_style_context ().add_class ("button_action");
            crop_button.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            crop_button.transition_duration = 500;
            crop_button.clicked.connect (() => {
                var videocrop = new VideoCrop (playerpage);
                videocrop.show_all ();
                set_reveal_child (false);
            });
            notify["child-revealed"].connect (() => {
                playerpage.right_bar.reveal_control (false);
                if (!child_revealed) {
                    hovered = child_revealed;
                }
            });
            my_app = new Gtk.Label (null);
            my_app.get_style_context ().add_class ("button_action");
            my_app.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            my_app.ellipsize = Pango.EllipsizeMode.END;
            my_app.use_markup = true;

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.hexpand = true;
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.pack_start (close_botton);
            main_actionbar.pack_start (info_option);
            main_actionbar.pack_start (home_button);
            main_actionbar.set_center_widget (my_app);
            main_actionbar.pack_end (maximize_button);
            main_actionbar.pack_end (blur_button);
            main_actionbar.pack_end (crop_button);
            main_actionbar.show_all ();

            label_info = new Gtk.Label (null);
            label_info.get_style_context ().add_class ("selectedlabel");
            label_info.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            label_info.ellipsize = Pango.EllipsizeMode.END;
            label_info.halign = Gtk.Align.START;
            label_info.selectable = true;

            menu_revealer = new Gtk.Revealer ();
            menu_revealer.add (label_info);
            menu_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            menu_revealer.transition_duration = 500;
            menu_revealer.hexpand = true;
            menu_revealer.reveal_child = false;
            menu_revealer.notify["child-revealed"].connect (() => {
                playerpage.right_bar.reveal_control (false);
            });
		    var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.get_style_context ().add_class ("topbar");
            grid.margin = grid.row_spacing = grid.column_spacing = grid.margin_top = 0;
            grid.add (main_actionbar);
            grid.add (menu_revealer);
            grid.show_all ();

            info_label_full = new Gtk.Label (null);
            info_label_full.get_style_context ().add_class ("selectedlabel");
            info_label_full.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            info_label_full.ellipsize = Pango.EllipsizeMode.END;
            info_label_full.selectable = true;
            var info_actionbar = new Gtk.ActionBar ();
            info_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            info_actionbar.hexpand = true;
            info_actionbar.get_style_context ().add_class ("info_topbar");
            info_actionbar.pack_start (info_label_full);
            info_actionbar.show_all ();

            stack = new Gtk.Stack ();
            stack.add_named (grid, "grid");
            stack.add_named (info_actionbar, "info_actionbar");
            stack.visible_child = grid;
            stack.homogeneous = false;
            add (stack);
            show_all ();
            NikiApp.settings.changed["information-button"].connect (revealer_menu);
            NikiApp.settings.changed["title-playing"].connect (label_my_app);
            NikiApp.settings.changed["artist-music"].connect (label_my_app);
            NikiApp.settings.changed["album-music"].connect (label_my_app);
            NikiApp.settings.changed["maximize"].connect (maximized_button);
            NikiApp.settings.changed["audio-video"].connect (() => {
                revealer_menu ();
                label_my_app ();
            });
            label_my_app ();
            blured_button ();
            info_button ();
            stack_fulscreen ();
            revealer_menu ();
            maximized_button ();
        }
        private void blured_button () {
            blur_button.change_icon (NikiApp.settings.get_boolean ("blur-mode")? "applications-graphics-symbolic" : "com.github.torikulhabib.niki.color-symbolic");
            blur_button.tooltip_text = NikiApp.settings.get_boolean ("blur-mode")? "Blur" : "Normal";
        }
        private void info_button () {
            ((Gtk.Image) info_option.image).icon_name = !NikiApp.settings.get_boolean ("information-button")? "dialog-information-symbolic" : "com.github.torikulhabib.niki.info-hide-symbolic";
            info_option.tooltip_text = !NikiApp.settings.get_boolean ("information-button")? StringPot.Show : StringPot.Hide;
        }

        private void label_my_app () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                my_app.label = @"$(Markup.escape_text (NikiApp.settings.get_string ("title-playing"))) <b> $(StringPot.Artist) </b> $(Markup.escape_text (NikiApp.settings.get_string ("artist-music"))) <b> $(StringPot.Album) </b> <i>$(Markup.escape_text (NikiApp.settings.get_string ("album-music")))</i>";
            } else {
                my_app.label = StringPot.Niki_Video;
            }
        }
        private void stack_fulscreen () {
            stack.visible_child_name = !NikiApp.settings.get_boolean ("fullscreen") && !NikiApp.settings.get_boolean ("audio-video")? "info_actionbar" : "grid";
        }
        private void revealer_menu () {
            blur_button.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            crop_button.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            menu_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video") && NikiApp.settings.get_boolean ("information-button")? true : false);
        }
        private void maximized_button () {
            ((Gtk.Image) maximize_button.image).icon_name = NikiApp.settings.get_boolean ("maximize")? "view-fullscreen-symbolic" : "view-restore-symbolic";
            maximize_button.tooltip_text = NikiApp.settings.get_boolean ("maximize")? StringPot.Maximize : StringPot.Unmaximize;
        }

        public void reveal_control () {
            if (!child_revealed) {
                set_reveal_child (true);
            }
            label_info.margin_start = 5;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }

            hiding_timer = GLib.Timeout.add_seconds (3, () => {
                if (hovered) {
                    hiding_timer = 0;
                    return false;
                }
                set_reveal_child (false);
                hiding_timer = 0;
                return Source.REMOVE;
            });
        }
    }
}
