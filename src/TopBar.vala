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

namespace Niki {
    public class TopBar : Gtk.Revealer {
        public Gtk.Button info_option;
        public Gtk.Button maximize_button;
        private Gtk.Button close_botton;
        private Gtk.Revealer menu_revealer;
        private Gtk.Stack stack;
        public ButtonRevealer? blur_button;
        public ButtonRevealer? crop_button;
        public ButtonRevealer? cropfull_button;
        public Gtk.Label label_info;
        public Gtk.Label info_label_full;
        private Gtk.Label my_app;
        private VideoCrop videocrop;
        private PlayerPage playerpage;

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
            this.playerpage = playerpage;
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            transition_duration = 500;
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            enter_notify_event.connect ((event) => {
              if (((Gtk.Window) get_toplevel ()).is_active) {
                    if (event.window == get_window ()) {
                        reveal_control ();
                        hovered = true;
                    }
                }
                return false;
            });
            motion_notify_event.connect (() => {
                if (((Gtk.Window) get_toplevel ()).is_active) {
                    reveal_control ();
                    hovered = true;
                }
                return false;
            });

            leave_notify_event.connect ((event) => {
              if (((Gtk.Window) get_toplevel ()).is_active) {
                    if (event.window == get_window ()) {
                        reveal_control ();
                        hovered = false;
                    }
                }
                return false;
            });
            maximize_button = new Gtk.Button.from_icon_name ("view-fullscreen-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            maximize_button.get_style_context ().add_class ("button_action");
            maximize_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            maximize_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("maximize", !NikiApp.settings.get_boolean ("maximize"));
            });
            NikiApp.settings.changed["fullscreen"].connect (() => {
                maximize_button.sensitive = NikiApp.settings.get_boolean ("fullscreen")? true : false;
                stack_fulscreen ();
            });
            close_botton = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Close")
            };

            close_botton.get_style_context ().add_class ("button_action");
            close_botton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            close_botton.clicked.connect (() => {
                destroy_mode ();
            });
            var home_button = new Gtk.Button.from_icon_name ("go-home-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Home")
            };
            home_button.get_style_context ().add_class ("button_action");
            home_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            home_button.clicked.connect (() => {
                playerpage.home_open ();
            });
            info_option = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            info_option.get_style_context ().add_class ("button_action");
            info_option.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            info_option.clicked.connect (() => {
                NikiApp.settings.set_boolean ("information-button", !NikiApp.settings.get_boolean ("information-button"));
                info_button ();
            });
            blur_button = new ButtonRevealer ("view-paged-symbolic") {
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500,
                tooltip_text = _("Audio Tags")
            };

            blur_button.button.get_style_context ().add_class ("button_action");
            blur_button.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            blur_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("blur-mode", !NikiApp.settings.get_boolean ("blur-mode"));
                blured_button ();
            });
            crop_button = new ButtonRevealer ("image-crop-symbolic") {
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500,
                tooltip_text = _("Video Crop")
            };
            crop_button.button.get_style_context ().add_class ("button_action");
            crop_button.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            crop_button.clicked.connect (dialog_crop);

            var cropfull_button = new Gtk.Button.from_icon_name ("image-crop-symbolic", Gtk.IconSize.LARGE_TOOLBAR) {
                tooltip_text = _("Video Crop"),
                focus_on_click = false,
                margin_top = 4,
                margin_end = 4
            };
            cropfull_button.get_style_context ().add_class ("button_action");
            cropfull_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            cropfull_button.clicked.connect (dialog_crop);
            notify["child-revealed"].connect (() => {
                playerpage.right_bar.reveal_control (false);
                if (!child_revealed) {
                    hovered = child_revealed;
                }
            });
            my_app = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                use_markup = true
            };
            my_app.get_style_context ().add_class ("button_action");
            my_app.get_style_context ().add_class ("h3");
            my_app.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var main_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_top = 4,
                margin_start = 4,
                margin_end = 4,
                hexpand = true
            };
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.pack_start (close_botton, false, false, 0);
            main_actionbar.pack_start (info_option, false, false, 0);
            main_actionbar.pack_start (home_button, false, false, 0);
            main_actionbar.set_center_widget (my_app);
            main_actionbar.pack_end (maximize_button, false, false, 0);
            main_actionbar.pack_end (blur_button, false, false, 0);
            main_actionbar.pack_end (crop_button, false, false, 0);
            main_actionbar.show_all ();

            label_info = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                halign = Gtk.Align.START,
                selectable = true
            };
            label_info.get_style_context ().add_class ("selectedlabel");
            label_info.get_style_context ().add_class ("h3");
            label_info.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            menu_revealer = new Gtk.Revealer () {
                margin_start = 4,
                transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
                transition_duration = 500,
                hexpand = true,
                reveal_child = false
            };
            menu_revealer.add (label_info);

            var grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                margin = 0,
                row_spacing = 0,
                column_spacing = 0,
                margin_top = 0
            };
            grid.get_style_context ().add_class ("topbar");
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.add (main_actionbar);
            grid.add (menu_revealer);
            grid.show_all ();

            info_label_full = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                selectable = true,
                margin_top = 4,
                margin_start = 8
            };
            info_label_full.get_style_context ().add_class ("selectedlabel");
            info_label_full.get_style_context ().add_class ("h2");
            info_label_full.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var info_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true
            };
            info_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            info_actionbar.get_style_context ().add_class ("topbar");
            info_actionbar.pack_start (info_label_full, false, false, 0);
            info_actionbar.pack_end (cropfull_button, false, false, 0);
            info_actionbar.show_all ();

            stack = new Gtk.Stack () {
                homogeneous = false
            };
            stack.add_named (grid, "grid");
            stack.add_named (info_actionbar, "info_actionbar");
            stack.visible_child = grid;
            add (stack);
            show_all ();
            NikiApp.settings.changed["information-button"].connect (() => {
                revealer_menu ();
                info_button ();
            });
            playerpage.right_bar.playlist.item_added.connect (label_my_app);
            playerpage.playback.idle.connect (label_my_app);
            NikiApp.settings.changed["maximize"].connect (maximized_button);
            NikiApp.settings.changed["make-lrc"].connect (reveal_control);
            NikiApp.settings.changed["audio-video"].connect (() => {
                revealer_menu ();
                label_my_app ();
                info_button ();
            });
            label_my_app ();
            info_button ();
            stack_fulscreen ();
            revealer_menu ();
            maximized_button ();
            blured_button ();
            menu_revealer.notify["child-revealed"].connect (() => {
                if (NikiApp.window.main_stack.visible_child_name == "player") {
                    playerpage.right_bar.reveal_control (false);
                }
            });
        }

        private void dialog_crop () {
            if (videocrop == null) {
                videocrop = new VideoCrop (playerpage);
                videocrop.show_all ();
                set_reveal_child (false);
                videocrop.destroy.connect (()=>{
                    videocrop = null;
                });
            }
        }

        private void blured_button () {
            blur_button.change_icon (NikiApp.settings.get_boolean ("blur-mode")? "applications-graphics-symbolic" : "com.github.torikulhabib.niki.color-symbolic");
            blur_button.tooltip_text = NikiApp.settings.get_boolean ("blur-mode")? "Blur" : "Normal";
        }

        private void info_button () {
            ((Gtk.Image) info_option.image).icon_name = !NikiApp.settings.get_boolean ("information-button")? (!NikiApp.settings.get_boolean ("audio-video")? "com.github.torikulhabib.niki.info.title-symbolic" : "avatar-default-symbolic"): "com.github.torikulhabib.niki.info-hide-symbolic";
            info_option.tooltip_text = !NikiApp.settings.get_boolean ("information-button")? _("Show") : _("Hide");
        }

        private void label_my_app () {
            Idle.add (()=> {
                if (NikiApp.settings.get_boolean ("audio-video")) {
                    my_app.label = @"$(playerpage.update_current ()) $(Markup.escape_text (NikiApp.settings.get_string ("title-playing"))) <b> $(_("Artist")) </b> $(Markup.escape_text (NikiApp.settings.get_string ("artist-music"))) <b> $(_("Album")) </b> <i>$(Markup.escape_text (NikiApp.settings.get_string ("album-music")))</i>";
                } else {
                    my_app.label = _("Niki Video");
                }
                return false;
            });
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
            ((Gtk.Image) maximize_button.image).icon_name = NikiApp.settings.get_boolean ("maximize")? "com.github.torikulhabib.niki.maximize-symbolic" : "com.github.torikulhabib.niki.restore-symbolic";
            maximize_button.tooltip_text = NikiApp.settings.get_boolean ("maximize")? _("Maximize") : _("Unmaximize");
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
                if (hovered || NikiApp.settings.get_boolean ("make-lrc")) {
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
