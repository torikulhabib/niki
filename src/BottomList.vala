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
    public class BottomList : Gtk.Grid {
        public SettingsPopover? menu_popover;
        public SeekTimeMusic? seektimemusic;
        private VolumeWiget? volume_widget;
        private Gtk.Button play_but_cen;
        private Gtk.Button next_button_center;
        private Gtk.Button shuffle_button;
        private Gtk.Button previous_button_center;
        private Gtk.Button font_button;
        public ButtonRevealer? subtitle_revealer;
        public VolumeButton? volume_button;
        private RepeatButton? repeat_button;
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

        private bool _playing = false;
        public bool playing {
            get {
                return _playing;
            }
            set {
                _playing = value;
                ((Gtk.Image) play_but_cen.image).icon_name = value? "com.github.torikulhabib.niki.pause-symbolic" : "com.github.torikulhabib.niki.play-symbolic";
                play_but_cen.tooltip_text = value? StringPot.Pause : StringPot.Play;
            }
        }

        public BottomList (PlayerPage playerpage) {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            play_but_cen = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.play-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            play_but_cen.focus_on_click = false;
            play_but_cen.clicked.connect (() => {
                playing = !playing;
            });
            repeat_button = new RepeatButton ();

            shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.BUTTON);
            shuffle_button.focus_on_click = false;
            shuffle_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("shuffle-button", !NikiApp.settings.get_boolean ("shuffle-button"));
                shuffle_icon ();
            });
            font_button = new Gtk.Button.from_icon_name ("font-x-generic-symbolic", Gtk.IconSize.BUTTON);
            font_button.focus_on_click = false;
            font_button.tooltip_text = NikiApp.settings.get_string ("font");
            font_button.clicked.connect (() => {
                font_button.tooltip_text = NikiApp.settings.get_string ("font");
            });

            next_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.next-symbolic", Gtk.IconSize.BUTTON);
            next_button_center.focus_on_click = false;
            next_button_center.tooltip_text = StringPot.Next;
            next_button_center.clicked.connect (() => {
                playerpage.next ();
            });

            previous_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.previous-symbolic", Gtk.IconSize.BUTTON);
            previous_button_center.focus_on_click = false;
            previous_button_center.tooltip_text = StringPot.Previous;
            previous_button_center.clicked.connect (() => {
                playerpage.previous ();
            });

            NikiApp.settings.changed["next-status"].connect (signal_playlist);
            NikiApp.settings.changed["previous-status"].connect (signal_playlist);

            subtitle_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.previous-symbolic");
            subtitle_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            subtitle_revealer.transition_duration = 500;
            subtitle_revealer.clicked.connect (() => {
                NikiApp.settings.set_boolean ("activate-subtitle", !NikiApp.settings.get_boolean ("activate-subtitle"));
            });
            NikiApp.settings.changed["activate-subtitle"].connect (subtitle_button);
            NikiApp.settings.changed["subtitle-available"].connect (() => {
                subtitle_revealer.set_reveal_child (NikiApp.settings.get_boolean ("subtitle-available"));
            });

            seektimemusic = new SeekTimeMusic (playerpage.playback);
            seektimemusic.halign = Gtk.Align.CENTER;
            volume_button = new VolumeButton ();
            volume_button.get_style_context ().add_class ("transbgborder");
            volume_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("status-muted", !NikiApp.settings.get_boolean ("status-muted"));
            });
            volume_widget = new VolumeWiget ();
            volume_widget.get_style_context ().add_class ("dlna_volume");
            volume_widget.scale.get_style_context ().add_class ("dlna_volume");
            volume_button.enter_notify_event.connect (() => {
                if (!volume_widget.child_revealed) {
                    schedule_show ();
                    volume_bool = true;
                }
                return false;
            });

            volume_button.leave_notify_event.connect (() => {
                schedule_hide ();
                return volume_bool = false;
            });

		    var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		    action_box.spacing = 10;
            action_box.halign = Gtk.Align.CENTER;
		    action_box.pack_start (shuffle_button, false, false, 0);
		    action_box.pack_start (previous_button_center, false, false, 0);
		    action_box.pack_start (play_but_cen, false, false, 0);
		    action_box.pack_start (next_button_center, false, false, 0);
		    action_box.pack_start (repeat_button, false, false, 0);

		    var grid_seek = new Gtk.Grid ();
            grid_seek.orientation = Gtk.Orientation.VERTICAL;
            grid_seek.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid_seek.hexpand = true;
            grid_seek.add (seektimemusic);
            grid_seek.add (action_box);

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.hexpand = true;
            main_actionbar.margin_bottom = 5;
            main_actionbar.set_center_widget (grid_seek);
            main_actionbar.pack_start (volume_button);
            main_actionbar.pack_start (volume_widget);
            main_actionbar.pack_end (font_button);

		    var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.HORIZONTAL;
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.hexpand = true;
            grid.add (main_actionbar);
            add (grid);
            volume_widget.leave_scale.connect (reveal_volume);
            playerpage.playback.notify["playing"].connect (signal_playlist);
            NikiApp.settings.changed["lyric-available"].connect (lyric_sensitive);
            NikiApp.settings.changed["player-mode"].connect (mode_change);
            NikiApp.settings.changed["audio-video"].connect (mode_change);
            signal_playlist ();
            lyric_sensitive ();
            shuffle_icon ();
            subtitle_button ();
        }
        private void mode_change () {
            lyric_sensitive ();
        }
        private void lyric_sensitive () {
            font_button.sensitive = NikiApp.settings.get_boolean ("lyric-available");
        }

        private void shuffle_icon () {
            ((Gtk.Image) shuffle_button.image).icon_name = NikiApp.settings.get_boolean ("shuffle-button")? "media-playlist-shuffle-symbolic" : "media-playlist-no-shuffle-symbolic";
        }

        private void signal_playlist () {
            previous_button_center.sensitive = NikiApp.settings.get_boolean ("previous-status")? true : false;
            next_button_center.sensitive = NikiApp.settings.get_boolean ("next-status")? true : false;
        }

        private void subtitle_button () {
            subtitle_revealer.change_icon (NikiApp.settings.get_boolean ("activate-subtitle")? "com.github.torikulhabib.niki.subtitle-on-symbolic" : "com.github.torikulhabib.niki.subtitle-off-symbolic");
            subtitle_revealer.tooltip_text = NikiApp.settings.get_boolean ("activate-subtitle")? StringPot.Subtitles_On : StringPot.Subtitles_Off;
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
            if (!volume_widget.child_revealed) {
                volume_widget.set_reveal_child (true);
            }
            if (volume_hiding_timer != 0) {
                Source.remove (volume_hiding_timer);
            }
            volume_hiding_timer = GLib.Timeout.add_seconds (1, () => {
                if (volume_bool || volume_widget.hovering_grabing) {
                    volume_hiding_timer = 0;
                    return false;
                }
                volume_widget.set_reveal_child (false);
                volume_hiding_timer = 0;
                return Source.REMOVE;
            });
        }
    }
}
