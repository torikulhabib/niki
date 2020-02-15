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
    public class BottomBar : Gtk.Revealer {
        private Gtk.Button menu_settings;
        public OtherGrid? othergrid;
        public SettingsPopover? menu_popover;
        private EqualizerGrid? equalizer_grid;
        private VideoGrid? video_grid;
        public SeekBar? seekbar_widget;
        private TimeVideo? time_video;
        private TimeMusic? time_music;
        private VolumeWiget? volume_widget;
        public Gtk.Button play_button;
        private Gtk.Button play_button_center;
        private Gtk.Revealer action_box_revealer;
        private Gtk.Revealer box_action_revealer;
        private Gtk.Revealer box_setting_list_revealer;
        public ButtonRevealer previous_revealer;
        public ButtonRevealer next_revealer;
        public ButtonRevealer subtitle_revealer;
        private ButtonRevealer playlist_revealer;
        private Gtk.Button fullscreen_button;
        private Gtk.Button next_button_center;
        public VolumeButton volume_button;
        private Gtk.Button font_button;
        private Gtk.Button previous_button_center;
        public ButtonRevealer stop_revealer;
        private ButtonRevealer liric_revealer;
        private Gtk.Revealer font_button_revealer;
        private Gtk.Revealer no_plylist_repeat_revealer;
        private RepeatButton repeat_button;
        private RepeatButton no_plylist_repeat;
        private Gtk.Button shuffle_button;
        private Gtk.Button setting_niki;
        private Gtk.Button settings_prev_button;
        private Gtk.Button settings_next_button;
        private Gtk.Stack setting_stack;
        private uint hiding_timer = 0;
        private uint volume_hiding_timer = 0;
        private uint show_timer_id = 0;
        private uint hide_timer_id = 0;
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
                ((Gtk.Image) play_button.image).icon_name = value? "media-playback-pause-symbolic" : "media-playback-start-symbolic";
                ((Gtk.Image) play_button_center.image).icon_name = value? "com.github.torikulhabib.niki.pause-symbolic" : "com.github.torikulhabib.niki.play-symbolic";
                play_button.tooltip_text = value? StringPot.Pause : StringPot.Play;
                play_button_center.tooltip_text = value? StringPot.Pause : StringPot.Play;
            }
        }

        public BottomBar (PlayerPage playerpage) {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE;
            transition_duration = 500;
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;
            get_style_context ().add_class ("ground_action_button");

            enter_notify_event.connect ((event) => {
                if (window.is_active) {
                    if (event.window == get_window ()) {
                        reveal_control ();
                        hovered = true;
                    }
                }
                return false;
            });

            motion_notify_event.connect (() => {
                if (window.is_active) {
                    reveal_control ();
                    hovered = true;
                }
                return false;
            });

            leave_notify_event.connect ((event) => {
                if (window.is_active) {
                    if (event.window == get_window ()) {
                        hovered = false;
                    }
                }
                return false;
            });

            stop_revealer = new ButtonRevealer ("media-playback-stop-symbolic");
            stop_revealer.revealer_button.get_style_context ().add_class ("button_action");
            stop_revealer.revealer_button.tooltip_text = StringPot.Stop;
            stop_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            stop_revealer.transition_duration = 500;

            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON);
            play_button.get_style_context ().add_class ("button_action");
            play_button.clicked.connect (() => {
                playing = !playing;
            });

            play_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.play-symbolic", Gtk.IconSize.BUTTON);
            ((Gtk.Image) play_button_center.image).pixel_size = NikiApp.settings.get_boolean ("audio-video")? 48 : 16;
            play_button_center.get_style_context ().add_class ("button_action");
            play_button_center.clicked.connect (() => {
                playing = !playing;
            });
            stop_revealer.clicked.connect (() => {
                playerpage.playback.pipeline.set_state (Gst.State.NULL);
                playing = false;
                playerpage.playback.progress = 0.0;
                stop_revealer.set_reveal_child (false);
            });
            repeat_button = new RepeatButton ();
            no_plylist_repeat = new RepeatButton ();
            no_plylist_repeat_revealer = new Gtk.Revealer ();
            no_plylist_repeat_revealer.add (no_plylist_repeat);
            no_plylist_repeat_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            no_plylist_repeat_revealer.transition_duration = 100;

            shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.BUTTON);
            shuffle_button.get_style_context ().add_class ("button_action");
            shuffle_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("shuffle-button", !NikiApp.settings.get_boolean ("shuffle-button"));
                shuffle_icon ();
            });

            playlist_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.playlist-symbolic");
            playlist_revealer.revealer_button.get_style_context ().add_class ("button_action");
            playlist_revealer.tooltip_text = StringPot.Playlist;
            playlist_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            playlist_revealer.transition_duration = 500;
            playlist_revealer.clicked.connect (() => {
                playerpage.right_bar.reveal_control ();
            });

            font_button = new Gtk.Button.from_icon_name ("font-x-generic-symbolic", Gtk.IconSize.BUTTON);
            font_button.get_style_context ().add_class ("button_action");
            font_button.tooltip_text = NikiApp.settings.get_string ("font");
            font_button.clicked.connect (() => {
                menu_popover.font_button ();
                font_button.tooltip_text = NikiApp.settings.get_string ("font");
            });
            font_button_revealer = new Gtk.Revealer ();
            font_button_revealer.add (font_button);
            font_button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            font_button_revealer.transition_duration = 100;

            menu_settings = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);
            menu_settings.get_style_context ().add_class ("button_action");
            menu_settings.tooltip_text = StringPot.Settings;
            menu_settings.clicked.connect (() => {
                menu_popover.show_all ();
            });

            menu_popover = new SettingsPopover (playerpage);
            menu_popover.relative_to = menu_settings;
            menu_popover.closed.connect (reveal_control);

            next_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.next-symbolic", Gtk.IconSize.BUTTON);
            next_button_center.tooltip_text = StringPot.Next;
            next_button_center.get_style_context ().add_class ("button_action");
            next_button_center.clicked.connect (() => {
                playerpage.next ();
            });

            next_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.next-symbolic");
            next_revealer.revealer_button.get_style_context ().add_class ("button_action");
            next_revealer.tooltip_text = StringPot.Next;
            next_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            next_revealer.transition_duration = 500;
            next_revealer.clicked.connect (() => {
                playerpage.next ();
            });

            previous_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.previous-symbolic", Gtk.IconSize.BUTTON);
            previous_button_center.tooltip_text = StringPot.Previous;
            previous_button_center.get_style_context ().add_class ("button_action");
            previous_button_center.clicked.connect (() => {
                playerpage.previous ();
            });

            previous_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.previous-symbolic");
            previous_revealer.revealer_button.get_style_context ().add_class ("button_action");
            previous_revealer.tooltip_text = StringPot.Previous;
            previous_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            previous_revealer.transition_duration = 500;
            previous_revealer.clicked.connect (() => {
                playerpage.previous ();
            });
            NikiApp.settings.changed["next-status"].connect (signal_playlist);
            NikiApp.settings.changed["previous-status"].connect (signal_playlist);

            subtitle_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.previous-symbolic");
            subtitle_revealer.revealer_button.get_style_context ().add_class ("button_action");
            subtitle_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            subtitle_revealer.transition_duration = 500;
            subtitle_revealer.clicked.connect (() => {
                NikiApp.settings.set_boolean ("activate-subtittle", !NikiApp.settings.get_boolean ("activate-subtittle"));
            });
            NikiApp.settings.changed["activate-subtittle"].connect (subtittle_button);
            NikiApp.settings.changed["subtitle-available"].connect (() => {
                subtitle_revealer.set_reveal_child (NikiApp.settings.get_boolean ("subtitle-available"));
            });

            fullscreen_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.fullscreen-symbolic", Gtk.IconSize.BUTTON);
            fullscreen_button.get_style_context ().add_class ("button_action");
            fullscreen_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
            });

            liric_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.liric-off-symbolic");
            liric_revealer.revealer_button.get_style_context ().add_class ("button_action");
            liric_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            liric_revealer.transition_duration = 500;
            liric_revealer.clicked.connect ( () => {
                NikiApp.settings.set_boolean ("liric-button", !NikiApp.settings.get_boolean ("liric-button"));
            });

            video_grid = new VideoGrid (playerpage);
            video_grid.init ();
            equalizer_grid = new EqualizerGrid (playerpage);
            equalizer_grid.init ();

            setting_niki = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.equalizer-on-symbolic", Gtk.IconSize.BUTTON);
            setting_niki.get_style_context ().add_class ("button_action");
            setting_niki.clicked.connect (() => {
                NikiApp.settings.set_boolean ("settings-button", !NikiApp.settings.get_boolean ("settings-button"));
            });

            seekbar_widget = new SeekBar (playerpage);
            time_video = new TimeVideo (playerpage.playback);
            time_music = new TimeMusic (playerpage.playback);

            volume_button = new VolumeButton ();
            volume_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("status-muted", !NikiApp.settings.get_boolean ("status-muted"));
            });
            volume_widget = new VolumeWiget ();
            volume_button.enter_notify_event.connect (() => {
                if (!volume_widget.child_revealed) {
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
            settings_prev_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.equalizer-on-symbolic", Gtk.IconSize.BUTTON);
            settings_prev_button.get_style_context ().add_class ("button_action");

            settings_next_button = new Gtk.Button.from_icon_name ("video-display-symbolic", Gtk.IconSize.BUTTON);
            settings_next_button.get_style_context ().add_class ("button_action");
            othergrid = new OtherGrid ();

            setting_stack = new Gtk.Stack ();
            setting_stack.add_named (equalizer_grid, "equalizer_grid");
            setting_stack.add_named (video_grid, "video_grid");
            setting_stack.add_named (othergrid, "other_grid");

            settings_next_button.clicked.connect (() => {
                settingsmode.switch_next_settings_mode ();
                settings_icon ();
            });
            settings_prev_button.clicked.connect (() => {
                settingsmode.switch_prev_settings_mode ();
                settings_icon ();
            });

            var setting_actionbar = new Gtk.ActionBar ();
            setting_actionbar.hexpand = true;
            setting_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            setting_actionbar.get_style_context ().add_class ("ground_action_button");
            setting_actionbar.set_center_widget (setting_stack);
            setting_actionbar.pack_start (settings_prev_button);
            setting_actionbar.pack_end (settings_next_button);
            setting_actionbar.show_all ();

            var settings_revealer = new Gtk.Revealer ();
            settings_revealer.add (setting_actionbar);
            settings_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
            settings_revealer.transition_duration = 500;
            settings_revealer.set_reveal_child (NikiApp.settings.get_boolean ("settings-button"));
            NikiApp.settings.changed["settings-button"].connect (() => {
                settings_revealer.set_reveal_child (NikiApp.settings.get_boolean ("settings-button"));
            });

		    var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		    box_action.pack_start (previous_revealer, false, false, 0);
		    box_action.pack_start (play_button, false, false, 0);
		    box_action.pack_start (stop_revealer, false, false, 0);
		    box_action.pack_start (next_revealer, false, false, 0);
            box_action_revealer = new Gtk.Revealer ();
            box_action_revealer.add (box_action);
            box_action_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            box_action_revealer.transition_duration = 50;

		    var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		    action_box.pack_start (shuffle_button, false, false, 0);
		    action_box.pack_start (previous_button_center, false, false, 0);
		    action_box.pack_start (play_button_center, false, false, 0);
		    action_box.pack_start (next_button_center, false, false, 0);
		    action_box.pack_start (repeat_button, false, false, 0);
            action_box_revealer = new Gtk.Revealer ();
            action_box_revealer.add (action_box);
            action_box_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            action_box_revealer.transition_duration = 50;

		    var box_setting_list = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		    box_setting_list.pack_start (subtitle_revealer, false, false, 0);
		    box_setting_list.pack_start (menu_settings, false, false, 0);
		    box_setting_list.pack_start (fullscreen_button, false, false, 0);
            box_setting_list_revealer = new Gtk.Revealer ();
            box_setting_list_revealer.add (box_setting_list);
            box_setting_list_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
            box_setting_list_revealer.transition_duration = 50;

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("ground_action_button");
            main_actionbar.hexpand = true;
            main_actionbar.margin_bottom = 8;
            main_actionbar.set_center_widget (action_box_revealer);
            main_actionbar.pack_start (box_action_revealer);
            main_actionbar.pack_start (volume_button);
            main_actionbar.pack_start (volume_widget);
            main_actionbar.pack_start (liric_revealer);
            main_actionbar.pack_start (time_video);
            main_actionbar.pack_end (box_setting_list_revealer);
            main_actionbar.pack_end (playlist_revealer);
            main_actionbar.pack_end (font_button_revealer);
            main_actionbar.pack_end (setting_niki);
            main_actionbar.pack_end (no_plylist_repeat_revealer);
            main_actionbar.show_all ();

		    var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.get_style_context ().add_class ("bottombar");
            grid.margin = grid.row_spacing = grid.column_spacing = grid.margin_top = 0;
            grid.add (seekbar_widget);
            grid.add (time_music);
            grid.add (main_actionbar);
            grid.add (settings_revealer);
            grid.show_all ();
            add (grid);
            show_all ();
            volume_widget.leave_scale.connect (reveal_volume);
            playerpage.playback.notify["playing"].connect (signal_playlist);
            playlist_revealer.notify["child-revealed"].connect (() => {
                view_player ();
                signal_playlist ();
            });
            NikiApp.settings.changed["tooltip-equalizer"].connect (settings_icon);
            NikiApp.settings.changed["tooltip-videos"].connect (settings_icon);
            NikiApp.settings.changed["lyric-available"].connect (lyric_sensitive);
            NikiApp.settings.changed["liric-button"].connect (liric_icon);
            NikiApp.settings.changed["popover-visible"].connect (reveal_control);
            NikiApp.settings.changed["fullscreen"].connect (fullscreen_signal);
            NikiApp.settings.changed["player-mode"].connect (mode_change);
            NikiApp.settings.changed["audio-video"].connect (mode_change);
            signal_playlist ();
            lyric_sensitive ();
            shuffle_icon ();
            settings_icon ();
            view_player ();
            liric_icon ();
            fullscreen_signal ();
            subtittle_button ();
        }
        private void mode_change () {
            view_player ();
            ((Gtk.Image) play_button_center.image).pixel_size = NikiApp.settings.get_boolean ("audio-video")? 48 : 16;
            lyric_sensitive ();
        }
        private void lyric_sensitive () {
            liric_revealer.sensitive = NikiApp.settings.get_boolean ("lyric-available");
            font_button_revealer.set_reveal_child (!playlist_revealer.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
            font_button.sensitive = NikiApp.settings.get_boolean ("lyric-available");
        }
        private void liric_icon () {
            liric_revealer.change_icon (NikiApp.settings.get_boolean ("liric-button")? "com.github.torikulhabib.niki.liric-on-symbolic" : "com.github.torikulhabib.niki.liric-off-symbolic");
            liric_revealer.tooltip_text = NikiApp.settings.get_boolean ("liric-button")? StringPot.Lyric_On : StringPot.Lyric_Off;
        }

        private void shuffle_icon () {
            ((Gtk.Image) shuffle_button.image).icon_name = NikiApp.settings.get_boolean ("shuffle-button")? "media-playlist-shuffle-symbolic" : "media-playlist-no-shuffle-symbolic";
        }

        private void settings_icon () {
            switch (NikiApp.settings.get_enum ("settings-mode")) {
                case SettingsMode.EQUALIZER :
                    setting_stack.visible_child = equalizer_grid;
                    settings_prev_button.sensitive = false;
                    settings_next_button.sensitive = true;
                    ((Gtk.Image) setting_niki.image).icon_name = "com.github.torikulhabib.niki.equalizer-on-symbolic";
                    ((Gtk.Image) settings_prev_button.image).icon_name = "com.github.torikulhabib.niki.equalizer-on-symbolic";
                    ((Gtk.Image) settings_next_button.image).icon_name = "video-display-symbolic";
                    settings_prev_button.tooltip_text = StringPot.Equalizer;
                    settings_next_button.tooltip_text = StringPot.Video_Balance;
                    setting_niki.tooltip_markup = _("%s: %s").printf (StringPot.Equalizer, "<b>" + Markup.escape_text (NikiApp.settings.get_string ("tooltip-equalizer")) + "</b>");
                    break;
                case SettingsMode.VIDEO :
                    setting_stack.visible_child = video_grid;
                    settings_prev_button.sensitive = true;
                    settings_next_button.sensitive = true;
                    ((Gtk.Image) settings_prev_button.image).icon_name = "com.github.torikulhabib.niki.equalizer-on-symbolic";
                    ((Gtk.Image) settings_next_button.image).icon_name = "preferences-other-symbolic";
                    ((Gtk.Image) setting_niki.image).icon_name = "video-display-symbolic";
                    settings_prev_button.tooltip_text = StringPot.Equalizer;
                    settings_next_button.tooltip_text = StringPot.Other_Preferences;
                    setting_niki.tooltip_markup = _("%s: %s").printf (StringPot.Video_Balance, "<b>" + Markup.escape_text (NikiApp.settings.get_string ("tooltip-videos")) + "</b>");
                    break;
                case SettingsMode.OTHER :
                    setting_stack.visible_child = othergrid;
                    ((Gtk.Image) settings_prev_button.image).icon_name = "video-display-symbolic";
                    ((Gtk.Image) settings_next_button.image).icon_name = "preferences-other-symbolic";
                    settings_next_button.sensitive = false;
                    settings_prev_button.sensitive = true;
                    settings_prev_button.tooltip_text = StringPot.Video_Balance;
                    settings_next_button.tooltip_text = StringPot.Other_Preferences;
                    ((Gtk.Image) setting_niki.image).icon_name = "preferences-other-symbolic";
                    setting_niki.tooltip_markup = _("%s: %s").printf (StringPot.Preferences, "<b> Audio and Video </b>");
                    break;
            }
        }

        private void view_player () {
            if (!NikiApp.settings.get_boolean ("audio-video")) {
                NikiApp.settings.set_boolean ("liric-button", false);
                liric_icon ();
            }
            time_video.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            time_music.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            box_setting_list_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            box_action_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            action_box_revealer.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            liric_revealer.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            no_plylist_repeat_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video") && !playlist_revealer.child_revealed);
        }
        private void signal_playlist () {
            playlist_revealer.set_reveal_child (NikiApp.settings.get_boolean ("next-status") || NikiApp.settings.get_boolean ("previous-status")? true : false);
            previous_revealer.set_reveal_child (NikiApp.settings.get_boolean ("previous-status")? true : false);
            next_revealer.set_reveal_child (NikiApp.settings.get_boolean ("next-status")? true : false);
            previous_button_center.sensitive = NikiApp.settings.get_boolean ("previous-status")? true : false;
            next_button_center.sensitive = NikiApp.settings.get_boolean ("next-status")? true : false;
            font_button_revealer.set_reveal_child (!playlist_revealer.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
            font_button.sensitive = NikiApp.settings.get_boolean ("lyric-available");
        }

        private void fullscreen_signal () {
            ((Gtk.Image) fullscreen_button.image).icon_name = NikiApp.settings.get_boolean ("fullscreen")? "com.github.torikulhabib.niki.fullscreen-symbolic" : "com.github.torikulhabib.niki.unfullscreen-symbolic";
            fullscreen_button.tooltip_text = NikiApp.settings.get_boolean ("fullscreen")? StringPot.Fullscreen : StringPot.Exit_Fullscreen;
        }
        private void subtittle_button () {
            subtitle_revealer.change_icon (NikiApp.settings.get_boolean ("activate-subtittle")? "com.github.torikulhabib.niki.subtittle-on-symbolic" : "com.github.torikulhabib.niki.subtittle-off-symbolic");
            subtitle_revealer.tooltip_text = NikiApp.settings.get_boolean ("activate-subtittle")? StringPot.Subtitle_On : StringPot.Subtitle_Off;
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
                if (!hovered) {
                    volume_widget.set_reveal_child (false);
                }
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
                reveal_control ();
                volume_hiding_timer = 0;
                return Source.REMOVE;
            });
        }

        public void reveal_control () {
            if (!child_revealed) {
                set_reveal_child (true);
            }
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add (NikiApp.settings.get_boolean ("liric-button")? 700 : 3000, () => {
                if (hovered || seekbar_widget.preview_popover.visible || menu_popover.visible || NikiApp.settings.get_boolean ("settings-button") || volume_widget.child_revealed) {
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
