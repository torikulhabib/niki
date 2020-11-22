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
    public class PlayerPage : GtkClutter.Embed {
        public PlaybackPlayer? playback;
        public Clutter.Stage stage;
        private ClutterGst.Content clutter_content;
        private Clutter.Actor cover_center;
        private Clutter.Text title_music;
        private Clutter.Text artist_music;
        public Clutter.Text first_lyric;
        public Clutter.Text seconds_lyric;
        private Clutter.Text notify_text;
        private Clutter.Image cover_img;
        private Clutter.Image oriimage;
        private Clutter.Image blur_image;
        public RightBar? right_bar;
        private GtkClutter.Actor right_actor;
        public TopBar? top_bar;
        public GtkClutter.Actor top_actor;
        public BottomBar? bottom_bar;
        public NotifyBottomBar? notifybottombar;
        public GtkClutter.Actor bottom_actor;
        private GtkClutter.Actor bottom_actor_notif;
        public Clutter.ScrollActor scroll;
        public Clutter.Actor menu_actor;
        public Clutter.Point point;
        private Gdk.Geometry geometry;
        public MPRIS? mpris;
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
            playback = new PlaybackPlayer ();
            playback.set_seek_flags (ClutterGst.SeekFlags.ACCURATE);
            stage = get_stage () as Clutter.Stage;
            stage.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            stage.set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR, Clutter.ScalingFilter.LINEAR);
            stage.set_content_gravity (Clutter.ContentGravity.RESIZE_ASPECT);
            clutter_content = new ClutterGst.Content ();
            clutter_content.player = playback;
            stage.content = clutter_content;
            playback.size_change.connect ((width, height) => {
                video_width = width;
                video_height = height;
                resize_player_page (window, width, height);
            });
            NikiApp.settings.changed["activate-subtitle"].connect (() => {
                playback.subtitle_track = NikiApp.settings.get_boolean ("activate-subtitle")? playback.get_subtitle_track() : -1;
            });
            mpris = new MPRIS ();
            mpris.bus_acive (playback);
            blur_image = new Clutter.Image ();
            oriimage = new Clutter.Image ();
            cover_img = new Clutter.Image ();

            Clutter.LayoutManager layout_manager = new Clutter.BoxLayout ();
            ((Clutter.BoxLayout) layout_manager).set_orientation (Clutter.Orientation.VERTICAL);
            ((Clutter.BoxLayout) layout_manager).set_spacing (0);
            menu_actor = new Clutter.Actor ();
            menu_actor.set_layout_manager (layout_manager);
            scroll = new Clutter.ScrollActor ();
            scroll.set_scroll_mode (Clutter.ScrollMode.VERTICALLY);
            scroll.add_child (menu_actor);
            stage.add_child (scroll);

            var spectrum_grid = new Spectrum (playback);
            spectrum_grid.show_all ();
            var spectrum = new GtkClutter.Actor ();
            spectrum.contents = spectrum_grid;
            spectrum.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            cover_center = new Clutter.Actor ();
            cover_center.width = 250;
            cover_center.height = 250;
            cover_center.content = cover_img;
            cover_center.add_child (spectrum);
            cover_center.set_pivot_point (0.5f, 0.5f);
            stage.add_child (cover_center);

            notify_text = new Clutter.Text ();
            notify_text.ellipsize = Pango.EllipsizeMode.END;
            notify_text.color = Clutter.Color.from_string ("white");
            notify_text.background_color = Clutter.Color.from_string ("black") { alpha = 80 };
            notify_text.font_name = "Bitstream Vera Sans Bold 10";
            notify_text.line_alignment = Pango.Alignment.CENTER;
            notify_text.use_markup = true;
            stage.add_child (notify_text);

            first_lyric = new Clutter.Text ();
            first_lyric.ellipsize = Pango.EllipsizeMode.END;
            first_lyric.background_color = Clutter.Color.from_string ("black") { alpha = 100 };
            first_lyric.line_alignment = Pango.Alignment.CENTER;
            first_lyric.single_line_mode = true;
            first_lyric.use_markup = true;
            stage.add_child (first_lyric);

            seconds_lyric = new Clutter.Text ();
            seconds_lyric.ellipsize = Pango.EllipsizeMode.END;
            seconds_lyric.background_color = Clutter.Color.from_string ("black") { alpha = 100 };
            seconds_lyric.line_alignment = Pango.Alignment.CENTER;
            seconds_lyric.single_line_mode = true;
            seconds_lyric.use_markup = true;
            stage.add_child (seconds_lyric);

            title_music = new Clutter.Text ();
            title_music.ellipsize = Pango.EllipsizeMode.END;
            title_music.color = Clutter.Color.from_string ("white");
            title_music.background_color = Clutter.Color.from_string ("black") { alpha = 100 };
            title_music.font_name = "Bitstream Vera Sans Bold 16";
            title_music.line_alignment = Pango.Alignment.CENTER;
            title_music.single_line_mode = true;
            title_music.use_markup = true;
            stage.add_child (title_music);

            artist_music = new Clutter.Text ();
            artist_music.ellipsize = Pango.EllipsizeMode.END;
            artist_music.color = Clutter.Color.from_string ("white");
            artist_music.background_color = Clutter.Color.from_string ("black") { alpha = 100 };
            artist_music.font_name = "Lato 17";
            artist_music.line_alignment = Pango.Alignment.CENTER;
            artist_music.single_line_mode = true;
            artist_music.use_markup = true;
            stage.add_child (artist_music);

            right_bar = new RightBar (this);
            right_actor = new GtkClutter.Actor ();
            right_actor.contents = right_bar;
            right_actor.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            right_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.X_AXIS, 1));
            right_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 1));
            stage.add_child (right_actor);

            top_bar = new TopBar (this);
            top_actor = new GtkClutter.Actor ();
            top_actor.contents = top_bar;
            top_actor.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            top_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 0));
            top_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            stage.add_child (top_actor);

            notifybottombar = new NotifyBottomBar (this);
            bottom_actor_notif = new GtkClutter.Actor ();
            bottom_actor_notif.contents = notifybottombar;
            bottom_actor_notif.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            bottom_actor_notif.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 1));
            bottom_actor_notif.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 1));
            stage.add_child (bottom_actor_notif);
            bottom_bar = new BottomBar (this);
            bottom_bar.bind_property ("playing", playback, "playing", BindingFlags.BIDIRECTIONAL);
            bottom_actor = new GtkClutter.Actor ();
            bottom_actor.contents = bottom_bar;
            bottom_actor.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            bottom_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 1));
            bottom_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 1));
            stage.add_child (bottom_actor);

            stage.motion_event.connect ((event) => {
                if (!bottom_bar.child_revealed) {
                    if (event.y > (stage.height - 30)) {
                        bottom_bar.reveal_control ();
                    }
                }
                if (!top_bar.child_revealed) {
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
                if (event.button == Gdk.BUTTON_PRIMARY && event.type == Gdk.EventType.2BUTTON_PRESS && !right_bar.hovered && !top_bar.hovered && !bottom_bar.hovered) {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }

                if (event.button == Gdk.BUTTON_SECONDARY && !right_bar.hovered && !top_bar.hovered && !bottom_bar.hovered) {
                    playback.playing = !playback.playing;
                    string_notify (playback.playing? _("Play") : _("Pause"));
                }
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect (() => {
                return mouse_hovered = false;
            });
            right_bar.playlist.play.connect (play_file);
            bottom_bar.notify["child-revealed"].connect (mouse_blank);
            top_bar.notify["child-revealed"].connect (mouse_blank);
            right_bar.notify["child-revealed"].connect (mouse_blank);
            right_bar.playlist.item_added.connect (load_current_list);

            playback.eos.connect (() => {
                playback.progress = 0;
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
                            Inhibitor.instance.uninhibit ();
                        }
                        break;
                }
            });

            playback.notify["progress"].connect (() => {
                if (playback.playing) {
                    if (NikiApp.settings.get_boolean("lyric-available") && NikiApp.settings.get_boolean("audio-video")) {
                        update_position_cover ();
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
                if (!NikiApp.settings.get_boolean("fullscreen")) {
                    string_notify (_("Press ESC to exit full screen"));
                } else {
                    notify_blank ();
                    if (notify_timer != 0) {
                        Source.remove (notify_timer);
                    }
                    notify_timer = 0;
                }
            });
            NikiApp.settings.changed["blur-mode"].connect (update_bg);
            NikiApp.settings.changed["information-button"].connect (()=> {
                seek_music ();
                update_position_cover ();
            });

            bottom_bar.notify["child-revealed"].connect (() => {
                notifybottombar.set_reveal_child (false);
            });

            playback.ready.connect (()=> {
                signal_window ();
                if (video_width > 0 && video_height > 0) {
                    resize_player_page (window, video_width, video_height);
                }
            });
            size_allocate.connect (signal_window);
            NikiApp.settings.changed["home-signal"].connect (() => {
                if (!NikiApp.settings.get_boolean("home-signal")) {
                    if (NikiApp.settings.get_boolean("audio-video")) {
                        window.resize (420, 420);
                        resize_player_page (window, 420, 420);
                    }
                }
            });
            NikiApp.settings.changed["audio-video"].connect (() => {
                if (NikiApp.settings.get_boolean("audio-video")) {
                    window.resize (420, 420);
                    resize_player_page (window, 420, 420);
                }
                audiovisualisation ();
            });
            NikiApp.settings.changed["visualisation-options"].connect (audiovisualisation);
            audiovisualisation ();
            Idle.add (starting);
            window.welcome_page.getlink.errormsg.connect (string_notify);
            NikiApp.settings.changed["location-save"].connect (reloadlrc);
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
        public void home_open () {
            save_lasplay ();
            playback.playing = false;
            playback.uri = null;
            Inhibitor.instance.uninhibit ();
            if (NikiApp.window.main_stack.visible_child_name == "player") {
                if (!NikiApp.settings.get_boolean("home-signal")) {
                    NikiApp.settings.set_boolean("home-signal", true);
                }
                NikiApp.window.main_stack.visible_child_name = "welcome";
                NikiApp.window.resize (570, 430);
                resize_player_page (NikiApp.window, 570, 430);
            }
            NikiApp.settings.set_string("last-played", " ");
            NikiApp.settings.set_string("uri-video", " ");
            mouse_blank ();
            right_bar.playlist.clear_items ();
        }

        private void update_bg () {
            if (NikiApp.settings.get_boolean("audio-video")) {
                audio_banner ();
            }
        }
        public void load_current_list () {
            if (NikiApp.window.main_stack.visible_child_name == "player" && !NikiApp.settings.get_boolean("home-signal") && playback.uri != null) {
                right_bar.playlist.set_current (playback.uri, this);
            }
        }
        private void buffer_fill () {
            string_notify (@"$(_("Buffering"))$(((int)(playback.get_buffer_fill () * 100)).to_string ())%" );
        }
        public bool starting () {
            if (!playback.playing) {
                if (is_privacy_mode_enabled () && !NikiApp.settings.get_boolean("home-signal")) {
                    if (file_exists (NikiApp.settings.get_string("last-played"))) {
                        NikiApp.window.welcome_page.index_but = 3;
                        NikiApp.window.welcome_page.stack.visible_child_name = "circular";
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
            if (NikiApp.settings.get_boolean("audio-video")){
                audio_banner ();
                NikiApp.window.resize (420, 420);
            }
            if (!NikiApp.settings.get_string("last-played").has_prefix ("http")) {
                right_bar.playlist.play_starup (NikiApp.settings.get_string("last-played"), this);
                playback.playing = false;
            }
        }
        private void gohome () {
            if (!NikiApp.settings.get_boolean("home-signal")) {
                NikiApp.settings.set_boolean("home-signal", true);
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
                ((Clutter.Text)item).font_name = NikiApp.settings.get_string("font");
            }
        }
        public void seek_music () {
            if (NikiApp.settings.get_boolean("audio-video") && !NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean ("lyric-button") && NikiApp.settings.get_boolean("lyric-available")) {
                for (int i = 0; i < menu_actor.get_n_children (); i++) {
                    Clutter.Actor menu = scroll.get_first_child ();
                    Clutter.Actor item = menu.get_child_at_index (i);
                    ((Clutter.Text)item).color = Clutter.Color.from_string ("white");
                }
            }
        }
        public Clutter.Actor text_clutter (string name) {
            var lyric_sc = new Clutter.Text ();
            lyric_sc.set_text (name);
            lyric_sc.font_name = NikiApp.settings.get_string("font");
            lyric_sc.color = Clutter.Color.from_string ("white");
            lyric_sc.background_color = Clutter.Color.from_string ("black") { alpha = 100 };
            lyric_sc.set_margin_left (12);
            lyric_sc.set_margin_right (12);
            return lyric_sc;
        }

        public void save_destroy () {
            if (!NikiApp.settings.get_boolean ("home-signal")) {
                if (playback.uri != null) {
                    if (playback.uri.has_prefix ("http")) {
                        NikiApp.settings.set_string("last-played", " ");
                        NikiApp.settings.set_string("uri-video", " ");
                        NikiApp.settings.set_boolean("home-signal", true);
                    } else {
                        save_lasplay ();
                        NikiApp.settings.set_string ("last-played", NikiApp.settings.get_string("uri-video"));
                        right_bar.playlist.save_playlist ();

                    }
                }
            }
        }
        private void save_lasplay () {
            if (!NikiApp.settings.get_boolean("audio-video")) {
                insert_last_video (playback.uri, seconds_to_time ((int) (playback.progress * playback.duration)), playback.progress);
            } else {
                insert_last_music (playback.uri, playback.progress);
            }
        }
        public void signal_window () {
            if (NikiApp.settings.get_boolean("audio-video")) {
                int height;
                NikiApp.window.get_size (null, out height);
                menu_actor.height = height - 150;
                update_position_cover ();
            }
            if (notify_timer > 0 ) {
                notify_text.x = (stage.width / 2) - (notify_text.width / 2);
                notify_text.y = ((stage.height / 8) - (notify_text.height / 2));
            }
        }

        private bool audio_banner () {
            Gdk.Pixbuf preview = null;
            Gdk.Pixbuf cover = null;
            switch (NikiApp.settings.get_enum ("player-mode")) {
                case PlayerMode.AUDIO :
                    if (file_exists (NikiApp.settings.get_string("uri-video"))) {
                        Gdk.Pixbuf pixt = pix_from_tag (get_discoverer_info (NikiApp.settings.get_string("uri-video")).get_tags ());
                        cover = align_and_scale_pixbuf (pixt, 256);
                        preview = align_and_scale_pixbuf (pixt, 764);
                    }
                    break;
                case PlayerMode.STREAMAUD :
                    cover = align_and_scale_pixbuf (unknown_cover (), 256);
                    preview = align_and_scale_pixbuf (unknown_cover (), 764);
                    break;
            }
            if (preview != null) {
                try {
                    cover_img.set_data (cover.get_pixels (), Cogl.PixelFormat.RGB_888, cover.width, cover.height, cover.rowstride);
                    oriimage.set_data (preview.get_pixels (), Cogl.PixelFormat.RGB_888, preview.width, preview.height, preview.rowstride);
	            } catch (Error e) {
                    GLib.warning (e.message);
	            }
                audiovisualisation ();
	        }
	        return Source.REMOVE;
        }

        private void audiovisualisation () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                set_size_request (420, 420);
            } else {
                set_size_request (100, 150);
            }
            switch (NikiApp.settings.get_int ("visualisation-options")) {
                case 0 :
                    if (!NikiApp.settings.get_boolean("audio-video")) {
                        stage.content = clutter_content;
                    } else {
                        stage.content = oriimage;
                        seek_music ();
                    }
                    break;
                case 1 :
                    stage.content = clutter_content;
                    break;
            }
        }

        private void update_position_cover () {
            scroll.x = NikiApp.settings.get_boolean("audio-video") && !NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean ("lyric-button") && NikiApp.settings.get_boolean("lyric-available")? (stage.width / 2) - (scroll.width / 2) : -scroll.width;
            scroll.y = NikiApp.settings.get_boolean("audio-video") && !NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean ("lyric-button") && NikiApp.settings.get_boolean("lyric-available")? ((stage.height / 2) - (scroll.height / 2)) : -scroll.height;
            cover_center.x = NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("information-button")? (stage.width / 2) - (cover_center.width / 2) : -cover_center.width;
            cover_center.y = NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("information-button")? ((stage.height / 2) - (cover_center.height / 2) - 50) : -cover_center.height;
            title_music.x = NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("information-button")? ((stage.width / 2) - (title_music.width / 2)) : -title_music.width;
            title_music.y = NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("information-button")? ((stage.height / 2) - (title_music.height / 2) + 90) : -artist_music.height;
            artist_music.x = NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("information-button")? ((stage.width / 2) - (artist_music.width / 2)) : -artist_music.width;
            artist_music.y = NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("information-button")? ((stage.height / 2) - (artist_music.height / 2) + (92 + title_music.height)) : -artist_music.height;
            first_lyric.x = NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean("lyric-available") && NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("lyric-button")? ((stage.width / 2) - (first_lyric.width / 2)) : -first_lyric.width;
            first_lyric.y = NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean("lyric-available") && NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("lyric-button")? ((stage.height / 2) - (first_lyric.height / 2) + (125 + artist_music.height)) : -first_lyric.height;
            seconds_lyric.x = NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean("lyric-available") && NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("lyric-button")? ((stage.width / 2) - (seconds_lyric.width / 2)) : -seconds_lyric.width;
            seconds_lyric.y = NikiApp.settings.get_boolean ("information-button") && NikiApp.settings.get_boolean("lyric-available") && NikiApp.settings.get_boolean("audio-video") && NikiApp.settings.get_boolean ("lyric-button")? ((stage.height / 2) - (seconds_lyric.height / 2) + (155 + first_lyric.height)) : -seconds_lyric.height;
        }

        public void resize_player_page (Window window, int width, int height) {
            if (!NikiApp.settings.get_boolean("audio-video")) {
                window.resize (width, height);
            }
            double widths = width / 2;
            double heights = height / 2;
            double aspect_max = widths / heights;
            double limit = aspect_max > 1.5? (aspect_max < 1.9? 0.1977777777777777 : 0.3277777777777777) : 0.1033333333333337;
            geometry.min_aspect = aspect_max > 1? aspect_max - limit : aspect_max + limit;
            geometry.max_aspect = aspect_max > 1? aspect_max - limit : aspect_max + limit;
            window.set_geometry_hints (window, geometry, !NikiApp.settings.get_boolean("audio-video") && NikiApp.window.main_stack.visible_child_name == "player"? Gdk.WindowHints.ASPECT : Gdk.WindowHints.USER_SIZE);
        }

        private void font_option () {
            playback.set_subtitle_font_name (NikiApp.settings.get_int("font-options") == 0? "" : NikiApp.settings.get_string("font"));
            first_lyric.font_name = seconds_lyric.font_name = NikiApp.settings.get_string("font");
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
            } else if (NikiApp.window.main_stack.visible_child_name == "player"){
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
            NikiApp.settings.set_enum ("player-mode", mediatype);
            top_bar.label_info.set_label (NikiApp.settings.get_string("title-playing") + filesize);
            top_bar.info_label_full.set_label (NikiApp.settings.get_string("title-playing") + filesize);
            if (uri.has_prefix ("http")) {
                NikiApp.settings.set_string("uri-video", uri);
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
                    playback.progress = lastplay_video (uri);
                }
                if (get_mime_type (File.new_for_uri (uri)).has_prefix ("audio/")) {
                    playback.uri = uri;
                    playback.progress = lastplay_music (uri);
                }
                NikiApp.settings.set_string("uri-video", uri);
                sub_lr_check (uri);
                playback.playing = from_beginning;
                signal_playing ();
            }
            if (NikiApp.settings.get_boolean("home-signal")) {
                NikiApp.settings.set_boolean("home-signal", false);
                NikiApp.window.main_stack.visible_child_name = "player";
            }
        }
        private void check_lr_sub () {
            if (NikiApp.settings.get_boolean("subtitle-available")) {
                NikiApp.settings.set_boolean("subtitle-available", false);
                bottom_bar.menu_popover.file_chooser_subtitle.select_uri ("");
            }
            if (NikiApp.settings.get_boolean("lyric-available")) {
                NikiApp.settings.set_boolean("lyric-available", false);
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
                NikiApp.settings.set_boolean("subtitle-available", true);
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
                    if (run_open_folder (2, NikiApp.window)) {
                        var file_uri = File.new_build_filename (NikiApp.settings.get_string ("ask-lyric"), file.get_basename ());
                        lyric_uri = get_playing_lyric (file_uri.get_uri ());
                    }
                    break;
            }
            if (lyric_uri != null) {
                bottom_bar.seekbar_widget.on_lyric_update (file_lyric (lyric_uri), this);
                NikiApp.settings.set_boolean("lyric-available", true);
            }
        }

        public void signal_playing () {
            bottom_bar.stop_revealer.set_reveal_child (true);
            if (NikiApp.settings.get_enum ("player-mode") == PlayerMode.VIDEO || NikiApp.settings.get_enum ("player-mode") == PlayerMode.STREAMVID) {
                if (NikiApp.settings.get_boolean("audio-video")) {
                    NikiApp.settings.set_boolean("audio-video", false);
                }
                if (playback.playing) {
                    Inhibitor.instance.inhibit ();
                } else {
                    Inhibitor.instance.uninhibit ();
                }
            } else {
                if (!NikiApp.settings.get_boolean("audio-video")) {
                    NikiApp.settings.set_boolean("audio-video", true);
                }
                if (NikiApp.settings.get_boolean ("lyric-button") && NikiApp.settings.get_boolean ("lyric-available") && playback.playing && !return_hide_mode) {
                    Inhibitor.instance.inhibit ();
                } else {
                    Inhibitor.instance.uninhibit ();
                }
                title_music.text = @" $(NikiApp.settings.get_string ("title-playing")) ";
                artist_music.text = @" $(NikiApp.settings.get_string ("artist-music")) ";
                Idle.add (audio_banner);
            }
            update_position_cover ();
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
            if (NikiApp.settings.get_int ("speed-playing") != 4) {
                playback.pipeline.set_state (Gst.State.PAUSED);
            }
            var duration = playback.duration;
            var progress = playback.progress;
            var new_progress = ((duration * progress) + (double)seconds)/duration;
            playback.progress = new_progress.clamp (0.0, 1.0);
            if (NikiApp.settings.get_int ("speed-playing") != 4) {
                if (playback.playing) {
                    playback.pipeline.set_state (Gst.State.PLAYING);
                }
            }
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
            notify_text.text = @"\n     $(notify_string)     \n";
            notify_control ();
        }
    }
}
