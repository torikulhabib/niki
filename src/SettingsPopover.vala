namespace niki {
    public class SettingsPopover : Gtk.Popover {
        private ComboxImage? languages;
        private ComboxImage? subtitles;
        private ComboxImage? combox_font;
        private PlayerPage? playerpage;
        private Gtk.Revealer label_audio_revealer;
        private Gtk.Revealer audio_track_revealer;
        private Gtk.Revealer sub_label_revealer;
        private Gtk.Revealer subtitles_revealer;
        private Gtk.Revealer combox_font_label_revealer;
        private Gtk.Revealer combox_font_revealer;
        private Gtk.Revealer font_selection_label_revealer;
        private Gtk.Revealer font_selection_btn_revealer;
        private Gst.PbUtils.DiscovererInfo discoverer_info;
        private Gtk.Grid grid;
        public signal void font_button ();

        public SettingsPopover (PlayerPage playerpage) {
            this.playerpage = playerpage;
            var languange_label = new Gtk.Label (StringPot.Audio);
            languange_label.halign = Gtk.Align.END;
            label_audio_revealer = new Gtk.Revealer ();
            label_audio_revealer.add (languange_label);
            label_audio_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            label_audio_revealer.transition_duration = 500;

            languages = new ComboxImage ();
            audio_track_revealer = new Gtk.Revealer ();
            audio_track_revealer.add (languages);
            audio_track_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            audio_track_revealer.transition_duration = 500;

            var sub_label = new Gtk.Label (StringPot.Internal_Sub);
            sub_label.halign = Gtk.Align.END;
            sub_label_revealer = new Gtk.Revealer ();
            sub_label_revealer.add (sub_label);
            sub_label_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            sub_label_revealer.transition_duration = 500;

            subtitles = new ComboxImage ();
            subtitles_revealer = new Gtk.Revealer ();
            subtitles_revealer.add (subtitles);
            subtitles_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            subtitles_revealer.transition_duration = 500;

            var combox_font_label = new Gtk.Label (StringPot.Font_Options);
            combox_font_label.halign = Gtk.Align.END;
            combox_font_label_revealer = new Gtk.Revealer ();
            combox_font_label_revealer.add (combox_font_label);
            combox_font_label_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            combox_font_label_revealer.transition_duration = 500;

            combox_font = new ComboxImage ();
            combox_font.appending ("emblem-default-symbolic", StringPot.Default_Font);
            combox_font.appending ("document-properties-symbolic", StringPot.Custom_Font);
            combox_font_revealer = new Gtk.Revealer ();
            combox_font_revealer.add (combox_font);
            combox_font_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            combox_font_revealer.transition_duration = 500;

            var font_selection_label = new Gtk.Label (StringPot.Customs);
            font_selection_label.halign = Gtk.Align.END;
            font_selection_label_revealer = new Gtk.Revealer ();
            font_selection_label_revealer.add (font_selection_label);
            font_selection_label_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            font_selection_label_revealer.transition_duration = 500;

            var font_selection_btn = new Gtk.FontButton ();
            font_selection_btn_revealer = new Gtk.Revealer ();
            font_selection_btn_revealer.add (font_selection_btn);
            font_selection_btn_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            font_selection_btn_revealer.transition_duration = 500;
            font_button.connect (() => {
                font_selection_btn.clicked ();
            });
            NikiApp.settings.changed["subtitle-available"].connect (revealer_view);

            var Speed_label = new Gtk.Label (StringPot.Play_Speed);
            Speed_label.margin_bottom = 1;
            Speed_label.halign = Gtk.Align.END;
            var speed_combox = new ComboxImage ();
            speed_combox.appending ("media-playback-start-symbolic", _("0.25"));
            speed_combox.appending ("media-playback-start-symbolic", _("0.5"));
            speed_combox.appending ("media-playback-start-symbolic", _("0.75"));
            speed_combox.appending ("media-playback-start-symbolic", _("0.90"));
            speed_combox.appending ("media-playback-start-symbolic", _("Normal"));
            speed_combox.appending ("media-playback-start-symbolic", _("1.25"));
            speed_combox.appending ("media-playback-start-symbolic", _("1.5"));
            speed_combox.appending ("media-playback-start-symbolic", _("1.75"));
            speed_combox.appending ("media-playback-start-symbolic", _("2.0"));
            speed_combox.margin_bottom = 1;

            var ex_subtitle_label = new Gtk.Label (StringPot.External_Sub);
            ex_subtitle_label.halign = Gtk.Align.END;
            var file_chooser_subtitle = new Gtk.FileChooserButton (StringPot.Pick_File, Gtk.FileChooserAction.OPEN);

            var all_files_filter = new Gtk.FileFilter ();
            all_files_filter.set_filter_name (StringPot.All_Files);
            all_files_filter.add_pattern ("*");
            var subtitle_files_filter = new Gtk.FileFilter ();
            subtitle_files_filter.set_filter_name (StringPot.Subtitle_Files);
            subtitle_files_filter.add_mime_type ("application/smil");
            subtitle_files_filter.add_mime_type ("application/x-subrip");
            subtitle_files_filter.add_mime_type ("text/x-microdvd");
            subtitle_files_filter.add_mime_type ("text/x-ssa");
            file_chooser_subtitle.add_filter (subtitle_files_filter);
            file_chooser_subtitle.add_filter (all_files_filter);

            NikiApp.settings.changed["subtitle-choose"].connect (() => {
                file_chooser_subtitle.select_uri (NikiApp.settings.get_string("subtitle-choose"));
            });
            file_chooser_subtitle.file_set.connect (() => {
                if (is_subtitle (file_chooser_subtitle.get_uri())) {
                    NikiApp.settings.set_string("subtitle-choose", file_chooser_subtitle.get_uri());
                    if (!NikiApp.settings.get_boolean("subtitle-available")) {
                        NikiApp.settings.set_boolean ("subtitle-available", true);
                    }
                } else {
                    file_chooser_subtitle.select_uri (NikiApp.settings.get_string("subtitle-choose"));
                }
            });

            grid = new Gtk.Grid ();
            grid.margin = 2;
            grid.attach (label_audio_revealer, 0, 0);
            grid.attach (audio_track_revealer, 1, 0);
            grid.attach (sub_label_revealer, 0, 1);
            grid.attach (subtitles_revealer, 1, 1);
            grid.attach (combox_font_label_revealer, 0, 2);
            grid.attach (combox_font_revealer, 1, 2);
            grid.attach (font_selection_label_revealer , 0, 3);
            grid.attach (font_selection_btn_revealer, 1, 3);
            grid.attach (Speed_label, 0, 4);
            grid.attach (speed_combox, 1, 4);
            grid.attach (ex_subtitle_label, 0, 5);
            grid.attach (file_chooser_subtitle, 1, 5);
            grid.show_all ();
            add (grid);
            NikiApp.settings.bind ("speed-playing", speed_combox, "active", GLib.SettingsBindFlags.DEFAULT);
            NikiApp.settings.bind ("font-options", combox_font, "active", GLib.SettingsBindFlags.DEFAULT);
            NikiApp.settings.bind ("font", font_selection_btn, "font", GLib.SettingsBindFlags.DEFAULT);

            combox_font.changed.connect (revealer_view);
            subtitles.changed.connect (on_subtitles_changed);
            languages.changed.connect (on_languages_changed);
            revealer_view ();
            playerpage.playback.ready.connect (subtitle_audio_track);
            NikiApp.settings.changed["activate-subtitle"].connect (()=> {
                subtitles.sensitive = NikiApp.settings.get_boolean ("activate-subtitle")? true : false;
            });
        }

        private void revealer_view () {
            combox_font_label_revealer.set_reveal_child (NikiApp.settings.get_boolean ("subtitle-available"));
            combox_font_revealer.set_reveal_child (NikiApp.settings.get_boolean ("subtitle-available"));
            font_selection_label_revealer.set_reveal_child (combox_font.get_active_int () == 0 || !combox_font_revealer.child_revealed? false : true);
            font_selection_btn_revealer.set_reveal_child (combox_font.get_active_int () == 0 || !combox_font_revealer.child_revealed? false : true);
            grid.row_spacing = grid.column_spacing = NikiApp.settings.get_boolean ("subtitle-available")? 2 : 0;
        }
        private uint remove_timer = 0;
        public void subtitle_audio_track () {
            if (remove_timer != 0) {
                Source.remove (remove_timer);
            }
            remove_timer = GLib.Timeout.add_seconds (1, () => {
                if (!NikiApp.settings.get_boolean ("audio-video") && playerpage.playback.uri != null) {
                    get_discoverer_info (playerpage.playback.uri);
                    revealer_view ();
                    subtitles_track ();
                    audio_track ();
                }
                remove_timer = 0;
                return Source.REMOVE;
            });
        }
        private void on_subtitles_changed () {
            if (subtitles.active < 0) {
                return;
            }
            playerpage.playback.subtitle_track = subtitles.active;
        }

        private void subtitles_track () {
            subtitles.changed.disconnect (on_subtitles_changed);
            if (subtitles.model.iter_n_children (null) >= 0) {
                subtitles.remove_all ();
            }
            GLib.List<string> subtitles_names = get_subtitle_track_names ();
            uint track = 1;
            foreach (string? subtitle in playerpage.playback.subtitle_tracks) {
                if (subtitle == null) {
                    continue;
                }
                if (subtitles_names.nth_data (track - 1) == null) {
                    subtitles.appending ("com.github.torikulhabib.niki.subtitle-on-symbolic", _("%s %u").printf (StringPot.Track, track));
                } else {
                    subtitles.appending ("com.github.torikulhabib.niki.subtitle-on-symbolic", _("%s %u").printf (subtitles_names.nth_data (track - 1), track));
                }
                track ++;
                if (!NikiApp.settings.get_boolean("subtitle-available")) {
                    NikiApp.settings.set_boolean ("subtitle-available", true);
                }
                if (!NikiApp.settings.get_boolean("activate-subtitle")) {
                    NikiApp.settings.set_boolean ("activate-subtitle", true);
                }
            }

            int count = subtitles.model.iter_n_children (null);
            sub_label_revealer.reveal_child = subtitles_revealer.reveal_child = count > 0;
            if (subtitles_revealer.reveal_child && (playerpage.playback.subtitle_track >= 0)) {
                subtitles.active = playerpage.playback.subtitle_track;
            }
            subtitles.changed.connect (on_subtitles_changed);
        }

        private GLib.List<string> get_subtitle_track_names () {
            var subtitles_streams = discoverer_info.get_subtitle_streams ();
            GLib.List<string> subtitle_languages = null;
            foreach (var subtitle_stream in subtitles_streams) {
                unowned string language_code = (subtitle_stream as Gst.PbUtils.DiscovererSubtitleInfo).get_language ();
                if (language_code == null) {
                    return subtitle_languages;
                }
                var language_name = Gst.Tag.get_language_name (language_code);
                subtitle_languages.append (language_name);
            }
            subtitle_languages.reverse ();
            return subtitle_languages;
        }

        private void on_languages_changed () {
            if (languages.active < 0 || languages.get_active_name () == StringPot.Default) {
                return;
            }
            playerpage.playback.audio_stream = languages.active;
        }

        private void audio_track () {
            languages.changed.disconnect (on_languages_changed);
            if (languages.model.iter_n_children (null) >= 0) {
                languages.remove_all ();
            }
            GLib.List<string> languages_names = get_audio_track_names ();
            uint track = 1;
            foreach (var stream in playerpage.playback.audio_streams) {
                if (stream == null) {
                    continue;
                }
                if (languages_names.nth_data (track - 1) == null) {
                    languages.appending ("audio-input-microphone-symbolic", _("%s %u").printf (StringPot.Track, track));
                } else {
                    languages.appending ("audio-input-microphone-symbolic", _("%s %u").printf (languages_names.nth_data (track - 1), track));
                }
                track ++;
            }

            int count = languages.model.iter_n_children (null);
            label_audio_revealer.reveal_child = audio_track_revealer.reveal_child = count > 1;
            if (audio_track_revealer.reveal_child) {
                languages.active = playerpage.playback.audio_stream;
            } else {
                if (count != 0) {
                    languages.remove_all ();
                }
                languages.appending ("microphone-sensitivity-muted-symbolic", StringPot.Default);
                languages.active = 0;
            }
            languages.changed.connect (on_languages_changed);
        }
        private GLib.List<string> get_audio_track_names () {
            var audio_streams = discoverer_info.get_audio_streams ();
            GLib.List<string> audio_languages = null;
            foreach (var audio_stream in audio_streams) {
                unowned string language_code = (audio_stream as Gst.PbUtils.DiscovererAudioInfo).get_language ();
                if (language_code == null) {
                    return audio_languages;
                }
                var language_name = Gst.Tag.get_language_name (language_code);
                audio_languages.append (language_name);
            }
            audio_languages.reverse ();
            return audio_languages;
        }

        private void get_discoverer_info (string uri_video) {
            try {
                Gst.PbUtils.Discoverer discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
                discoverer_info = discoverer.discover_uri (uri_video);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}
