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
    public class CameraRightBar : Gtk.Revealer {
        public Gtk.Button profile_button;
        private Gtk.Button flip_button;
        private Gtk.Button coloreffect_button;
        public Gtk.Button flash_button;
        private Gtk.FlowBox profile_list;
        private Gtk.FlowBox effect_list;
        private Gtk.Popover profile_popover;
        private Gtk.Popover coloreffect_popover;
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
                } else {
                    reveal_control ();
                }
            }
        }

        private EffectColor _selected_effect = null;
        private EffectColor selected_effect {
            get {
                return _selected_effect;
            }
            set {
                if (selected_effect == value) {
                    return;
                }
                _selected_effect = value;
                coloreffect_button.tooltip_text = selected_effect.coloreffects.get_effect ();
            }
        }

        private ProfileCamera _selected_profile = null;
        private ProfileCamera selected_profile {
            get {
                return _selected_profile;
            }
            set {
                if (selected_profile == value) {
                    return;
                }
                _selected_profile = value;
                profile_button.tooltip_text = selected_profile.cameraprofile.get_profile ();
            }
        }

        public CameraRightBar (CameraPage camerapage) {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            transition_duration = 500;
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            enter_notify_event.connect ((event) => {
                if (event.window == get_window ()) {
                    hovered = true;
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
                if (event.window == get_window ()) {
                    hovered = false;
                }
                return false;
            });

            profile_button = new Gtk.Button.from_icon_name ("document-save-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            profile_button.focus_on_click = false;
            profile_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            profile_button.get_style_context ().add_class ("button_action");
            profile_button.clicked.connect (() => {
                profile_popover.visible = !profile_popover.visible;
            });
            var profile_grid = new Gtk.Grid ();
            profile_list = new Gtk.FlowBox ();
            profile_list.child_activated.connect ((item) => {
                selected_profile = item as ProfileCamera;
                NikiApp.settings.set_enum ("camera-profile", (int) item.get_index ());
                camerapage.string_notify (profile_button.tooltip_text);
                profile_popover.hide ();
            });
            profile_grid.add (profile_list);

            profile_popover = new Gtk.Popover (profile_button);
            profile_popover.position = Gtk.PositionType.LEFT;
            profile_popover.add (profile_grid);
            profile_popover.show.connect (() => {
                if (selected_profile != null) {
                    profile_list.select_child (selected_profile);
                    selected_profile.grab_focus ();
                }
            });
            profile_popover.hide.connect (() => {
                reveal_control ();
            });
            foreach (var profile_camera in CameraProfile.get_all ()) {
                var item = new ProfileCamera (profile_camera);
                profile_list.add (item);
            }
            profile_grid.show_all ();

            flip_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.flip-on-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            flip_button.focus_on_click = false;
            flip_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            flip_button.get_style_context ().add_class ("button_action");
            flip_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("mode-flip", !NikiApp.settings.get_boolean ("mode-flip"));
                camerapage.string_notify (flip_button.tooltip_text);
            });
            coloreffect_button = new Gtk.Button.from_icon_name ("applications-graphics-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            coloreffect_button.focus_on_click = false;
            coloreffect_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            coloreffect_button.get_style_context ().add_class ("button_action");
            coloreffect_button.clicked.connect (() => {
                coloreffect_popover.visible = !coloreffect_popover.visible;
            });
            var effect_grid = new Gtk.Grid ();
            effect_list = new Gtk.FlowBox ();
            effect_list.child_activated.connect ((item) => {
                selected_effect = item as EffectColor;
                NikiApp.settings.set_int ("coloreffect-mode", (int) item.get_index ());
                camerapage.string_notify (coloreffect_button.tooltip_text);
                coloreffect_popover.hide ();
            });
            effect_grid.add (effect_list);

            coloreffect_popover = new Gtk.Popover (coloreffect_button);
            coloreffect_popover.position = Gtk.PositionType.LEFT;
            coloreffect_popover.add (effect_grid);
            coloreffect_popover.show.connect (() => {
                if (selected_effect != null) {
                    effect_list.select_child (selected_effect);
                    selected_effect.grab_focus ();
                }
            });
            coloreffect_popover.hide.connect (() => {
                reveal_control ();
            });
            foreach (var effect_color in ColorEffects.get_all ()) {
                var item = new EffectColor (effect_color);
                effect_list.add (item);
            }
            effect_grid.show_all ();
            flash_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.flash-on-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            flash_button.focus_on_click = false;
            flash_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            flash_button.get_style_context ().add_class ("button_action");
            flash_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("flash-camera", !NikiApp.settings.get_boolean ("flash-camera"));
                camerapage.string_notify (flash_button.tooltip_text);
            });
            var content_box = new Gtk.Grid ();
            content_box.get_style_context ().add_class ("playlist");
            content_box.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            content_box.margin = 2;
            content_box.orientation = Gtk.Orientation.VERTICAL;
            content_box.add (profile_button);
            content_box.add (flip_button);
            content_box.add (coloreffect_button);
            content_box.add (flash_button);
            add (content_box);
            show_all ();
            NikiApp.settings.changed["camera-video"].connect (profil_sensitive);
            NikiApp.settings.changed["flash-camera"].connect (flash_on);
            NikiApp.settings.changed["mode-flip"].connect (mode_flip);
            mode_flip ();
            flash_on ();
            profil_sensitive ();
            selected_effect = effect_list.get_child_at_index(NikiApp.settings.get_int ("coloreffect-mode")) as EffectColor;
            selected_profile = profile_list.get_child_at_index(NikiApp.settings.get_enum ("camera-profile")) as ProfileCamera;
        }

        private void profil_sensitive () {
            profile_button.sensitive = NikiApp.settings.get_boolean ("camera-video")? true : false;
        }
        private void mode_flip () {
            ((Gtk.Image) flip_button.image).icon_name = NikiApp.settings.get_boolean ("mode-flip")? "com.github.torikulhabib.niki.flip-off-symbolic" : "com.github.torikulhabib.niki.flip-on-symbolic";
            flip_button.tooltip_text = NikiApp.settings.get_boolean ("mode-flip")? StringPot.Flip_Off : StringPot.Flip_On;
        }

        private void flash_on () {
            ((Gtk.Image) flash_button.image).icon_name = NikiApp.settings.get_boolean ("flash-camera")? "com.github.torikulhabib.niki.flash-off-symbolic" : "com.github.torikulhabib.niki.flash-on-symbolic";
            flash_button.tooltip_text = NikiApp.settings.get_boolean ("flash-camera")? StringPot.Flash_Off : StringPot.Flash_On;
        }

        public void reveal_control () {
            set_reveal_child (true);
            margin_top = 120;
            margin_bottom = 120;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }

            hiding_timer = GLib.Timeout.add_seconds (2, () => {
                if (hovered || profile_popover.visible || coloreffect_popover.visible) {
                    hiding_timer = 0;
                    return false;
                }
                set_reveal_child (false);
                hiding_timer = 0;
                return false;
            });
        }
    }
}
