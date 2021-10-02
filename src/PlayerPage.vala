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
    public class PlayerPage : GtkClutter.Embed {
        public Player? playback;
        public Clutter.Stage stage;
        private ClutterGst.Content clutter_content;
        public Clutter.Actor cover_center;
        public Clutter.Actor small_cover;
        private Clutter.Text title_music;
        private Clutter.Text artist_music;
        public Clutter.Text first_lyric;
        public Clutter.Text seconds_lyric;
        private Clutter.Text notify_text;
        private SmallImage small_image;
        private CoverImage img_cover;
        private ImageCanvas img_background;
        private TittlePango tittlepango;
        private ArtistPango artistpango;
        public RightBar? right_bar;
        private GtkClutter.Actor right_actor;
        public TopBar? top_bar;
        public GtkClutter.Actor top_actor;
        public BottomBar? bottom_bar;
        public NotifyBottomBar? notifybottombar;
        public NotifyResume? notify_resume;
        public GtkClutter.Actor resume_actor;
        public GtkClutter.Actor bottom_actor;
        private GtkClutter.Actor bottom_actor_notif;
        public Clutter.ScrollActor scroll;
        public Clutter.Actor menu_actor;
        public Clutter.Point point;
        private Gdk.Geometry geometry;
        public MPRIS? mpris;
        public Inhibitor? initbitor;
        private string filesize;
        public int video_height;
        public int video_width;
        private uint mouse_timer = 0;
        private bool _mouse_hovered = false;
        private bool mouse_hovered {
            get {
                return _mouse_hovered;
            }
            set {
                _mouse_hovered = value;
                if (value) {
                    if (mouse_timer != 0) {
                        Source.remove (mouse_timer);
                        mouse_timer = 0;
                    }
                } else {
                    mouse_control ();
                }
            }
        }

        public PlayerPage (Window window) {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            playback = new Player ();
            initbitor = new Inhibitor ();
            stage = get_stage () as Clutter.Stage;
            stage.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            stage.set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR, Clutter.ScalingFilter.LINEAR);
            stage.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            clutter_content = new ClutterGst.Content () {
                sink = playback.sink
            };

            stage.content = clutter_content;
            playback.size_change.connect ((width, height) => {
                video_width = width * get_scale_factor ();
                video_height = height * get_scale_factor ();
                resize_player_page (width, height);
            });

            mpris = new MPRIS ();
            mpris.bus_acive (playback);
            img_background = new ImageCanvas (this);

            Clutter.LayoutManager layout_manager = new Clutter.BoxLayout ();
            ((Clutter.BoxLayout) layout_manager).set_orientation (Clutter.Orientation.VERTICAL);
            ((Clutter.BoxLayout) layout_manager).set_spacing (0);

            menu_actor = new Clutter.Actor ();
            menu_actor.set_layout_manager (layout_manager);

            scroll = new Clutter.ScrollActor ();
            scroll.set_scroll_mode (Clutter.ScrollMode.VERTICALLY);
            scroll.add_child (menu_actor);
            stage.add_child (scroll);

            var spectrum_grid = new Spectrum (this);
            spectrum_grid.show_all ();

            var spectrum = new GtkClutter.Actor () {
                background_color = Clutter.Color.from_string ("black") { alpha = 0 },
                contents = spectrum_grid
            };

            small_cover = new Clutter.Actor ();
            small_image = new SmallImage (this);
            stage.add_child (small_cover);

            cover_center = new Clutter.Actor ();
            img_cover = new CoverImage (this);
            cover_center.add_child (spectrum);
            stage.add_child (cover_center);

            notify_text = new Clutter.Text () {
                ellipsize = Pango.EllipsizeMode.END,
                color = Clutter.Color.from_string ("white"),
                background_color = Clutter.Color.from_string ("black") { alpha = 80 },
                font_name = "Bitstream Vera Sans Bold 10",
                line_alignment = Pango.Alignment.CENTER,
                use_markup = true,
                line_wrap = true
            };
            stage.add_child (notify_text);

            first_lyric = new Clutter.Text () {
                ellipsize = Pango.EllipsizeMode.END,
                background_color = Clutter.Color.from_string ("black") { alpha = 100 },
                line_alignment = Pango.Alignment.CENTER,
                single_line_mode = true,
                line_wrap = true
            };
            stage.add_child (first_lyric);

            seconds_lyric = new Clutter.Text () {
                ellipsize = Pango.EllipsizeMode.END,
                background_color = Clutter.Color.from_string ("black") { alpha = 100 },
                line_alignment = Pango.Alignment.CENTER,
                single_line_mode = true,
                line_wrap = true
            };
            stage.add_child (seconds_lyric);

            title_music = new Clutter.Text ();
            tittlepango = new TittlePango (this, title_music);
            tittlepango.draw_position.connect (stage_position);
            stage.add_child (title_music);

            artist_music = new Clutter.Text ();
            artistpango = new ArtistPango (this, artist_music);
            artistpango.draw_position.connect (stage_position);
            stage.add_child (artist_music);

            right_bar = new RightBar (this);
            right_actor = new GtkClutter.Actor () {
                background_color = Clutter.Color.from_string ("black") { alpha = 0 },
                contents = right_bar
            };
            right_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.X_AXIS, 1));
            right_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 1));
            stage.add_child (right_actor);

            top_bar = new TopBar (this);
            top_actor = new GtkClutter.Actor () {
                background_color = Clutter.Color.from_string ("black") { alpha = 0 },
                contents = top_bar
            };
            top_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 0));
            top_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            stage.add_child (top_actor);

            notifybottombar = new NotifyBottomBar (this);
            bottom_actor_notif = new GtkClutter.Actor () {
                background_color = Clutter.Color.from_string ("black") { alpha = 0 },
                contents = notifybottombar
            };
            bottom_actor_notif.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 1));
            bottom_actor_notif.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 1));
            stage.add_child (bottom_actor_notif);

            bottom_bar = new BottomBar (this);
            bottom_bar.bind_property ("playing", playback, "playing", BindingFlags.BIDIRECTIONAL);
            bottom_actor = new GtkClutter.Actor () {
                background_color = Clutter.Color.from_string ("black") { alpha = 0 },
                contents = bottom_bar
            };
            bottom_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 1));
            bottom_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 1));
            stage.add_child (bottom_actor);

            notify_resume = new NotifyResume (this);
            resume_actor = new GtkClutter.Actor () {
                background_color = Clutter.Color.from_string ("black") { alpha = 150 },
                contents = notify_resume
            };
            stage.add_child (resume_actor);

            stage.motion_event.connect ((event) => {
                if (!bottom_bar.child_revealed && !right_bar.child_revealed) {
                    if (event.y > (stage.height - 30)) {
                        bottom_bar.reveal_control ();
                    }
                }
                if (event.y < (stage.height - 30) && event.y > 20) {
                    top_bar.hovered = bottom_bar.hovered = false;
                }
                if (!top_bar.child_revealed && !right_bar.child_revealed) {
                    if (event.y < 20) {
                        top_bar.reveal_control ();
                    }
                }
                return Gdk.EVENT_PROPAGATE;
            });
            motion_notify_event.connect (() => {
                mouse_hovered = window.main_stack.visible_child_name == "welcome"? false : true;
                return false;
            });
            button_press_event.connect ((event) => {
                mouse_hovered = false;
                if (event.button == Gdk.BUTTON_PRIMARY && event.type == Gdk.EventType.2BUTTON_PRESS && !right_bar.child_revealed && !top_bar.hovered && !bottom_bar.hovered && !notify_resume.hovered) {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }

                if (event.button == Gdk.BUTTON_SECONDARY && !right_bar.child_revealed && !top_bar.hovered && !bottom_bar.hovered && !notify_resume.hovered) {
                    playback.playing = !playback.playing;
                    string_notify (playback.playing? _("Play") : _("Pause"));
                }
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect (() => {
                return mouse_hovered = false;
            });
            right_bar.playlist.play.connect (play_file);
            right_bar.playlist.item_added.connect (tittle_update);
            bottom_bar.notify["child-revealed"].connect (mouse_blank);
            top_bar.notify["child-revealed"].connect (mouse_blank);
            right_bar.notify["child-revealed"].connect (mouse_blank);
            right_bar.playlist.item_added.connect (load_current_list);

            playback.eos.connect (() => {
                switch (NikiApp.settings.get_enum ("repeat-mode")) {
                    case RepeatMode.ALL :
                        if (!right_bar.playlist.next ()) {
                            right_bar.playlist.play_first ();
                        }
                        break;
                    case RepeatMode.ONE :
                        playback.playing = true;
                        break;
                    case RepeatMode.OFF :
                        if (!right_bar.playlist.next ()) {
                            playback.playing = false;
                            ((Gtk.Image) bottom_bar.play_button.image).icon_name = "com.github.torikulhabib.niki.replay-symbolic";
                            bottom_bar.play_button.tooltip_text = _("Replay");
                            bottom_bar.stop_revealer.set_reveal_child (false);
                            bottom_bar.previous_revealer.set_reveal_child (false);
                            bottom_bar.next_revealer.set_reveal_child (false);
                            initbitor.uninhibit ();
                        }
                        break;
                }
            });

            playback.notify["progress"].connect (() => {
                if (playback.playing) {
                    if (NikiApp.settings.get_boolean ("lyric-available") && NikiApp.settings.get_boolean ("audio-video")) {
                        stage_position ();
                    }
                }
            });
            playback.notify["buffer-fill"].connect (buffer_fill);
            playback.notify["playing"].connect (signal_playing);
            NikiApp.settings.changed["font-options"].connect (font_option);
            NikiApp.settings.changed["font"].connect (font_option);
            font_option ();
            update_volume ();
            NikiApp.settings.changed["volume-adjust"].connect (update_volume);
            NikiApp.settings.changed["status-muted"].connect (update_volume);
            NikiApp.settings.changed["fullscreen"].connect (() => {
                if (!NikiApp.settings.get_boolean ("fullscreen")) {
                    string_notify (_("Press ESC to exit full screen"));
                } else {
                    notify_blank ();
                    if (notify_timer != 0) {
                        Source.remove (notify_timer);
                    }
                    notify_timer = 0;
                }
            });

            NikiApp.settings.changed["information-button"].connect (()=> {
                seek_music ();
                stage_position ();
            });

            bottom_bar.notify["child-revealed"].connect (() => {
                notifybottombar.set_reveal_child (false);
            });

            playback.ready.connect (()=> {
                stage_position ();
                if (video_width > 0 && video_height > 0) {
                    resize_player_page (video_width, video_height);
                }
            });
            NikiApp.settings.changed["activate-subtitle"].connect (subtittle_mode);
            subtittle_mode ();
            size_allocate.connect (stage_position);
            notify_resume.notify["child-revealed"].connect (stage_position);
            notify_resume.resume_play.connect ((progress)=> {
                playback.seeked = progress;
                stage_position ();
            });
            Idle.add (starting);
            window.welcome_page.getlink.errormsg.connect (string_notify);
            NikiApp.settings.changed["location-save"].connect (reloadlrc);
            NikiApp.settings.changed["lyric-location"].connect (reloadlrc);
            destroy.connect (()=> {
                if (!NikiApp.settings.get_boolean ("fullscreen")) {
                    NikiApp.settings.set_boolean ("fullscreen", true);
                }
            });
        }

        public void reloadlrc () {
            if (playback.uri != null) {
                sub_lr_check (playback.uri);
            }
        }

        private void subtittle_mode () {
            playback.subtitle_active = NikiApp.settings.get_boolean ("activate-subtitle");
        }

        public void home_open () {
            save_lasplay ();
            playback.stop ();
            playback.uri = "";
            initbitor.uninhibit ();
            if (NikiApp.window.main_stack.visible_child_name == "player") {
                if (!NikiApp.settings.get_boolean ("home-signal")) {
                    NikiApp.settings.set_boolean ("home-signal", true);
                }
                NikiApp.window.main_stack.visible_child_name = "welcome";
                resize_player_page (0, 0);
                ((Gtk.Window) get_toplevel ()).resize (570, 430);
            }
            NikiApp.settings.set_string ("last-played", " ");
            NikiApp.settings.set_string ("uri-video", " ");
            mouse_blank ();
            right_bar.playlist.clear_items ();
        }

        public void load_current_list () {
            if (NikiApp.window.main_stack.visible_child_name == "player" && !NikiApp.settings.get_boolean ("home-signal") && playback.uri != null) {
                update_current ();
            }
        }

        private void buffer_fill () {
            string_notify (@"Buffering: $(playback.buffer_fill)% Speed: $(format_size ((uint64)playback.conn_speed))");
        }

        public bool starting () {
            if (!playback.playing) {
                if (is_privacy_mode_enabled () && !NikiApp.settings.get_boolean ("home-signal") && NikiApp.window.welcome_page.index_but != 1) {
                    if (file_exists (NikiApp.settings.get_string ("last-played"))) {
                        NikiApp.window.welcome_page.index_but = 2;
                        NikiApp.window.welcome_page.stack.visible_child_name = "circular";
                        NikiApp.window.welcome_page.start_count (restore_file ());
                    } else {
                        gohome ();
                    }
                } else {
                    gohome ();
                }
            } else {
                NikiApp.window.main_stack.visible_child_name = "player";
            }
            return false;
        }

        public Gtk.ListStore restore_file () {
            var liststore = new Gtk.ListStore (1, typeof (string));
            foreach (string restore_last in NikiApp.settings.get_strv ("last-played-videos")) {
                if (!restore_last.has_prefix ("http")) {
                    Gtk.TreeIter iter;
                    liststore.append (out iter);
                    liststore.set (iter, 0, restore_last);
                }
            }
            return liststore;
        }

        public void get_first () {
            if (!NikiApp.settings.get_string ("last-played").has_prefix ("http")) {
                right_bar.playlist.play_starup (NikiApp.settings.get_string ("last-played"), this);
            }
        }

        private void gohome () {
            if (!NikiApp.settings.get_boolean ("home-signal")) {
                NikiApp.settings.set_boolean ("home-signal", true);
            }
            right_bar.playlist.clear_items ();
            NikiApp.window.main_stack.visible_child_name = "welcome";
        }

        public string scroll_actor (int index_in) {
            Clutter.Actor menu = scroll.get_first_child ();
            if (index_in > 0) {
                seek_music ();
            }
            Clutter.Actor item = menu.get_child_at_index (index_in);
            item.get_position (out point.x, out point.y);
            point.y = point.y - ((menu_actor.height / 2) - (((Clutter.Text)item).height / 2));
            scroll.save_easing_state ();
            scroll.scroll_to_point (point);
            scroll.restore_easing_state ();
            ((Clutter.Text)item).color = Clutter.Color.from_string ("orange");
            ((GLib.Object)scroll).set_data ("selected-item", index_in.to_pointer ());
            return ((Clutter.Text)item).text;
        }

        private void font_change () {
            for (int i = 0; i < menu_actor.get_n_children (); i++) {
                Clutter.Actor menu = scroll.get_first_child ();
                Clutter.Actor item = menu.get_child_at_index (i);
                ((Clutter.Text)item).font_name = NikiApp.settings.get_string ("font");
            }
        }

        public void seek_music () {
            if (NikiApp.settings.get_boolean ("audio-video") && !NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean ("lyric-button") && NikiApp.settings.get_boolean ("lyric-available")) {
                for (int i = 0; i < menu_actor.get_n_children (); i++) {
                    Clutter.Actor menu = scroll.get_first_child ();
                    Clutter.Actor item = menu.get_child_at_index (i);
                    ((Clutter.Text)item).color = Clutter.Color.from_string ("white");
                }
            }
        }

        public Clutter.Actor text_clutter (string name) {
            var lyric_sc = new Clutter.Text () {
                text = name,
                font_name = NikiApp.settings.get_string ("font"),
                color = Clutter.Color.from_string ("white"),
                background_color = Clutter.Color.from_string ("black") { alpha = 100 },
                margin_left = 12,
                margin_right = 12
            };
            return lyric_sc;
        }

        public void save_destroy () {
            if (!NikiApp.settings.get_boolean ("home-signal")) {
                if (playback.uri != null) {
                    if (playback.uri.has_prefix ("http")) {
                        NikiApp.settings.set_string ("last-played", " ");
                        NikiApp.settings.set_string ("uri-video", " ");
                        NikiApp.settings.set_boolean ("home-signal", true);
                    } else {
                        save_lasplay ();
                        NikiApp.settings.set_string ("last-played", NikiApp.settings.get_string ("uri-video"));
                        right_bar.playlist.save_playlist ();

                    }
                }
            }
        }

        private void save_lasplay () {
            if (!NikiApp.settings.get_boolean ("audio-video")) {
                insert_last_video (playback.uri, seconds_to_time ((int) (playback.progress * playback.duration)), playback.progress);
            } else {
                insert_last_music (playback.uri, playback.progress);
            }
        }

        public void stage_position () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                int height;
                ((Gtk.Window) get_toplevel ()).get_size (null, out height);
                menu_actor.height = height - (int) (height * 0.5);
            }
            if (notify_timer > 0 ) {
                notify_text.x = (stage.width / 2) - (notify_text.width / 2);
                notify_text.y = ((stage.height / 8) - (notify_text.height / 2));
            }
            bool auvi = NikiApp.settings.get_boolean ("audio-video");
            bool ifbot = NikiApp.settings.get_boolean ("information-button");
            bool libot = NikiApp.settings.get_boolean ("lyric-button");
            bool liava = NikiApp.settings.get_boolean ("lyric-available");
            scroll.x = auvi && !ifbot && libot && liava? (stage.width / 2) - (scroll.width / 2) : -scroll.width;
            scroll.y = auvi && !ifbot && libot && liava? ((stage.height / 2) - (scroll.height / 2)) : -scroll.height;
            small_cover.x = auvi && !ifbot? ((stage.width / 2) - (small_cover.width / 2)) : -small_cover.width;
            small_cover.y = auvi && !ifbot? ((stage.height / 2) - (scroll.height / 2) - (small_cover.height + (small_cover.height / 20))) : -small_cover.height;
            cover_center.x = auvi && ifbot? (stage.width / 2) - (cover_center.width / 2) : -cover_center.width;
            cover_center.y = auvi && ifbot? ((stage.height / 2) - (cover_center.height / 2) - (title_music.height + (title_music.height / 2))) : -cover_center.height;
            if (auvi) {
                title_music.x = ((stage.width / 2) - (title_music.width / 2));
                title_music.y = scroll.y < 0 && ifbot? ((stage.height / 2) - (title_music.height / 2) + ((cover_center.height / 2) - (title_music.height - (title_music.height / 4)))) : ((stage.height / 2) + (scroll.height / 2) + (title_music.height - (title_music.height / 4)));
                artist_music.x = ((stage.width / 2) - (artist_music.width / 2));
                artist_music.y = scroll.y < 0 && ifbot? ((stage.height / 2) - (artist_music.height / 2) + (((cover_center.height / 2) - (title_music.height - (title_music.height / 4))) + (artist_music.height))) : ((stage.height / 2) + (scroll.height / 2) + ((title_music.height) - (title_music.height / 4) + (artist_music.height)));
            } else {
                title_music.x = -title_music.width;
                title_music.y = -title_music.height;
                artist_music.x = -artist_music.width;
                artist_music.y = -artist_music.height;
            }

            first_lyric.x = ifbot && liava && auvi && libot? ((stage.width / 2) - (first_lyric.width / 2)) : -first_lyric.width;
            first_lyric.y = ifbot && liava && auvi && libot? ((stage.height / 2) - (first_lyric.height / 2) + (((cover_center.height / 2) - (title_music.height - (title_music.height / 4))) + (artist_music.height + (artist_music.height / 4))) + first_lyric.height) : -first_lyric.height;
            seconds_lyric.x = ifbot && liava && auvi && libot? ((stage.width / 2) - (seconds_lyric.width / 2)) : -seconds_lyric.width;
            seconds_lyric.y = ifbot && liava && auvi && libot? ((stage.height / 2) - (seconds_lyric.height / 2) + (((cover_center.height / 2) - (title_music.height - (title_music.height / 4))) + (artist_music.height + (artist_music.height / 4) + (seconds_lyric.height + (first_lyric.height + (first_lyric.height / 4) ))))) : -seconds_lyric.height;
            resume_actor.x = notify_resume.child_revealed? (stage.width / 2) - (resume_actor.width / 2) : -resume_actor.width;
            resume_actor.y = notify_resume.child_revealed? ((stage.height / 2) - (resume_actor.height / 2)) : -resume_actor.height;
        }

        public void resize_player_page (int n_width, int n_height) {
            double width = n_width / 2;
            double height = n_height / 2;
            double aspect_max = width / height;
            if (!NikiApp.settings.get_boolean ("audio-video") && !NikiApp.settings.get_boolean ("home-signal")) {
                double limit = aspect_max > 1.5? (aspect_max < 1.9? 0.1977777777777777 : 0.3277777777777777) : 0.1033333333333337;
                geometry.min_aspect = aspect_max > 1? aspect_max - limit : aspect_max + limit;
                geometry.max_aspect = aspect_max > 1? aspect_max - limit : aspect_max + limit;
                ((Gtk.Window) get_toplevel ()).set_geometry_hints (((Gtk.Window) get_toplevel ()), geometry, Gdk.WindowHints.ASPECT);
                ((Gtk.Window) get_toplevel ()).resize (n_width, n_height);
                set_size_request ((int)(width / 2), (int)(height / 2));
            } else {
                geometry.min_aspect = aspect_max;
                geometry.max_aspect = aspect_max;
                ((Gtk.Window) get_toplevel ()).set_geometry_hints (((Gtk.Window) get_toplevel ()), geometry, Gdk.WindowHints.USER_SIZE);
            }
        }

        private void font_option () {
            playback.subtitle_font_name = NikiApp.settings.get_int ("font-options") == 0? "" : NikiApp.settings.get_string ("font");
            first_lyric.font_name = seconds_lyric.font_name = NikiApp.settings.get_string ("font");
            font_change ();
        }

        public void mouse_control () {
            cursor_hand_mode (2);
            if (mouse_timer != 0) {
                Source.remove (mouse_timer);
            }
            mouse_timer = GLib.Timeout.add (500, () => {
                if (mouse_hovered || NikiApp.window.main_stack.visible_child_name == "welcome") {
                    mouse_timer = 0;
                    return false;
                }
                mouse_blank ();
                mouse_timer = 0;
                return false;
            });
        }

        public void mouse_blank () {
            if (bottom_bar.child_revealed || right_bar.child_revealed || top_bar.child_revealed) {
                cursor_hand_mode (2);
            } else if (NikiApp.window.main_stack.visible_child_name == "player") {
                cursor_hand_mode (1);
            } else {
                cursor_hand_mode (2);
            }
        }
        private uint notify_timer = 0;
        private void notify_control () {
            notify_text.x = (stage.width / 2) - (notify_text.width / 2);
            notify_text.y = ((stage.height / 8) - (notify_text.height / 2));
            if (notify_timer != 0) {
                Source.remove (notify_timer);
            }
            notify_timer = GLib.Timeout.add (1500, () => {
                notify_blank ();
                notify_timer = 0;
                return Source.REMOVE;
            });
        }

        private void notify_blank () {
            notify_text.x = -notify_text.width;
            notify_text.y = -notify_text.height;
        }

        public void update_volume () {
            playback.audio_volume = NikiApp.settings.get_double ("volume-adjust");
        }

        private void play_file (string uri, string filesize, int mediatype, bool from_beginning = true) {
            this.filesize = filesize;
            NikiApp.settings.set_enum ("player-mode", mediatype);
            if (uri.has_prefix ("http")) {
                NikiApp.settings.set_string ("uri-video", uri);
                playback.uri = uri;
                playback.playing = from_beginning;
                check_lr_sub ();
                signal_playing ();
            } else {
                if (playback.uri != null) {
                    if (get_mime_type (File.new_for_uri (playback.uri)).has_prefix ("video/")) {
                        if (videos_file_exists (playback.uri)) {
                            insert_last_video (playback.uri, seconds_to_time ((int) (playback.progress * playback.duration)), playback.progress);
                            right_bar.playlist.update_progress_video (playback.uri, seconds_to_time ((int) (playback.progress * playback.duration)), seconds_to_time ((int) (playback.duration)));
                        }
                    }
                    if (get_mime_type (File.new_for_uri (playback.uri)).has_prefix ("audio/")) {
                        if (music_file_exists (playback.uri)) {
                            insert_last_music (playback.uri, playback.progress);
                        }
                    }
                }
                if (get_mime_type (File.new_for_uri (uri)).has_prefix ("video/")) {
                    playback.uri = uri;
                    if (lastplay_video (uri) > 0.1) {
                        notify_resume.reveal_control (duration_video (uri), lastplay_video (uri), _("watching"));
                    } else {
                        notify_resume.set_reveal_child (false);
                    }
                }
                if (get_mime_type (File.new_for_uri (uri)).has_prefix ("audio/")) {
                    playback.uri = uri;
                    if (lastplay_music (uri) > 0.1) {
                        notify_resume.reveal_control (duration_music (uri), lastplay_music (uri), _("listening"));
                    } else {
                        notify_resume.set_reveal_child (false);
                    }
                }
                NikiApp.settings.set_string ("uri-video", uri);
                sub_lr_check (uri);
                playback.playing = from_beginning;
                signal_playing ();
            }
            if (NikiApp.settings.get_boolean ("home-signal")) {
                NikiApp.settings.set_boolean ("home-signal", false);
                NikiApp.window.main_stack.visible_child_name = "player";
            }
            tittle_update ();
        }

        private void tittle_update () {
            top_bar.label_info.set_label (update_current () + NikiApp.settings.get_string ("title-playing") + filesize);
            top_bar.info_label_full.set_label (update_current () + NikiApp.settings.get_string ("title-playing") + filesize);
        }

        public string update_current () {
            if (playback.uri == null) {
                return "";
            }
            right_bar.playlist.set_current (playback.uri, this);
            int total = right_bar.playlist.total;
            int current = right_bar.playlist.current + 1;
            return @"($(current)/$(total)) ";
        }

        private void check_lr_sub () {
            if (NikiApp.settings.get_boolean ("subtitle-available")) {
                NikiApp.settings.set_boolean ("subtitle-available", false);
                bottom_bar.menu_popover.file_chooser_subtitle.select_uri ("");
            }
            if (NikiApp.settings.get_boolean ("lyric-available")) {
                NikiApp.settings.set_boolean ("lyric-available", false);
            }
            if (menu_actor.get_n_children () > 0) {
                menu_actor.remove_all_children ();
            }
        }

        private void sub_lr_check (string check) {
            check_lr_sub ();
            string? sub_uri = get_subtitle_for_uri (check);
            if (sub_uri != null && sub_uri != check) {
                bottom_bar.menu_popover.file_chooser_subtitle.select_uri (sub_uri);
                playback.subtitle_uri = sub_uri;
                NikiApp.settings.set_boolean ("subtitle-available", true);
            } else {
                playback.subtitle_uri = null;
            }
            var file = File.new_for_uri (check);
            string? lyric_uri = null;
            switch (NikiApp.settings.get_int ("location-save")) {
                case 0 :
                    lyric_uri = get_playing_lyric (check);
                    break;
                case 1 :
                    var file_uri = File.new_build_filename (NikiApp.settings.get_string ("lyric-location"), file.get_basename ());
                    lyric_uri = get_playing_lyric (file_uri.get_uri ());
                    break;
                case 2 :
                    var file_ask = run_open_file (this, false, 3);
                    if (file_ask != null) {
                        lyric_uri = get_playing_lyric (file_ask[0].get_uri ());
                    }
                    break;
            }
            if (lyric_uri != null) {
                bottom_bar.seekbar_widget.on_lyric_update (file_lyric (lyric_uri), this);
                NikiApp.settings.set_boolean ("lyric-available", true);
            }
        }

        public void signal_playing () {
            bottom_bar.stop_revealer.set_reveal_child (true);
            if (NikiApp.settings.get_enum ("player-mode") == PlayerMode.VIDEO || NikiApp.settings.get_enum ("player-mode") == PlayerMode.STREAMVID) {
                if (NikiApp.settings.get_boolean ("audio-video")) {
                    NikiApp.settings.set_boolean ("audio-video", false);
                }
                if (playback.playing) {
                    initbitor.inhibit ();
                } else {
                    initbitor.uninhibit ();
                }
                stage.content = clutter_content;
            } else {
                if (!NikiApp.settings.get_boolean ("audio-video")) {
                    NikiApp.settings.set_boolean ("audio-video", true);
                }
                if (NikiApp.settings.get_boolean ("lyric-button") && NikiApp.settings.get_boolean ("lyric-available") && playback.playing && !return_hide_mode) {
                    initbitor.inhibit ();
                } else {
                    initbitor.uninhibit ();
                }
                resize_player_page (0, 0);
            }
            stage_position ();
            load_current_list ();
        }

        public void next () {
            if (!right_bar.playlist.get_has_next () && NikiApp.settings.get_enum ("repeat-mode") == 1) {
                right_bar.playlist.play_first ();
            } else {
                right_bar.playlist.next ();
            }
        }

        public void previous () {
            if (!right_bar.playlist.get_has_previous () && NikiApp.settings.get_enum ("repeat-mode") == 1) {
                right_bar.playlist.play_end ();
            } else {
                right_bar.playlist.previous ();
            }
        }

        public void seek_jump_seconds (int seconds) {
            if (NikiApp.settings.get_boolean ("home-signal")) {
                return;
            }
            var duration = playback.duration;
            var progress = playback.progress;
            var new_progress = ((duration * progress) + (double)seconds) / duration;
            playback.seeked = new_progress.clamp (0.0, 1.0);
            string_notify (bottom_bar.seekbar_widget.duration_n_progress);
            if (!bottom_bar.child_revealed) {
                notifybottombar.reveal_control ();
            }
            seek_music ();
        }

        public void seek_volume (double steps) {
            var new_volume = ((1 * NikiApp.settings.get_double ("volume-adjust")) + (double)steps);
            NikiApp.settings.set_double ("volume-adjust", new_volume.clamp (0.0, 1.0));
            string_notify (double_to_percent (NikiApp.settings.get_double ("volume-adjust")));
        }

        public void string_notify (string notify_string) {
            notify_text.text = @"\n     $(notify_string.dup ())     \n";
            notify_control ();
        }
    }
}
