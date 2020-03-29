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
    public class CameraTopBar : Gtk.EventBox {
        public Gtk.Button maximize_button;
        private Gtk.Button close_botton;
        private Gtk.Label my_app;
        private bool _hovered = false;
        public bool hovered {
            get {
                return _hovered;
            }
            set {
                _hovered = value;
            }
        }

        construct {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            enter_notify_event.connect ((event) => {
              if (NikiApp.window.is_active) {
                    if (event.window == get_window ()) {
                        hovered = true;
                    }
                }
                return false;
            });
            motion_notify_event.connect (() => {
                if (NikiApp.window.is_active) {
                    hovered = true;
                }
                return false;
            });
            button_press_event.connect (() => {
                hovered = true;
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect (() => {
                hovered = true;
                return false;
            });
            leave_notify_event.connect ((event) => {
              if (NikiApp.window.is_active) {
                    if (event.window == get_window ()) {
                        hovered = false;
                    }
                }
                return false;
            });
            if (!NikiApp.settings.get_boolean ("fullscreen")) {
                NikiApp.settings.set_boolean ("fullscreen", true);
            }
            NikiApp.settings.changed["fullscreen"].connect (() => {
                maximize_button.sensitive = NikiApp.settings.get_boolean ("fullscreen")? true : false;
            });

            maximize_button = new Gtk.Button.from_icon_name ("view-fullscreen-symbolic", Gtk.IconSize.BUTTON);
            maximize_button.get_style_context ().add_class ("button_action");
            maximize_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("maximize", !NikiApp.settings.get_boolean ("maximize"));
            });

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.hexpand = true;
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");

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
                NikiApp.window.main_stack.visible_child_name = "welcome";
		        NikiApp.window.camera_page.cameraplayer.set_null ();
            });

            my_app = new Gtk.Label (null);
            my_app.get_style_context ().add_class ("button_action");
            my_app.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            my_app.ellipsize = Pango.EllipsizeMode.END;
            my_app.use_markup = true;
            my_app.label = StringPot.Niki_Camera;

            main_actionbar.pack_start (close_botton);
            main_actionbar.pack_start (home_button);
            main_actionbar.set_center_widget (my_app);
            main_actionbar.pack_end (maximize_button);

		    var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.get_style_context ().add_class ("topbar");
            grid.margin = grid.row_spacing = grid.column_spacing = grid.margin_top = 0;
            grid.valign = Gtk.Align.CENTER;
            grid.add (main_actionbar);
            grid.show_all ();
            add (grid);
            show_all ();
            NikiApp.settings.changed["maximize"].connect (maximized_button);
            maximized_button ();
        }
        private void maximized_button () {
            ((Gtk.Image) maximize_button.image).icon_name = NikiApp.settings.get_boolean ("maximize")? "view-fullscreen-symbolic" : "view-restore-symbolic";
            maximize_button.tooltip_text = NikiApp.settings.get_boolean ("maximize")? StringPot.Maximize : StringPot.Unmaximize;
        }
    }
}
