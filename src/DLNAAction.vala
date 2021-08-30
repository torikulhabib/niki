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
    public class DLNAAction : Gtk.Revealer {
        public Gtk.Label progress_duration_label;
        private DLNAVolume? dlnavolume;
        private Gtk.Button play_button;
        private Gtk.Button next_button;
        private Gtk.Button previous_button;
        private DLNAVolumeButton? volume_button;
        public ButtonRevealer? stop_revealer;
        public Gtk.Scale scale_range;
        private uint volume_hiding_timer = 0;
        private uint show_timer_id = 0;
        private uint hide_timer_id = 0;

        private bool _volume_bool = false;
        public bool volume_bool {
            get {
                return _volume_bool;
            }
            set {
                _volume_bool = value;
                if (value) {
                    if (volume_hiding_timer != 0) {
                        Source.remove (volume_hiding_timer);
                        volume_hiding_timer = 0;
                    }
                } else {
                    schedule_hide ();
                }
            }
        }

        public bool _playing = false;
        public bool playing {
            get {
                return _playing;
            }
            set {
                _playing = value;
                ((Gtk.Image) play_button.image).icon_name = value? "media-playback-pause-symbolic" : "media-playback-start-symbolic";
                play_button.tooltip_text = value? _("Pause") : _("Play");
            }
        }

        public DLNAAction (WelcomePage welcompage) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            transition_duration = 500;
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            stop_revealer = new ButtonRevealer ("media-playback-stop-symbolic") {
                tooltip_text = _("Stop"),
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 500
            };
            stop_revealer.clicked.connect (() => {
                welcompage.dlnarendercontrol.playback_control ("Stop");
            });

            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON);
            play_button.clicked.connect (() => {
                welcompage.dlnarendercontrol.play ();
            });

            previous_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.previous-symbolic", Gtk.IconSize.BUTTON) {
                tooltip_text = _("Previous")
            };
            previous_button.clicked.connect (() => {
                welcompage.treview.previous_signal ();
            });
            next_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.next-symbolic", Gtk.IconSize.BUTTON) {
                tooltip_text = _("Next")
            };
            next_button.clicked.connect (() => {
                welcompage.dlnarendercontrol.next_media ();
            });
            volume_button = new DLNAVolumeButton ();
            volume_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("dlna-muted", !NikiApp.settings.get_boolean ("dlna-muted"));
            });
            var clear_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.BUTTON) {
                tooltip_text = _("Reload")
            };
            clear_button.clicked.connect (() => {
                welcompage.dlnarendercontrol.clear_selected_renderer_state ();
            });
            dlnavolume = new DLNAVolume ();
            dlnavolume.leave_scale.connect (reveal_volume);
            volume_button.enter_notify_event.connect (() => {
                if (!dlnavolume.child_revealed) {
                    schedule_show ();
                    volume_bool = true;
                }
                return false;
            });

            volume_button.leave_notify_event.connect (() => {
                schedule_hide ();
                volume_bool = false;
                return false;
            });

            scale_range = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01) {
                draw_value = false,
                hexpand = true
            };
            scale_range.get_style_context ().add_class ("dlna_seek_bar");
            scale_range.enter_notify_event.connect (() => {
                return cursor_hand_mode (0);
            });

            scale_range.leave_notify_event.connect (() => {
                return cursor_hand_mode (2);
            });
            scale_range.change_value.connect ((scroll, new_value) => {
                if (scroll == Gtk.ScrollType.JUMP) {
                    uint seeking = (uint)(new_value * 100);
                    welcompage.dlnarendercontrol.on_position_scale_value_changed (seeking);
                }
                return false;
            });
            var grid_scale = new Gtk.Grid () {
                margin = 0,
                row_spacing = 0,
                column_spacing = 0,
                hexpand = true
            };
            grid_scale.get_style_context ().add_class ("dlna_seek_bar");
            grid_scale.add (scale_range);
            progress_duration_label = new Gtk.Label (null);
            progress_duration_label.get_style_context ().add_class ("h3");
            progress_duration_label.get_style_context ().add_class ("label");
            progress_duration_label.selectable = true;
            progress_duration_label.halign = Gtk.Align.START;

            var main_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                margin_bottom = 6
            };
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("ground_dlna");
            main_actionbar.pack_start (previous_button, false, false, 0);
            main_actionbar.pack_start (play_button, false, false, 0);
            main_actionbar.pack_start (stop_revealer, false, false, 0);
            main_actionbar.pack_start (next_button, false, false, 0);
            main_actionbar.pack_start (volume_button, false, false, 0);
            main_actionbar.pack_start (dlnavolume, false, false, 0);
            main_actionbar.pack_start (progress_duration_label, false, false, 0);
            main_actionbar.pack_end (clear_button, false, false, 0);
            main_actionbar.show_all ();

            var grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                margin = 0,
                row_spacing = 0,
                column_spacing = 0,
                margin_top = 0
            };
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.add (grid_scale);
            grid.add (main_actionbar);
            grid.show_all ();
            add (grid);
            show_all ();
        }

        public void schedule_show () {
            if (show_timer_id > 0) {
                return;
            }
            cancel_timer (ref hide_timer_id);
            show_timer_id = Timeout.add (350, () => {
                reveal_volume ();
                show_timer_id = 0;
                return false;
            });
        }

        public void schedule_hide () {
            if (hide_timer_id > 0) {
                return;
            }
            cancel_timer (ref show_timer_id);
            hide_timer_id = Timeout.add (350, () => {
                volume_bool = false;
                hide_timer_id = 0;
                return false;
            });
        }

        private void cancel_timer (ref uint timer_id) {
            if (timer_id > 0) {
                Source.remove (timer_id);
                timer_id = 0;
            }
        }
        public void reveal_volume () {
            if (!dlnavolume.child_revealed) {
                dlnavolume.set_reveal_child (true);
            }
            if (volume_hiding_timer != 0) {
                Source.remove (volume_hiding_timer);
            }
            volume_hiding_timer = GLib.Timeout.add_seconds (1, () => {
                if (volume_bool || dlnavolume.hovering_grabing) {
                    volume_hiding_timer = 0;
                    return false;
                }
                dlnavolume.set_reveal_child (false);
                volume_hiding_timer = 0;
                return Source.REMOVE;
            });
        }
    }
}
