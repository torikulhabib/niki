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
    public class MediaEditor : Gtk.Dialog {
        private Gtk.TextView comment_textview;
        private Gtk.SpinButton date_spinbutton;
        private Gtk.SpinButton track_spinbutton;
        private Gtk.Image? asyncimage;
        private Gtk.Image? video_asyncimage;
        private Gtk.Label label_duration;
        private Gtk.Label label_bitrate;
        private Gtk.Label label_chanel;
        private Gtk.Label label_sample;
        private Gtk.Label label_name;
        private Gtk.Label container;
        private Gtk.Label container_video;
        private Gtk.Label container_audio;
        private MediaEntry? title_entry;
        private MediaEntry? artist_entry;
        private MediaEntry? album_entry;
        private MediaEntry? genre_entry;
        private MediaEntry? duration_video;
        private MediaEntry? pixel_ratio;
        private MediaEntry? sekable_video;
        private MediaEntry? audio_codec;
        private MediaEntry? video_codec;
        private MediaEntry? date_time_video;
        private MediaEntry? interlaced;
        private MediaEntry? container_format;
        private MediaEntry? video_height;
        private MediaEntry? video_width;
        private MediaEntry? video_bitrate;
        private MediaEntry? video_bitrate_max;
        private MediaEntry? frame_rate;
        private MediaEntry? video_depth;
        private MediaEntry? audio_bitrate;
        private MediaEntry? audio_bitrate_max;
        private MediaEntry? audio_language;
        private MediaEntry? audio_chanel;
        private MediaEntry? audio_samplerate;
        private MediaEntry? audio_depth;
        private Gtk.Stack stack;
        private Playlist? playlist;
        private Gtk.Label label;
        private Gtk.Label header_label;
        private Gtk.Spinner spinner;
        private Gtk.Revealer prog_revealer;
        private Gtk.Revealer save_revealer;
        private Gtk.Revealer clear_revealer;
        private uint hiding_timer = 0;
        public signal void update_file (string file_name);

        public MediaEditor (Playlist playlist) {
            Object (
                resizable: true,
                deletable: false,
                use_header_bar: 1,
                skip_taskbar_hint: true,
                transient_for: NikiApp.window,
                destroy_with_parent: true
            );
            this.playlist = playlist;
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            resize (425, 380);

            header_label = new Gtk.Label (null) {
                halign = Gtk.Align.CENTER,
                hexpand = true,
                can_focus = true
            };
            header_label.get_style_context ().add_class ("h4");

            title_entry = new MediaEntry ("com.github.torikulhabib.niki.title-symbolic","edit-paste-symbolic");
            title_entry.tooltip_notify.connect (info_send);
            artist_entry = new MediaEntry ("avatar-default-symbolic", "edit-paste-symbolic");
            artist_entry.tooltip_notify.connect (info_send);
            album_entry = new MediaEntry ("media-optical-symbolic", "edit-paste-symbolic");
            album_entry.tooltip_notify.connect (info_send);
            genre_entry = new MediaEntry ("audio-x-generic-symbolic", "edit-paste-symbolic");
            genre_entry.tooltip_notify.connect (info_send);

            comment_textview = new Gtk.TextView ();
            comment_textview.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            comment_textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);

            var comment_scr = new Gtk.ScrolledWindow (null, null) {
                expand = true,
                margin_end = 10
            };
            comment_scr.get_style_context ().add_class ("dlna_scrollbar");
            comment_scr.get_style_context ().add_class ("frame");
            comment_scr.set_policy (Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.AUTOMATIC);
            comment_scr.add (comment_textview);

            var local_time = new DateTime.now_local ();
            date_spinbutton = new Gtk.SpinButton.with_range (0, local_time.get_year (), 1) {
                focus_on_click = false,
                margin_end = 10
            };
            date_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            track_spinbutton = new Gtk.SpinButton.with_range (0, 500, 1) {
                focus_on_click = false,
                margin_end = 10
            };
            track_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            asyncimage = new Gtk.Image () {
                pixel_size = 85,
                margin_end = 5
            };

            var openimage = new Gtk.Button () {
                focus_on_click = false
            };
            openimage.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            openimage.get_style_context ().add_class ("transparantbg");
            openimage.add (asyncimage);
            openimage.clicked.connect (()=> {
                var file = run_open_file (this, false, 2);
                if (file != null) {
                    select_image (file[0].get_path ());
                }
            });

            label_duration = new Gtk.Label (null) {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END
            };
            label_bitrate = new Gtk.Label (null) {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END
            };
            label_sample = new Gtk.Label (null) {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END
            };
            label_chanel = new Gtk.Label (null) {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END
            };

            var grid_label = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                valign = Gtk.Align.CENTER
            };
            grid_label.add (label_duration);
            grid_label.add (label_bitrate);
            grid_label.add (label_sample);
            grid_label.add (label_chanel);
            grid_label.show_all ();

            var imagege_box = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER,
                hexpand = true
            };
            imagege_box.get_style_context ().add_class ("ground_action_button");
            imagege_box.add (openimage);
            imagege_box.add (grid_label);

            var grid = new Gtk.Grid () {
                expand = true,
                margin_start = 10
            };
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.attach (new HeaderLabel (_("Cover:"), 200), 0, 0, 1, 1);
            grid.attach (imagege_box, 0, 1, 1, 1);
            grid.attach (new HeaderLabel (_("Comment:"), 200), 1, 0, 1, 1);
            grid.attach (comment_scr, 1, 1, 1, 1);
            grid.attach (new HeaderLabel (_("Tittle:"), 200), 0, 2, 1, 1);
            grid.attach (title_entry, 0, 3, 1, 1);
            grid.attach (new HeaderLabel (_("Artist:"), 200), 1, 2, 1, 1);
            grid.attach (artist_entry, 1, 3, 1, 1);
            grid.attach (new HeaderLabel (_("Album:"), 200), 0, 4, 1, 1);
            grid.attach (album_entry, 0, 5, 1, 1);
            grid.attach (new HeaderLabel (_("Genre:"), 200), 1, 4, 1, 1);
            grid.attach (genre_entry, 1, 5, 1, 1);
            grid.attach (new HeaderLabel (_("Track:"), 200), 0, 6, 1, 1);
            grid.attach (track_spinbutton, 0, 7, 1, 1);
            grid.attach (new HeaderLabel (_("Date:"), 200), 1, 6, 1, 1);
            grid.attach (date_spinbutton, 1, 7, 1, 1);

            label_name = new Gtk.Label (null) {
                hexpand = true,
                halign = Gtk.Align.CENTER,
                ellipsize = Pango.EllipsizeMode.MIDDLE
            };
            label_name.get_style_context ().add_class ("h4");

            var previous_button = new Gtk.Button.from_icon_name ("go-previous-symbolic") {
                focus_on_click = false
            };
            previous_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            previous_button.get_style_context ().add_class ("transparantbg");
            previous_button.clicked.connect (previous_track);

            var next_button = new Gtk.Button.from_icon_name ("go-next-symbolic") {
                focus_on_click = false
            };
            next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            next_button.get_style_context ().add_class ("transparantbg");
            next_button.clicked.connect (next_track);

            var header = get_header_bar ();
            header.set_custom_title (header_label);
            header.pack_start (previous_button);
            header.pack_end (next_button);

            container = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                halign = Gtk.Align.START,
                margin = 2,
                margin_end = 10
            };
            container_audio = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                halign = Gtk.Align.START,
                margin = 2,
                margin_end = 10
            };
            container_video = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                halign = Gtk.Align.START,
                margin = 2,
                margin_end = 10
            };

            duration_video = new MediaEntry ("tools-timer-symbolic", "", false);
            duration_video.tooltip_notify.connect (info_send);
            pixel_ratio = new MediaEntry ("view-fullscreen-symbolic", "", false);
            pixel_ratio.tooltip_notify.connect (info_send);
            sekable_video = new MediaEntry ("media-seek-forward-symbolic", "", false);
            sekable_video.tooltip_notify.connect (info_send);
            audio_codec = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_codec.tooltip_notify.connect (info_send);
            video_codec = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_codec.tooltip_notify.connect (info_send);
            date_time_video = new MediaEntry ("x-office-calendar-symbolic", "", false);
            date_time_video.tooltip_notify.connect (info_send);
            interlaced = new MediaEntry ("insert-link-symbolic", "", false);
            interlaced.tooltip_notify.connect (info_send);
            video_width = new MediaEntry ("video-display-symbolic", "", false);
            video_width.tooltip_notify.connect (info_send);
            video_height = new MediaEntry ("video-display-symbolic", "", false);
            video_height.tooltip_notify.connect (info_send);
            container_format = new MediaEntry ("video-x-generic-symbolic", "", false);
            container_format.tooltip_notify.connect (info_send);
            video_bitrate = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_bitrate.tooltip_notify.connect (info_send);
            video_bitrate_max = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_bitrate_max.tooltip_notify.connect (info_send);
            frame_rate = new MediaEntry ("video-x-generic-symbolic", "", false);
            frame_rate.tooltip_notify.connect (info_send);
            video_depth = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_depth.tooltip_notify.connect (info_send);
            audio_bitrate = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_bitrate.tooltip_notify.connect (info_send);
            audio_bitrate_max = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_bitrate_max.tooltip_notify.connect (info_send);
            audio_language = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_language.tooltip_notify.connect (info_send);
            audio_chanel = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_chanel.tooltip_notify.connect (info_send);
            audio_samplerate = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_samplerate.tooltip_notify.connect (info_send);
            audio_depth = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_depth.tooltip_notify.connect (info_send);

            video_asyncimage = new Gtk.Image () {
                pixel_size = 85,
                margin_end = 5,
                valign = Gtk.Align.CENTER
            };

            var thumbnail = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.CENTER,
                margin_top = 5,
                margin_bottom = 5,
                hexpand = true
            };
            thumbnail.get_style_context ().add_class ("ground_action_button");
            thumbnail.add (video_asyncimage);

            var topology_box = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                halign = Gtk.Align.START,
                valign = Gtk.Align.CENTER,
                margin = 5,
                hexpand = true,
                vexpand = true
            };
            topology_box.get_style_context ().add_class ("ground_action_button");
            topology_box.add (container);
            topology_box.add (container_audio);
            topology_box.add (container_video);

            var video_grid = new Gtk.Grid () {
                expand = true,
                margin_start = 10
            };
            video_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            video_grid.attach (new HeaderLabel (_("Thumbnail:"), 200), 0, 0, 1, 1);
            video_grid.attach (thumbnail, 0, 1, 1, 1);
            video_grid.attach (new HeaderLabel (_("Topology:"), 200), 1, 0, 1, 1);
            video_grid.attach (topology_box, 1, 1, 1, 1);
            video_grid.attach (new HeaderLabel (_("Duration:"), 200), 0, 2, 1, 1);
            video_grid.attach (duration_video, 0, 3, 1, 1);
            video_grid.attach (new HeaderLabel (_("Seekable:"), 200), 1, 2, 1, 1);
            video_grid.attach (sekable_video, 1, 3, 1, 1);
            video_grid.attach (new HeaderLabel (_("Container Format:"), 200), 0, 4, 1, 1);
            video_grid.attach (container_format, 0, 5, 1, 1);
            video_grid.attach (new HeaderLabel (_("Date Time:"), 200), 1, 4, 1, 1);
            video_grid.attach (date_time_video, 1, 5, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Codec:"), 200), 0, 6, 1, 1);
            video_grid.attach (audio_codec, 0, 7, 1, 1);
            video_grid.attach (new HeaderLabel (_("Video Codec:"), 200), 1, 6, 1, 1);
            video_grid.attach (video_codec, 1, 7, 1, 1);
            video_grid.attach (new HeaderLabel (_("Pixel Aspect Ratio:"), 200), 0, 8, 1, 1);
            video_grid.attach (pixel_ratio, 0, 9, 1, 1);
            video_grid.attach (new HeaderLabel (_("Interlaced:"), 200), 1, 8, 1, 1);
            video_grid.attach (interlaced, 1, 9, 1, 1);
            video_grid.attach (new HeaderLabel (_("Video Bitrate:"), 200), 0, 10, 1, 1);
            video_grid.attach (video_bitrate, 0, 11, 1, 1);
            video_grid.attach (new HeaderLabel (_("Video Bitrate Max:"), 200), 1, 10, 1, 1);
            video_grid.attach (video_bitrate_max, 1, 11, 1, 1);
            video_grid.attach (new HeaderLabel (_("Frame Rate:"), 200), 0, 12, 1, 1);
            video_grid.attach (frame_rate, 0, 13, 1, 1);
            video_grid.attach (new HeaderLabel (_("Video Depth"), 200), 1, 12, 1, 1);
            video_grid.attach (video_depth, 1, 13, 1, 1);
            video_grid.attach (new HeaderLabel (_("Video Width:"), 200), 0, 14, 1, 1);
            video_grid.attach (video_width, 0, 15, 1, 1);
            video_grid.attach (new HeaderLabel (_("Video Height:"), 200), 1, 14, 1, 1);
            video_grid.attach (video_height, 1, 15, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Bitrate:"), 200), 0, 16, 1, 1);
            video_grid.attach (audio_bitrate, 0, 17, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Bitrate Max:"), 200), 1, 16, 1, 1);
            video_grid.attach (audio_bitrate_max, 1, 17, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Language:"), 200), 0, 18, 1, 1);
            video_grid.attach (audio_language, 0, 19, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Chanels:"), 200), 1, 18, 1, 1);
            video_grid.attach (audio_chanel, 1, 19, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Sample rate:"), 200), 0, 20, 1, 1);
            video_grid.attach (audio_samplerate, 0, 21, 1, 1);
            video_grid.attach (new HeaderLabel (_("Audio Depth:"), 200), 1, 20, 1, 1);
            video_grid.attach (audio_depth, 1, 21, 1, 1);

            var viscrolledwindow = new Gtk.ScrolledWindow (null, null);
            viscrolledwindow.set_policy (Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.AUTOMATIC);
            viscrolledwindow.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            viscrolledwindow.add (video_grid);

            stack = new Gtk.Stack () {
                transition_duration = 500,
                vhomogeneous = false,
                hhomogeneous = false
            };
            stack.add_named (grid, "audio_info");
            stack.add_named (viscrolledwindow, "video_info");
            stack.show_all ();

            var grid_combine = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                valign = Gtk.Align.FILL
            };
            grid_combine.set_size_request (425, 380);
            grid_combine.add (label_name);
            grid_combine.add (stack);
            grid_combine.show_all ();

            var save_button = new Gtk.Button.with_label (_("Save"));
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.clicked.connect (save_to_file);

            var close_button = new Gtk.Button.with_label (_("Close"));
            close_button.clicked.connect (()=> {
                destroy ();
            });

            var clear_button = new Gtk.Button.with_label (_("Clear"));
            clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            clear_button.clicked.connect (clear_tags);

            move_widget (this);

            label = new Gtk.Label (null) {
                valign = Gtk.Align.CENTER,
                ellipsize = Pango.EllipsizeMode.END
            };

            spinner = new Gtk.Spinner () {
                margin_end = 5,
                valign = Gtk.Align.CENTER
            };

            var prog_grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                valign = Gtk.Align.CENTER
            };
            prog_grid.add (spinner);
            prog_grid.add (label);

            prog_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                margin_start = 10
            };
            prog_revealer.add (prog_grid);

            save_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.CROSSFADE
            };
            save_revealer.add (save_button);

            clear_revealer = new Gtk.Revealer () {
                transition_type = Gtk.RevealerTransitionType.CROSSFADE
            };
            clear_revealer.add (clear_button);

            var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                spacing = 5,
                margin_end = 10,
                homogeneous = true
            };
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.pack_end (close_button, false, true, 0);
            box_action.pack_end (save_revealer, false, true, 0);
            box_action.pack_end (clear_revealer, false, true, 0);

            var box_proaction = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                margin_top = 5,
                margin_bottom = 10,
                column_homogeneous = true
            };
            box_proaction.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_proaction.add (prog_revealer);
            box_proaction.add (box_action);

            var grid_ver = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL
            };
            grid_ver.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid_ver.add (grid_combine);
            grid_ver.add (box_proaction);

            get_content_area ().add (grid_ver);
            destroy.connect (()=> {
                permanent_delete (File.new_for_path (cache_image ("setcover")));
            });
        }

        public void info_send (string text) {
            spinner.active = true;
            prog_revealer.reveal_child = true;
            label.label = text;
            if (hiding_timer != 0) {
                Source.remove (hiding_timer);
            }
            hiding_timer = GLib.Timeout.add_seconds (1, () => {
                spinner.active = false;
                prog_revealer.reveal_child = false;
                hiding_timer = 0;
                return false;
            });
        }

        private void previous_track () {
            Gtk.TreeIter iter = playlist.selected_iter ();
            if (playlist.model.iter_previous (ref iter)) {
                playlist.get_selection ().select_iter (iter);
            }
            if (!playlist.liststore.iter_is_valid (iter)) {
                return;
            }
            string file_name;
            playlist.liststore.get (iter, PlaylistColumns.FILENAME, out file_name);
            stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            set_media (file_name);
            permanent_delete (File.new_for_path (cache_image ("setcover")));
        }

        private void next_track () {
            Gtk.TreeIter iter = playlist.selected_iter ();
            if (playlist.model.iter_next (ref iter)) {
                playlist.get_selection ().select_iter (iter);
            }
            if (!playlist.liststore.iter_is_valid (iter)) {
                return;
            }
            string file_name;
            playlist.liststore.get (iter, PlaylistColumns.FILENAME, out file_name);
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
            set_media (file_name);
            permanent_delete (File.new_for_path (cache_image ("setcover")));
        }

        private void save_to_file () {
            string file_name;
            playlist.liststore.get (playlist.selected_iter (), PlaylistColumns.FILENAME, out file_name);
            var file = File.new_for_uri (file_name);
            string nameimage = cache_image ("setcover");
            if (get_mime_type (file).has_prefix ("audio/")) {
                if (file.get_uri ().down ().has_suffix ("aac") || file.get_uri ().down ().has_suffix ("ac3")) {
                    return;
                }
                if (file.get_uri ().down ().has_suffix ("mp3")) {
                    var file_mpg = new InyTag.Mpeg_File (file.get_path ());
                    var frampic = new InyTag.ID3v2_Attached_Picture_Frame ();
                    var framcomm = new InyTag.Attached_Comment_Frame ();
                    file_mpg.id3v2_tag.add_text_frame (InyTag.Frame_ID.TITLE, title_entry.text);
                    file_mpg.id3v2_tag.add_text_frame (InyTag.Frame_ID.LEADARTIST, artist_entry.text);
                    file_mpg.id3v2_tag.add_text_frame (InyTag.Frame_ID.ALBUM, album_entry.text);
                    file_mpg.id3v2_tag.add_text_frame (InyTag.Frame_ID.CONTENTTYPE, genre_entry.text);
                    framcomm.set_encording (InyTag.String_Type.UTF16);
                    framcomm.set_text (comment_textview.buffer.text);
                    file_mpg.id3v2_tag.add_comment_frame (framcomm);
                    file_mpg.id3v2_tag.add_text_frame (InyTag.Frame_ID.TRACKNUM, track_spinbutton.value.to_string ());
                    file_mpg.id3v2_tag.add_text_frame (InyTag.Frame_ID.YEARV2, date_spinbutton.value.to_string ());
                    if (FileUtils.test (nameimage, FileTest.EXISTS)) {
                        frampic.mime_type = get_mime_type (File.new_for_path (nameimage));
                        frampic.type = InyTag.Img_Type.FrontCover;
                        frampic.set_picture (nameimage);
                        file_mpg.id3v2_tag.add_picture_frame (frampic);
                    }
                    file_mpg.save ();
                } else if (file.get_uri ().down ().has_suffix ("m4a")) {
                    var file_mp4 = new InyTag.Mp4_File (file.get_path ());
                    file_mp4.mp4_tag.title = title_entry.text;
                    file_mp4.mp4_tag.artist = artist_entry.text;
                    file_mp4.mp4_tag.album = album_entry.text;
                    file_mp4.mp4_tag.genre = genre_entry.text;
                    file_mp4.mp4_tag.comment = comment_textview.buffer.text;
                    file_mp4.mp4_tag.year = (int) date_spinbutton.value;
                    file_mp4.mp4_tag.track = (int) track_spinbutton.value;
                    if (FileUtils.test (nameimage, FileTest.EXISTS)) {
                        InyTag.Mp4_Picture picture = new InyTag.Mp4_Picture ();
                        picture.set_file (InyTag.Format_Type.JPEG, nameimage);
                        file_mp4.tag_mp4.set_item_picture (picture);
                    }
                    file_mp4.save ();
                } else if (file.get_uri ().down ().has_suffix ("flac")) {
                    var file_flac = new InyTag.Flac_File (file.get_path ());
                    file_flac.flac_tag.title = title_entry.text;
                    file_flac.flac_tag.artist = artist_entry.text;
                    file_flac.flac_tag.album = album_entry.text;
                    file_flac.flac_tag.genre = genre_entry.text;
                    file_flac.flac_tag.comment = comment_textview.buffer.text;
                    file_flac.flac_tag.year = (int) date_spinbutton.value;
                    file_flac.flac_tag.track = (int) track_spinbutton.value;
                    if (FileUtils.test (nameimage, FileTest.EXISTS)) {
                        InyTag.Flac_Picture picture_flac = new InyTag.Flac_Picture ();
                        picture_flac.mime_type = get_mime_type (File.new_for_path (nameimage));
                        picture_flac.type = InyTag.Img_Type.FrontCover;
                        picture_flac.description = "desck";
                        picture_flac.set_picture (nameimage);
                        file_flac.add_picture (picture_flac);
                    }
                    file_flac.save ();
                } else {
                    var tagfile = new InyTag.File (file.get_path ());
                    tagfile.tag.title = title_entry.text;
                    tagfile.tag.artist = artist_entry.text;
                    tagfile.tag.album = album_entry.text;
                    tagfile.tag.genre = genre_entry.text;
                    tagfile.tag.comment = comment_textview.buffer.text;
                    tagfile.tag.year = (int) date_spinbutton.value;
                    tagfile.tag.track = (int) track_spinbutton.value;
                    tagfile.save ();
                }
                info_send (@"$(_("Taged")) $(file.get_basename ())");
                update_file (file_name);
            }
        }
        private void clear_tags () {
            string file_name;
            playlist.liststore.get (playlist.selected_iter (), PlaylistColumns.FILENAME, out file_name);
            var file = File.new_for_uri (file_name);
            if (get_mime_type (file).has_prefix ("audio/")) {
                if (file.get_uri ().down ().has_suffix ("mp3")) {
                    var file_mpg = new InyTag.Mpeg_File (file.get_path ());
                    file_mpg.id3v2_tag.remove_all ();
                    file_mpg.mpeg_tag.title = "";
                    file_mpg.mpeg_tag.artist = "";
                    file_mpg.mpeg_tag.album = "";
                    file_mpg.mpeg_tag.genre = "";
                    file_mpg.mpeg_tag.comment = "";
                    file_mpg.mpeg_tag.year = 0;
                    file_mpg.mpeg_tag.track = 0;
                    file_mpg.save ();
                } else if (file.get_uri ().down ().has_suffix ("m4a")) {
                    var file_mp4 = new InyTag.Mp4_File (file.get_path ());
                    file_mp4.mp4_tag.title = "";
                    file_mp4.mp4_tag.artist ="";
                    file_mp4.mp4_tag.album = "";
                    file_mp4.mp4_tag.genre = "";
                    file_mp4.mp4_tag.comment = "";
                    file_mp4.mp4_tag.year = 0;
                    file_mp4.mp4_tag.track = 0;
                    file_mp4.remove_picture ();
                    file_mp4.save ();
                } else if (file.get_uri ().down ().has_suffix ("flac")) {
                    var file_flac = new InyTag.Flac_File (file.get_path ());
                    file_flac.flac_tag.title = "";
                    file_flac.flac_tag.artist ="";
                    file_flac.flac_tag.album = "";
                    file_flac.flac_tag.genre = "";
                    file_flac.flac_tag.comment = "";
                    file_flac.flac_tag.year = 0;
                    file_flac.flac_tag.track = 0;
                    file_flac.remove_all_picture ();
                    file_flac.save ();
                } else if (!file_name.down ().has_suffix ("aac") || !file_name.down ().has_suffix ("ac3")) {
                    var tagfile = new InyTag.File (File.new_for_uri (file_name).get_path ());
                    tagfile.tag.title = "";
                    tagfile.tag.artist = "";
                    tagfile.tag.album = "";
                    tagfile.tag.genre = "";
                    tagfile.tag.comment = "";
                    tagfile.tag.track = 0;
                    tagfile.tag.year = 0;
                }
                info_send (@"$(_("Clear")) $(file.get_basename ())");
                audio_info (file_name);
                update_file (file_name);
                permanent_delete (File.new_for_path (cache_image ("setcover")));
            }
        }
        public void set_media (string file_name) {
            if (file_name.has_prefix ("http")) {
                return;
            }
            var file = File.new_for_uri (file_name);
            if (get_mime_type (file).has_prefix ("video/")) {
                stack.visible_child_name = "video_info";
                header_label.label = _("Video Details");
                video_info (file_name);
                clear_revealer.reveal_child = save_revealer.reveal_child = false;
            }
            if (get_mime_type (file).has_prefix ("audio/")) {
                stack.visible_child_name = "audio_info";
                header_label.label = _("Audio Tags");
                audio_info (file_name);
                clear_revealer.reveal_child = save_revealer.reveal_child = true;
            }
        }

        private void video_info (string file_name) {
            File path = File.new_for_uri (file_name);
            label_name.label = path.get_basename ();
            label_name.tooltip_text = path.get_path ();
            if (!FileUtils.test (large_thumb (path), FileTest.EXISTS)) {
                var dbus_thumbler = new DbusThumbnailer ().instance;
                dbus_thumbler.instand_thumbler (path, "large");
                dbus_thumbler.load_finished.connect (()=> {
                    video_asyncimage.set_from_pixbuf (pix_scale (large_thumb (path), 128));
                    video_asyncimage.show ();
                });
            } else {
                video_asyncimage.set_from_pixbuf (pix_scale (large_thumb (path), 128));
                video_asyncimage.show ();
            }
            var info = get_discoverer_info (file_name);
            var stream_info = info.get_stream_info ();
            Gst.Caps caps = stream_info.get_caps ();
            container.tooltip_text = container.label = "%s: %s".printf (stream_info.get_stream_type_nick (), caps.is_fixed () == true? Gst.PbUtils.get_codec_description (caps) : caps.to_string ());
            ((Gst.PbUtils.DiscovererContainerInfo) stream_info).get_streams ().foreach ((list)=> {
                if (list.get_stream_type_nick () == "audio") {
                    Gst.Caps acaps = list.get_caps ();
                    container_audio.tooltip_text = container_audio.label = "%s: %s".printf (list.get_stream_type_nick (), acaps.is_fixed () == true? Gst.PbUtils.get_codec_description (acaps) : acaps.to_string ());
                }
                if (list.get_stream_type_nick () == "video") {
                    Gst.Caps vcaps = list.get_caps ();
                    container_video.tooltip_text = container_video.label = "%s: %s".printf (list.get_stream_type_nick (), vcaps.is_fixed () == true? Gst.PbUtils.get_codec_description (vcaps) : vcaps.to_string ());
                }
            });
            duration_video.text = seconds_to_time ((int)(info.get_duration () / 1000000000));
            sekable_video.text = info.get_seekable ()? _("Yes") : _("No");
            info.get_video_streams ().foreach ((list)=> {
                var stream_video = (Gst.PbUtils.DiscovererVideoInfo)list;
                video_height.text = "%u".printf (stream_video.get_height ());
                video_width.text = "%u".printf (stream_video.get_width ());
                interlaced.text = "%s".printf (stream_video.is_interlaced ()? _("Yes") : _("No"));
                pixel_ratio.text = "%u/%u".printf (stream_video.get_par_num (), stream_video.get_par_denom ());
                video_bitrate.text = "%u".printf (stream_video.get_bitrate ());
                video_bitrate_max.text = "%u".printf (stream_video.get_max_bitrate ());
                video_depth.text = "%u".printf (stream_video.get_depth ());
                frame_rate.text = "%u/%u".printf (stream_video.get_framerate_num (), stream_video.get_framerate_denom ());
            });
            info.get_audio_streams ().foreach ((list)=> {
                var stream_audio = (Gst.PbUtils.DiscovererAudioInfo)list;
                audio_language.text = "%s".printf (stream_audio.get_language ());
                audio_samplerate.text = "%u".printf (stream_audio.get_sample_rate ());
                audio_bitrate.text = "%u".printf (stream_audio.get_bitrate ());
                audio_bitrate_max.text = "%u".printf (stream_audio.get_max_bitrate ());
                audio_depth.text = "%u".printf (stream_audio.get_depth ());
                audio_chanel.text = "%u (%s )".printf (stream_audio.get_channels (), format_channel_mask (stream_audio));
            });
            var tag_list = info.get_tags ();
            container_format.text = get_string_tag (Gst.Tags.CONTAINER_FORMAT, tag_list);
            audio_codec.text = get_string_tag (Gst.Tags.AUDIO_CODEC, tag_list);
            video_codec.text = get_string_tag (Gst.Tags.VIDEO_CODEC, tag_list);
            Gst.DateTime? date_time;
            GLib.Date? time_date;
            if (tag_list.get_date_time (Gst.Tags.DATE_TIME, out date_time)) {
                date_time_video.text = date_time.to_iso8601_string ();
            } else if (tag_list.get_date (Gst.Tags.DATE, out time_date)) {
                date_time_video.text = date_time.to_iso8601_string ();
            } else {
                date_time_video.text = "";
            }
        }

        private string? format_channel_mask (Gst.PbUtils.DiscovererAudioInfo ainfo) {
            var astring = new StringBuilder (" ");
            Gst.Audio.ChannelPosition position [64];
            uint channels = ainfo.get_channels ();
            EnumClass enum_class = (EnumClass) typeof (Gst.Audio.ChannelPosition).class_ref ();
            uint64 channel_mask = ainfo.get_channel_mask ();
            if (channel_mask != 0) {
                Gst.Audio.audio_channel_positions_from_mask (channel_mask, position);
                for (uint i = 0; i < channels; i++) {
                    EnumValue value = enum_class.get_value (position[i]);
                    astring.append_printf ("%s%s", value.value_nick, i + 1 == channels ? "" : ", ");
                }
            } else {
                astring.append (_("Unknown Layout"));
            }
            return astring.str;
        }

        private void audio_info (string file_name) {
            label_name.label = File.new_for_uri (file_name).get_basename ();
            label_name.tooltip_text = File.new_for_uri (file_name).get_path ();
            if (file_name.down ().has_suffix ("aac") || file_name.down ().has_suffix ("ac3")) {
                title_entry.text = "";
                artist_entry.text = "";
                album_entry.text = "";
                genre_entry.text = "";
                comment_textview.buffer.text = "";
                track_spinbutton.value = 0;
                date_spinbutton.value = 0;
                return;
            }
            if (file_name.down ().has_suffix ("mp3")) {
                var file_mpg = new InyTag.Mpeg_File (File.new_for_uri (file_name).get_path ());
                title_entry.text = file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.TITLE);
                artist_entry.text = file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.LEADARTIST);
                album_entry.text = file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.ALBUM);
                genre_entry.text = file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.CONTENTTYPE);
                comment_textview.buffer.text = file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.COMMENT);;
                track_spinbutton.value = int.parse (file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.TRACKNUM));
                date_spinbutton.value = int.parse (file_mpg.id3v2_tag.get_text_frame (InyTag.Frame_ID.YEARV2));
                label_bitrate.label = file_mpg.audioproperties.bitrate.to_string () + _(" kHz");
                label_sample.label = file_mpg.audioproperties.samplerate.to_string () + _(" bps");
                label_chanel.label = file_mpg.audioproperties.channels == 2? _("Stereo") : _("Mono");
                label_duration.label = seconds_to_time (file_mpg.audioproperties.length);
                InyTag.ID3v2_Attached_Picture_Frame picture = file_mpg.id3v2_tag.get_picture_frame (InyTag.Img_Type.FrontCover);
                InyTag.ByteVector vector = picture.get_picture ();
                var pixbuf = vector.get_pixbuf ();
                apply_cover_pixbuf (align_and_scale_pixbuf (pixbuf != null? pixbuf : unknown_cover (), 256));
            } else if (file_name.down ().has_suffix ("flac")) {
                var file_flac = new InyTag.Flac_File (File.new_for_uri (file_name).get_path ());
                title_entry.text = file_flac.flac_tag.title;
                artist_entry.text = file_flac.flac_tag.artist;
                album_entry.text = file_flac.flac_tag.album;
                genre_entry.text = file_flac.flac_tag.genre;
                comment_textview.buffer.text = file_flac.flac_tag.comment;
                date_spinbutton.value = (int) file_flac.flac_tag.year;
                track_spinbutton.value = (int) file_flac.flac_tag.track;
                label_bitrate.label = file_flac.audioproperties.bitrate.to_string () + _(" kHz");
                label_sample.label = file_flac.audioproperties.samplerate.to_string () + _(" bps");
                label_chanel.label = file_flac.audioproperties.channels == 2? _("Stereo") : _("Mono");
                label_duration.label = seconds_to_time (file_flac.audioproperties.length);
                InyTag.Flac_Picture picflac = file_flac.get_picture (InyTag.Img_Type.FrontCover);
                InyTag.ByteVector vector = picflac.get_picture ();
                var pixbuf = vector.get_pixbuf ();
                apply_cover_pixbuf (align_and_scale_pixbuf (pixbuf != null? pixbuf : unknown_cover (), 256));
            } else if (file_name.down ().has_suffix ("m4a")) {
                var file_mp4 = new InyTag.Mp4_File (File.new_for_uri (file_name).get_path ());
                title_entry.text = file_mp4.mp4_tag.title;
                artist_entry.text = file_mp4.mp4_tag.artist;
                album_entry.text = file_mp4.mp4_tag.album;
                genre_entry.text = file_mp4.mp4_tag.genre;
                comment_textview.buffer.text = file_mp4.mp4_tag.comment;
                date_spinbutton.value = (int) file_mp4.mp4_tag.year;
                track_spinbutton.value = (int) file_mp4.mp4_tag.track;
                label_bitrate.label = file_mp4.audioproperties.bitrate.to_string () + _(" kHz");
                label_sample.label = file_mp4.audioproperties.samplerate.to_string () + _(" bps");
                label_chanel.label = file_mp4.audioproperties.channels == 2? _("Stereo") : _("Mono");
                label_duration.label = seconds_to_time (file_mp4.audioproperties.length);
                InyTag.Mp4_Picture picture = file_mp4.tag_mp4.get_item_picture ();
                InyTag.ByteVector vector = picture.get_picture (InyTag.Format_Type.JPEG);
                Gdk.Pixbuf pixbuf = vector.get_pixbuf ();
                apply_cover_pixbuf (align_and_scale_pixbuf (pixbuf != null? pixbuf : unknown_cover (), 256));
            } else {
                var tagfile = new InyTag.File (File.new_for_uri (file_name).get_path ());
                label_bitrate.label = tagfile.audioproperties.bitrate.to_string () + _(" kHz");
                label_sample.label = tagfile.audioproperties.samplerate.to_string () + _(" bps");
                label_chanel.label = tagfile.audioproperties.channels == 2? _("Stereo") : _("Mono");
                label_duration.label = seconds_to_time (tagfile.audioproperties.length);
                title_entry.text = tagfile.tag.title;
                artist_entry.text = tagfile.tag.artist;
                album_entry.text = tagfile.tag.album;
                genre_entry.text = tagfile.tag.genre;
                comment_textview.buffer.text = tagfile.tag.comment;
                track_spinbutton.value = tagfile.tag.track;
                date_spinbutton.value = tagfile.tag.year;
                var tags = get_discoverer_info (file_name).get_tags ();
                apply_cover_pixbuf (align_and_scale_pixbuf (pix_from_tag (tags, Gst.Tag.ImageType.ARTIST), 256));
            }
        }

        private void apply_cover_pixbuf (Gdk.Pixbuf save_pixbuf) {
            asyncimage.set_from_pixbuf (align_and_scale_pixbuf (save_pixbuf, 85));
            asyncimage.show ();
        }

        private void select_image (string inpu_data) {
            var crop_dialog = new CropDialog (inpu_data, this);
            crop_dialog.show_all ();
            crop_dialog.request_avatar_change.connect ((pixbuf)=> {
                apply_cover_pixbuf (pixbuf);
                string nameimage = cache_image ("setcover");
                permanent_delete (File.new_for_path (nameimage));
                pix_to_file (pixbuf, nameimage);
            });
        }
    }
}
