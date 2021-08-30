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
    public class BottomBar : Gtk.Revealer {
        public MakeLyric? makelyric;
        public OtherGrid? othergrid;
        public SettingsPopover? menu_popover;
        public SeekBar? seekbar_widget;
        public EqualizerGrid? equalizergrid;
        public VideoGrid? video_grid;
        private TimeVideo? time_video;
        public TimeMusic? time_music;
        private VolumeWiget? volume_widget;
        public Gtk.Button play_button;
        private Gtk.Button menu_settings;
        private Gtk.Button play_but_cen;
        private Gtk.Button fullscreen_button;
        private Gtk.Button next_button_center;
        private Gtk.Button shuffle_button;
        private Gtk.Button setting_niki;
        private Gtk.Button settings_prev_button;
        private Gtk.Button settings_next_button;
        private Gtk.Button font_button;
        private Gtk.Button previous_button_center;
        private Gtk.Revealer action_box_rev;
        private Gtk.Revealer box_action_revealer;
        private Gtk.Revealer box_set_list_rev;
        private Gtk.Revealer font_but_rev;
        private Gtk.Revealer no_rep_rev;
        public ButtonRevealer? previous_revealer;
        public ButtonRevealer? next_revealer;
        public ButtonRevealer? subtitle_revealer;
        public ButtonRevealer? stop_revealer;
        private ButtonRevealer? playlist_revealer;
        private ButtonRevealer? lyric_revealer;
        public VolumeButton? volume_button;
        public RepeatButton? repeat_button;
        private RepeatButton? no_plylist_repeat;
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
                ((Gtk.Image) play_but_cen.image).icon_name = value? "com.github.torikulhabib.niki.pause-symbolic" : "com.github.torikulhabib.niki.play-symbolic";
                play_button.tooltip_text = value? _("Pause") : _("Play");
                play_but_cen.tooltip_text = value? _("Pause") : _("Play");
            }
        }

        public BottomBar (PlayerPage playerpage) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
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

            stop_revealer = new ButtonRevealer ("media-playback-stop-symbolic") {
                tooltip_text = _("Stop"),
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 500
            };
            stop_revealer.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            stop_revealer.button.get_style_context ().add_class ("button_action");


            play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            play_button.get_style_context ().add_class ("button_action");
            play_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            play_button.clicked.connect (() => {
                playing = !playing;
            });

            play_but_cen = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.play-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            ((Gtk.Image) play_but_cen.image).pixel_size = NikiApp.settings.get_boolean ("audio-video")? 48 : 16;
            play_but_cen.get_style_context ().add_class ("button_action");
            play_but_cen.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            play_but_cen.clicked.connect (() => {
                playing = !playing;
            });

            stop_revealer.clicked.connect (() => {
                playerpage.playback.pipeline.set_state (Gst.State.NULL);
                playing = false;
                playerpage.playback.progress = 0.0;
                insert_last_video (playerpage.playback.uri, seconds_to_time ((int) (playerpage.playback.progress * playerpage.playback.duration)), 0.0);
                stop_revealer.set_reveal_child (false);
            });

            repeat_button = new RepeatButton ();
            repeat_button.get_style_context ().add_class ("button_action");
            repeat_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            no_plylist_repeat = new RepeatButton ();
            no_plylist_repeat.get_style_context ().add_class ("button_action");
            no_plylist_repeat.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            no_rep_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 100
            };
            no_rep_rev.add (no_plylist_repeat);

            shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            shuffle_button.get_style_context ().add_class ("button_action");
            shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            shuffle_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("shuffle-button", !NikiApp.settings.get_boolean ("shuffle-button"));
                shuffle_icon ();
            });

            playlist_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.playlist-symbolic") {
                tooltip_text = _("Playlist"),
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500
            };
            playlist_revealer.button.get_style_context ().add_class ("button_action");
            playlist_revealer.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            playlist_revealer.clicked.connect (() => {
                playerpage.right_bar.reveal_control ();
            });

            font_button = new Gtk.Button.from_icon_name ("font-x-generic-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = NikiApp.settings.get_string ("font")
            };
            font_button.get_style_context ().add_class ("button_action");
            font_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            font_button.clicked.connect (() => {
                menu_popover.font_selection_btn.clicked ();
                font_button.tooltip_text = NikiApp.settings.get_string ("font");
            });

            font_but_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 100
            };
            font_but_rev.add (font_button);

            menu_settings = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Settings")
            };
            menu_settings.get_style_context ().add_class ("button_action");
            menu_settings.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            menu_settings.clicked.connect (() => {
                menu_popover.show_all ();
            });

            menu_popover = new SettingsPopover (playerpage) {
                relative_to = menu_settings
            };
            menu_popover.closed.connect (reveal_control);

            next_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.next-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Next")
            };
            next_button_center.get_style_context ().add_class ("button_action");
            next_button_center.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            next_button_center.clicked.connect (() => {
                playerpage.next ();
            });

            next_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.next-symbolic") {
                tooltip_text = _("Next"),
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 500
            };
            next_revealer.button.get_style_context ().add_class ("button_action");
            next_revealer.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            next_revealer.clicked.connect (() => {
                playerpage.next ();
            });

            previous_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.previous-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Previous")
            };
            previous_button_center.get_style_context ().add_class ("button_action");
            previous_button_center.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            previous_button_center.clicked.connect (() => {
                playerpage.previous ();
            });

            previous_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.previous-symbolic") {
                tooltip_text = _("Previous"),
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500
            };
            previous_revealer.button.get_style_context ().add_class ("button_action");
            previous_revealer.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            previous_revealer.clicked.connect (() => {
                playerpage.previous ();
            });

            NikiApp.settings.changed["next-status"].connect (signal_playlist);
            NikiApp.settings.changed["previous-status"].connect (signal_playlist);

            subtitle_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.previous-symbolic") {
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500
            };
            subtitle_revealer.button.get_style_context ().add_class ("button_action");
            subtitle_revealer.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            subtitle_revealer.clicked.connect (() => {
                NikiApp.settings.set_boolean ("activate-subtitle", !NikiApp.settings.get_boolean ("activate-subtitle"));
            });

            NikiApp.settings.changed["activate-subtitle"].connect (subtitle_button);
            NikiApp.settings.changed["subtitle-available"].connect (() => {
                subtitle_revealer.set_reveal_child (NikiApp.settings.get_boolean ("subtitle-available"));
            });

            fullscreen_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.fullscreen-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            fullscreen_button.get_style_context ().add_class ("button_action");
            fullscreen_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            fullscreen_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
            });

            lyric_revealer = new ButtonRevealer ("com.github.torikulhabib.niki.lyric-off-symbolic") {
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500
            };
            lyric_revealer.button.get_style_context ().add_class ("button_action");
            lyric_revealer.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            lyric_revealer.clicked.connect ( () => {
                NikiApp.settings.set_boolean ("lyric-button", !NikiApp.settings.get_boolean ("lyric-button"));
            });

            video_grid = new VideoGrid (playerpage);
            video_grid.init ();
            equalizergrid = new EqualizerGrid (playerpage);
            equalizergrid.init ();

            setting_niki = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.equalizer-on-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            setting_niki.get_style_context ().add_class ("button_action");
            setting_niki.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            setting_niki.clicked.connect (() => {
                NikiApp.settings.set_boolean ("settings-button", !NikiApp.settings.get_boolean ("settings-button"));
            });

            seekbar_widget = new SeekBar (playerpage);
            time_video = new TimeVideo (playerpage.playback);
            time_music = new TimeMusic (playerpage.playback);

            volume_button = new VolumeButton ();
            volume_button.get_style_context ().add_class ("button_action");
            volume_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            volume_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("status-muted", !NikiApp.settings.get_boolean ("status-muted"));
            });
            volume_widget = new VolumeWiget ();
            volume_widget.get_style_context ().add_class ("volume");
            volume_widget.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            volume_widget.scale.get_style_context ().add_class ("volume");
            volume_widget.scale.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            volume_widget.notify["child-revealed"].connect (() => {
                int width;
                ((Gtk.Window) get_toplevel ()).get_size (out width, null);
                if (width < 500) {
                    lyric_revealer.set_reveal_child (!volume_widget.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
                } else if (!lyric_revealer.child_revealed) {
                    lyric_revealer.set_reveal_child (!volume_widget.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
                }
            });
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
            settings_prev_button = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.equalizer-on-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            settings_prev_button.get_style_context ().add_class ("button_action");
            settings_prev_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            settings_next_button = new Gtk.Button.from_icon_name ("video-display-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            settings_next_button.get_style_context ().add_class ("button_action");
            settings_next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            othergrid = new OtherGrid ();

            setting_stack = new Gtk.Stack ();
            setting_stack.add_named (equalizergrid, "equalizergrid");
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

            var setting_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                margin_start = 4,
                margin_end = 4
            };
            setting_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            setting_actionbar.get_style_context ().add_class ("transbgborder");
            setting_actionbar.pack_start (settings_prev_button, false, false, 0);
            setting_actionbar.set_center_widget (setting_stack);
            setting_actionbar.pack_end (settings_next_button, false, false, 0);
            setting_actionbar.show_all ();

            var settings_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_UP,
                transition_duration = 500,
                reveal_child = NikiApp.settings.get_boolean ("settings-button")
            };
            settings_revealer.add (setting_actionbar);

            NikiApp.settings.changed["settings-button"].connect (() => {
                reveal_control ();
                settings_revealer.set_reveal_child (NikiApp.settings.get_boolean ("settings-button"));
            });

            settings_revealer.notify["child-revealed"].connect (() => {
                playerpage.right_bar.reveal_control (false);
            });

            makelyric = new MakeLyric (this, playerpage);
            time_music.position_sec.connect (makelyric.set_time_sec);
            var make_lrc_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_UP,
                transition_duration = 500
            };
            make_lrc_rev.add (makelyric);
            make_lrc_rev.notify["child-revealed"].connect (()=> {
                makelyric.resize_scr ();
                if (!make_lrc_rev.child_revealed) {
                    makelyric.clear_listmodel ();
                    makelyric.text_lrc.buffer.text = "";
                }
            });

            make_lrc_rev.set_reveal_child (NikiApp.settings.get_boolean ("make-lrc"));
            NikiApp.settings.changed["make-lrc"].connect (() => {
                make_lrc_rev.set_reveal_child (NikiApp.settings.get_boolean ("make-lrc"));
            });

            var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_action.pack_start (previous_revealer, false, false, 0);
            box_action.pack_start (play_button, false, false, 0);
            box_action.pack_start (stop_revealer, false, false, 0);
            box_action.pack_start (next_revealer, false, false, 0);
            box_action_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 50
            };
            box_action_revealer.add (box_action);

            var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            action_box.pack_start (shuffle_button, false, false, 0);
            action_box.pack_start (previous_button_center, false, false, 0);
            action_box.pack_start (play_but_cen, false, false, 0);
            action_box.pack_start (next_button_center, false, false, 0);
            action_box.pack_start (repeat_button, false, false, 0);
            action_box_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 50
            };
            action_box_rev.add (action_box);

            var box_set_list = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_set_list.pack_start (subtitle_revealer, false, false, 0);
            box_set_list.pack_start (menu_settings, false, false, 0);
            box_set_list.pack_start (fullscreen_button, false, false, 0);
            box_set_list_rev = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                transition_duration = 50
            };
            box_set_list_rev.add (box_set_list);

            var main_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                margin_end = 4,
                margin_start = 4,
                margin_bottom = 6
            };
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.set_center_widget (action_box_rev);
            main_actionbar.pack_start (box_action_revealer, false, false, 0);
            main_actionbar.pack_start (volume_button, false, false, 0);
            main_actionbar.pack_start (volume_widget, false, false, 0);
            main_actionbar.pack_start (lyric_revealer, false, false, 0);
            main_actionbar.pack_start (time_video, false, false, 0);
            main_actionbar.pack_end (box_set_list_rev, false, false, 0);
            main_actionbar.pack_end (playlist_revealer, false, false, 0);
            main_actionbar.pack_end (font_but_rev, false, false, 0);
            main_actionbar.pack_end (setting_niki, false, false, 0);
            main_actionbar.pack_end (no_rep_rev, false, false, 0);

            var grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                margin = 0,
                row_spacing = 0,
                column_spacing = 0,
                margin_top = 0
            };
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.get_style_context ().add_class ("bottombar");
            grid.add (seekbar_widget);
            grid.add (make_lrc_rev);
            grid.add (time_music);
            grid.add (main_actionbar);
            grid.add (settings_revealer);
            add (grid);
            show_all ();

            volume_widget.leave_scale.connect (reveal_volume);
            playerpage.playback.notify["playing"].connect (signal_playlist);
            playlist_revealer.notify["child-revealed"].connect (() => {
                view_player ();
                signal_playlist ();
            });

            notify["child-revealed"].connect (() => {
                if (!child_revealed) {
                    hovered = child_revealed;
                }
                playerpage.right_bar.reveal_control (false);
            });

            NikiApp.settings.changed["make-lrc"].connect (makelyric.resize_scr);
            NikiApp.settings.changed["tooltip-equalizer"].connect (settings_icon);
            NikiApp.settings.changed["tooltip-videos"].connect (settings_icon);
            NikiApp.settings.changed["lyric-available"].connect (lyric_sensitive);
            NikiApp.settings.changed["lyric-button"].connect (lyric_icon);
            NikiApp.settings.changed["popover-visible"].connect (reveal_control);
            NikiApp.settings.changed["fullscreen"].connect (fullscreen_signal);
            NikiApp.settings.changed["player-mode"].connect (mode_change);
            NikiApp.settings.changed["audio-video"].connect (mode_change);
            signal_playlist ();
            lyric_sensitive ();
            shuffle_icon ();
            settings_icon ();
            view_player ();
            lyric_icon ();
            fullscreen_signal ();
            subtitle_button ();
        }

        private void mode_change () {
            if (!NikiApp.settings.get_boolean ("audio-video")) {
                if (NikiApp.settings.get_boolean ("make-lrc")) {
                    NikiApp.settings.set_boolean ("make-lrc", false);
                }
            }
            view_player ();
            ((Gtk.Image) play_but_cen.image).pixel_size = NikiApp.settings.get_boolean ("audio-video")? 48 : 16;
            lyric_sensitive ();
        }

        private void lyric_sensitive () {
            lyric_revealer.sensitive = NikiApp.settings.get_boolean ("lyric-available");
            font_but_rev.set_reveal_child (!playlist_revealer.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
            font_button.sensitive = NikiApp.settings.get_boolean ("lyric-available");
        }

        private void lyric_icon () {
            lyric_revealer.change_icon (NikiApp.settings.get_boolean ("lyric-button")? "com.github.torikulhabib.niki.lyric-on-symbolic" : "com.github.torikulhabib.niki.lyric-off-symbolic");
            lyric_revealer.tooltip_text = NikiApp.settings.get_boolean ("lyric-button")? _("Lyrics On") : _("Lyrics Off");
        }

        private void shuffle_icon () {
            ((Gtk.Image) shuffle_button.image).icon_name = NikiApp.settings.get_boolean ("shuffle-button")? "media-playlist-shuffle-symbolic" : "media-playlist-no-shuffle-symbolic";
        }

        private void settings_icon () {
            switch (NikiApp.settings.get_enum ("settings-mode")) {
                case SettingsMode.EQUALIZER :
                    setting_stack.visible_child = equalizergrid;
                    settings_prev_button.sensitive = false;
                    settings_next_button.sensitive = true;
                    ((Gtk.Image) setting_niki.image).icon_name = "com.github.torikulhabib.niki.equalizer-on-symbolic";
                    ((Gtk.Image) settings_prev_button.image).icon_name = "com.github.torikulhabib.niki.equalizer-on-symbolic";
                    ((Gtk.Image) settings_next_button.image).icon_name = "video-display-symbolic";
                    settings_prev_button.tooltip_text = _("Equalizer");
                    settings_next_button.tooltip_text = _("Video Balance");
                    setting_niki.tooltip_markup = _("%s: %s").printf (_("Equalizer"), "<b>" + Markup.escape_text (NikiApp.settings.get_string ("tooltip-equalizer")) + "</b>");
                    break;
                case SettingsMode.VIDEO :
                    setting_stack.visible_child = video_grid;
                    settings_prev_button.sensitive = true;
                    settings_next_button.sensitive = true;
                    ((Gtk.Image) settings_prev_button.image).icon_name = "com.github.torikulhabib.niki.equalizer-on-symbolic";
                    ((Gtk.Image) settings_next_button.image).icon_name = "preferences-other-symbolic";
                    ((Gtk.Image) setting_niki.image).icon_name = "video-display-symbolic";
                    settings_prev_button.tooltip_text = _("Equalizer");
                    settings_next_button.tooltip_text = _("Other Preferences");
                    setting_niki.tooltip_markup = _("%s: %s").printf (_("Video Balance"), "<b>" + Markup.escape_text (NikiApp.settings.get_string ("tooltip-videos")) + "</b>");
                    break;
                case SettingsMode.OTHER :
                    setting_stack.visible_child = othergrid;
                    ((Gtk.Image) settings_prev_button.image).icon_name = "video-display-symbolic";
                    ((Gtk.Image) settings_next_button.image).icon_name = "preferences-other-symbolic";
                    settings_next_button.sensitive = false;
                    settings_prev_button.sensitive = true;
                    settings_prev_button.tooltip_text = _("Video Balance");
                    settings_next_button.tooltip_text = _("Other Preferences");
                    ((Gtk.Image) setting_niki.image).icon_name = "preferences-other-symbolic";
                    setting_niki.tooltip_markup = _("%s: %s").printf (_("Other Preferences"), @"<b> $(_("Audio and Video")) </b>");
                    break;
            }
        }

        private void view_player () {
            if (!NikiApp.settings.get_boolean ("audio-video")) {
                NikiApp.settings.set_boolean ("lyric-button", false);
                lyric_icon ();
            }
            time_video.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            time_music.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            box_set_list_rev.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            box_action_revealer.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video"));
            action_box_rev.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            lyric_revealer.set_reveal_child (NikiApp.settings.get_boolean ("audio-video"));
            no_rep_rev.set_reveal_child (!NikiApp.settings.get_boolean ("audio-video") && !playlist_revealer.child_revealed);
        }

        private void signal_playlist () {
            playlist_revealer.set_reveal_child (NikiApp.settings.get_boolean ("next-status") || NikiApp.settings.get_boolean ("previous-status")? true : false);
            previous_revealer.set_reveal_child (NikiApp.settings.get_boolean ("previous-status")? true : false);
            next_revealer.set_reveal_child (NikiApp.settings.get_boolean ("next-status")? true : false);
            previous_button_center.sensitive = NikiApp.settings.get_boolean ("previous-status")? true : false;
            next_button_center.sensitive = NikiApp.settings.get_boolean ("next-status")? true : false;
            font_but_rev.set_reveal_child (!playlist_revealer.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
            font_button.sensitive = NikiApp.settings.get_boolean ("lyric-available");
        }

        private void fullscreen_signal () {
            ((Gtk.Image) fullscreen_button.image).icon_name = NikiApp.settings.get_boolean ("fullscreen")? "com.github.torikulhabib.niki.fullscreen-symbolic" : "com.github.torikulhabib.niki.unfullscreen-symbolic";
            fullscreen_button.tooltip_text = NikiApp.settings.get_boolean ("fullscreen")? _("Fullscreen") : _("Exit Fullscreen");
        }

        private void subtitle_button () {
            subtitle_revealer.change_icon (NikiApp.settings.get_boolean ("activate-subtitle")? "com.github.torikulhabib.niki.subtitle-on-symbolic" : "com.github.torikulhabib.niki.subtitle-off-symbolic");
            subtitle_revealer.tooltip_text = NikiApp.settings.get_boolean ("activate-subtitle")? _("Subtitles On") : _("Subtitles Off");
        }

        public void schedule_show () {
            if (show_timer_id > 0) {
                return;
            }
            cancel_timer (ref hide_timer_id);
            show_timer_id = Timeout.add (350, () => {
                int width;
                ((Gtk.Window) get_toplevel ()).get_size (out width, null);
                if (width < 500) {
                    lyric_revealer.set_reveal_child (false);
                } else if (!lyric_revealer.child_revealed) {
                    lyric_revealer.set_reveal_child (!volume_widget.child_revealed && NikiApp.settings.get_boolean ("audio-video"));
                }
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
            hiding_timer = GLib.Timeout.add (3000, () => {
                if (hovered || seekbar_widget.preview_popover.visible || menu_popover.visible || NikiApp.settings.get_boolean ("settings-button") || NikiApp.settings.get_boolean ("make-lrc") || volume_widget.child_revealed) {
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
