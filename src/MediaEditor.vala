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
    public class MediaEditor : Gtk.Dialog {
        private Gtk.TextView comment_textview;
        private Gtk.SpinButton date_spinbutton;
        private Gtk.SpinButton track_spinbutton;
        private AsyncImage? asyncimage;
        private AsyncImage? video_asyncimage;
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
        private Gtk.Button save_button;
        private Gtk.Button clear_button;
        private Gtk.Label label;
        private Gtk.Spinner spinner;
        private Gtk.Revealer prog_revealer;
        private uint hiding_timer = 0;
        public signal void update_file (string file_name);

        public MediaEditor (Playlist playlist) {
            Object (
                resizable: true,
                deletable: false,
                skip_taskbar_hint: true,
                transient_for: NikiApp.window,
                destroy_with_parent: true
            );
            this.playlist = playlist;
            resize (425, 380);
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
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
            var comment_scr = new Gtk.ScrolledWindow (null, null);
            comment_scr.set_policy (Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.AUTOMATIC);
            comment_scr.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            comment_scr.add (comment_textview);
            var local_time = new DateTime.now_local ();
            date_spinbutton = new Gtk.SpinButton.with_range (0, local_time.get_year (), 1);
            date_spinbutton.focus_on_click = false;
            date_spinbutton.margin_end = 10;
            date_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            track_spinbutton = new Gtk.SpinButton.with_range (0, 500, 1);
            track_spinbutton.focus_on_click = false;
            track_spinbutton.margin_end = 10;
            track_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var comment_frame = new Gtk.Frame (null);
            comment_frame.expand = true;
            comment_frame.margin_end = 10;
            comment_frame.add (comment_scr);

            asyncimage = new AsyncImage (true);
            asyncimage.pixel_size = 85;
            asyncimage.margin_end = 5;
            var openimage = new Gtk.Button ();
            openimage.focus_on_click = false;
            openimage.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            openimage.get_style_context ().add_class ("transparantbg");
            openimage.add (asyncimage);
            openimage.clicked.connect (()=> {
                var file = run_open_file (this, false, 2);
                if (file != null) {
                    select_image (file[0].get_path ());
                }
            });

            label_duration = new Gtk.Label (null);
            label_duration.halign = Gtk.Align.START;
            label_duration.ellipsize = Pango.EllipsizeMode.END;
            label_bitrate = new Gtk.Label (null);
            label_bitrate.halign = Gtk.Align.START;
            label_bitrate.ellipsize = Pango.EllipsizeMode.END;
            label_sample = new Gtk.Label (null);
            label_sample.halign = Gtk.Align.START;
            label_sample.ellipsize = Pango.EllipsizeMode.END;
            label_chanel = new Gtk.Label (null);
            label_chanel.halign = Gtk.Align.START;
            label_chanel.ellipsize = Pango.EllipsizeMode.END;

            var grid_label = new Gtk.Grid ();
            grid_label.orientation = Gtk.Orientation.VERTICAL;
            grid_label.valign = Gtk.Align.CENTER;
            grid_label.add (label_duration);
            grid_label.add (label_bitrate);
            grid_label.add (label_sample);
            grid_label.add (label_chanel);
            grid_label.show_all ();

            var imagege_box = new Gtk.Grid ();
            imagege_box.get_style_context ().add_class ("ground_action_button");
            imagege_box.orientation = Gtk.Orientation.HORIZONTAL;
            imagege_box.valign = Gtk.Align.CENTER;
            imagege_box.halign = Gtk.Align.CENTER;
            imagege_box.hexpand = true;
            imagege_box.add (openimage);
            imagege_box.add (grid_label);

            var grid = new Gtk.Grid ();
            grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid.expand = true;
            grid.margin_start = 10;
            grid.attach (new HeaderLabel (_("Cover:"), 200), 0, 0, 1, 1);
            grid.attach (imagege_box, 0, 1, 1, 1);
            grid.attach (new HeaderLabel (_("Comment:"), 200), 1, 0, 1, 1);
            grid.attach (comment_frame, 1, 1, 1, 1);
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

            label_name = new Gtk.Label (null);
            label_name.hexpand = true;
            label_name.halign = Gtk.Align.CENTER;
            label_name.ellipsize = Pango.EllipsizeMode.MIDDLE;
            label_name.get_style_context ().add_class ("h4");

            var previous_button = new Gtk.Button.from_icon_name ("go-previous-symbolic");
            previous_button.focus_on_click = false;
            previous_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            previous_button.get_style_context ().add_class ("transparantbg");
            previous_button.clicked.connect (previous_track);

            var next_button = new Gtk.Button.from_icon_name ("go-next-symbolic");
            next_button.focus_on_click = false;
            next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            next_button.get_style_context ().add_class ("transparantbg");
            next_button.clicked.connect (next_track);

            var arrows_grid = new Gtk.Grid ();
            arrows_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            arrows_grid.orientation = Gtk.Orientation.HORIZONTAL;
            arrows_grid.margin_start = arrows_grid.margin_end = 5;
            arrows_grid.add (previous_button);
            arrows_grid.add (label_name);
            arrows_grid.add (next_button);

            container = new Gtk.Label (null);
            container.ellipsize = Pango.EllipsizeMode.END;
            container.halign = Gtk.Align.START;
            container.margin = 2;
            container.margin_end = 10;
            container_audio = new Gtk.Label (null);
            container_audio.ellipsize = Pango.EllipsizeMode.END;
            container_audio.halign = Gtk.Align.START;
            container_audio.margin = 2;
            container_audio.margin_end = 10;
            container_video = new Gtk.Label (null);
            container_video.ellipsize = Pango.EllipsizeMode.END;
            container_video.halign = Gtk.Align.START;
            container_video.margin = 2;
            container_video.margin_end = 10;

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

            video_asyncimage = new AsyncImage (true);
            video_asyncimage.pixel_size = 85;
            video_asyncimage.margin_end = 5;
            video_asyncimage.valign = Gtk.Align.CENTER;

            var thumbnail = new Gtk.Grid ();
            thumbnail.get_style_context ().add_class ("ground_action_button");
            thumbnail.orientation = Gtk.Orientation.HORIZONTAL;
            thumbnail.valign = Gtk.Align.CENTER;
            thumbnail.halign = Gtk.Align.CENTER;
            thumbnail.margin_top = thumbnail.margin_bottom = 5;
            thumbnail.hexpand = true;
            thumbnail.add (video_asyncimage);

            var topology_box = new Gtk.Grid ();
            topology_box.get_style_context ().add_class ("ground_action_button");
            topology_box.orientation = Gtk.Orientation.VERTICAL;
            topology_box.halign = Gtk.Align.START;
            topology_box.valign = Gtk.Align.CENTER;
            topology_box.margin = 5;
            topology_box.hexpand = true;
            topology_box.vexpand = true;
            topology_box.add (container);
            topology_box.add (container_audio);
            topology_box.add (container_video);

            var video_grid = new Gtk.Grid ();
            video_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            video_grid.expand = true;
            video_grid.margin_start = 10;
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
            stack = new Gtk.Stack ();
            stack.transition_duration = 500;
            stack.add_named (grid, "audio_info");
            stack.add_named (viscrolledwindow, "video_info");
            stack.vhomogeneous = false;
            stack.hhomogeneous = false;
            stack.show_all ();

            var grid_combine = new Gtk.Grid ();
            grid_combine.set_size_request (425, 380);
            grid_combine.orientation = Gtk.Orientation.VERTICAL;
            grid_combine.valign = Gtk.Align.FILL;
            grid_combine.add (arrows_grid);
            grid_combine.add (stack);
            grid_combine.show_all ();

            save_button = new Gtk.Button.with_label (_("Save"));
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            save_button.clicked.connect (save_to_file);

            var close_button = new Gtk.Button.with_label (_("Close"));
            close_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FRAME);
            close_button.clicked.connect (()=>{
                destroy();
            });
            clear_button = new Gtk.Button.with_label (_("Clear"));
            clear_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            clear_button.clicked.connect (clear_tags);

            move_widget (this, this);

            label = new Gtk.Label (null);
            label.valign = Gtk.Align.CENTER;
            label.ellipsize = Pango.EllipsizeMode.END;
            spinner = new Gtk.Spinner ();
            spinner.margin_end = 5;
            spinner.valign = Gtk.Align.CENTER;

            var prog_grid = new Gtk.Grid ();
            prog_grid.orientation = Gtk.Orientation.HORIZONTAL;
            prog_grid.valign = Gtk.Align.CENTER;
            prog_grid.add (spinner);
            prog_grid.add (label);

            prog_revealer = new Gtk.Revealer ();
            prog_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
            prog_revealer.add (prog_grid);

		    var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.spacing = 5;
            box_action.margin_top = 5;
            box_action.margin_start = 10;
            box_action.margin_end = 10;
            box_action.pack_end (close_button, false, true, 0);
            box_action.pack_end (save_button, false, true, 0);
            box_action.pack_end (clear_button, false, true, 0);
            box_action.pack_start (prog_revealer, false, false, 0);

		    var grid_ver = new Gtk.Grid ();
            grid_ver.orientation = Gtk.Orientation.VERTICAL;
            grid_ver.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid_ver.add (grid_combine);
            grid_ver.add (box_action);
            get_content_area ().add (grid_ver);
            show.connect(()=>{
                NikiApp.window.player_page.right_bar.set_reveal_child (false);
            });
            destroy.connect(()=>{
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
                playlist.get_selection().select_iter (iter);
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
                playlist.get_selection().select_iter (iter);
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
                    file_mpg.mpeg_tag.title = title_entry.text;
                    file_mpg.mpeg_tag.artist = artist_entry.text;
                    file_mpg.mpeg_tag.album = album_entry.text;
                    file_mpg.mpeg_tag.genre = genre_entry.text;
                    file_mpg.mpeg_tag.comment = comment_textview.buffer.text;
                    file_mpg.mpeg_tag.year = (uint) date_spinbutton.value;
                    file_mpg.mpeg_tag.track = (uint) track_spinbutton.value;
                    var frampic = new InyTag.ID3v2_Attached_Picture_Frame ();
                    if (FileUtils.test (nameimage, FileTest.EXISTS)) {
                        if (!file_mpg.id3v2_tag.is_frame_empty (InyTag.Frame_ID.PICTURE)) {
                            file_mpg.id3v2_tag.remove_frame (InyTag.Frame_ID.PICTURE);
                        }
                        file_mpg.id3v2_tag.add_picture_frame (frampic);
                        frampic.set_mime_type (get_mime_type (File.new_for_path (nameimage)));
                        frampic.set_type (InyTag.Img_Type.FrontCover);
                        frampic.set_picture (nameimage);
                    }
                    file_mpg.save ();
                } else if (file.get_uri ().down ().has_suffix ("m4a")) {
                    var file_mp4 = new InyTag.Mp4_File (file.get_path ());
                    file_mp4.mp4_tag.title = title_entry.text;
                    file_mp4.mp4_tag.artist = artist_entry.text;
                    file_mp4.mp4_tag.album = album_entry.text;
                    file_mp4.mp4_tag.genre = genre_entry.text;
                    file_mp4.mp4_tag.comment = comment_textview.buffer.text;
                    file_mp4.mp4_tag.year = (uint) date_spinbutton.value;
                    file_mp4.mp4_tag.track = (uint) track_spinbutton.value;
                    if (FileUtils.test (nameimage, FileTest.EXISTS)) {
                        file_mp4.set_picture (InyTag.Format_Type.JPEG, nameimage);
                    }
                    file_mp4.save ();
                } else if (file.get_uri ().down ().has_suffix ("flac")) {
                    var file_flac = new InyTag.Flac_File (file.get_path ());
                    file_flac.flac_tag.title = title_entry.text;
                    file_flac.flac_tag.artist = artist_entry.text;
                    file_flac.flac_tag.album = album_entry.text;
                    file_flac.flac_tag.genre = genre_entry.text;
                    file_flac.flac_tag.comment = comment_textview.buffer.text;
                    file_flac.flac_tag.year = (uint) date_spinbutton.value;
                    file_flac.flac_tag.track = (uint) track_spinbutton.value;
                    if (FileUtils.test (nameimage, FileTest.EXISTS)) {
                        InyTag.Flac_Picture picture_flac = new InyTag.Flac_Picture ();
                        picture_flac.set_mime_type (get_mime_type (File.new_for_path (nameimage)));
                        picture_flac.set_type (InyTag.Img_Type.FrontCover);
                        picture_flac.set_picture (nameimage);
                        file_flac.remove_picture ();
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
                    tagfile.tag.year = (uint) date_spinbutton.value;
                    tagfile.tag.track = (uint) track_spinbutton.value;
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
                if (file.get_uri ().down ().has_suffix ("aac") || file.get_uri ().down ().has_suffix ("ac3")) {
                    return;
                }
                var tagfile = new InyTag.File (file.get_path ());
                tagfile.tag.title = "";
                tagfile.tag.artist ="";
                tagfile.tag.album = "";
                tagfile.tag.genre = "";
                tagfile.tag.comment = "";
                tagfile.tag.year = 0;
                tagfile.tag.track = 0;
                tagfile.save ();
                if (file.get_uri ().down ().has_suffix ("mp3")) {
                    var file_mpg = new InyTag.Mpeg_File (file.get_path ());
                    if (!file_mpg.id3v2_tag.is_frame_empty (InyTag.Frame_ID.PICTURE)) {
                        file_mpg.id3v2_tag.remove_frame (InyTag.Frame_ID.PICTURE);
                    }
                    file_mpg.save ();
                } else if (file.get_uri ().down ().has_suffix ("m4a")) {
                    var file_mp4 = new InyTag.Mp4_File (file.get_path ());
                    file_mp4.remove_picture ();
                    file_mp4.save ();
                } else if (file.get_uri ().down ().has_suffix ("flac")) {
                    var file_flac = new InyTag.Flac_File (file.get_path ());
                    file_flac.remove_picture ();
                    file_flac.save ();
                }
                info_send (@"$(_("Clear")) $(file.get_basename ())");
                audio_info (file_name);
                update_file (file_name);
            }
        }
        public void set_media (string file_name) {
            Gtk.TreeIter iter;
            playlist.liststore.get_iter (out iter, playlist.set_current (file_name, NikiApp.window.player_page));
            playlist.get_selection().select_iter (iter);
            if (!playlist.liststore.iter_is_valid (iter)) {
                return;
            }
            if (file_name.has_prefix ("http")) {
                return;
            }
            var file = File.new_for_uri (file_name);
            if (get_mime_type (file).has_prefix ("video/")) {
		        stack.visible_child_name = "video_info";
                video_info (file_name);
                clear_button.hide ();
                save_button.hide ();
            }
            if (get_mime_type (file).has_prefix ("audio/")) {
                stack.visible_child_name = "audio_info";
                audio_info (file_name);
                clear_button.show ();
                save_button.show ();
            }
        }
        private void video_info (string file_name) {
            File path = File.new_for_uri (file_name);
            label_name.label = path.get_basename ();
            label_name.tooltip_text = path.get_path ();
            if (!FileUtils.test (large_thumb (path), FileTest.EXISTS)) {
                var dbus_Thum = new DbusThumbnailer ().instance;
                dbus_Thum.instand_thumbler (path, "large");
                dbus_Thum.load_finished.connect (()=>{
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
            container.tooltip_text = container.label = "%s: %s".printf(stream_info.get_stream_type_nick (), caps.is_fixed () == true? Gst.PbUtils.get_codec_description (caps) : caps.to_string ());
            ((Gst.PbUtils.DiscovererContainerInfo) stream_info).get_streams ().foreach ((list)=> {
                if (list.get_stream_type_nick () == "audio") {
                    Gst.Caps acaps = list.get_caps ();
                    container_audio.tooltip_text = container_audio.label = "%s: %s".printf(list.get_stream_type_nick (), acaps.is_fixed () == true? Gst.PbUtils.get_codec_description (acaps) : acaps.to_string ());
                }
                if (list.get_stream_type_nick () == "video") {
                    Gst.Caps vcaps = list.get_caps ();
                    container_video.tooltip_text = container_video.label = "%s: %s".printf(list.get_stream_type_nick (), vcaps.is_fixed () == true? Gst.PbUtils.get_codec_description (vcaps) : vcaps.to_string ());
                }
            });
            duration_video.text = seconds_to_time ((int)(info.get_duration ()/1000000000));
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
            var tagfile = new InyTag.File (File.new_for_uri (file_name).get_path ());
            label_bitrate.label = tagfile.audioproperties.bitrate.to_string () + _(" kHz");
            label_sample.label = tagfile.audioproperties.samplerate.to_string () + _(" bps");
            label_chanel.label = tagfile.audioproperties.channels == 2? _("Stereo") : _("Mono");
            label_duration.label = seconds_to_time (tagfile.audioproperties.length);
            apply_cover_pixbuf (align_and_scale_pixbuf (pix_from_tag (get_discoverer_info (file_name).get_tags ()), 256));
            title_entry.text = tagfile.tag.title;
            artist_entry.text = tagfile.tag.artist;
            album_entry.text = tagfile.tag.album;
            genre_entry.text = tagfile.tag.genre;
            comment_textview.buffer.text = tagfile.tag.comment;
            track_spinbutton.value = tagfile.tag.track;
            date_spinbutton.value = tagfile.tag.year;
        }

        private void apply_cover_pixbuf (Gdk.Pixbuf save_pixbuf) {
            asyncimage.set_from_pixbuf (align_and_scale_pixbuf (save_pixbuf, 85));
            asyncimage.show ();
        }

        private void select_image (string inpu_data) {
            var crop_dialog = new CropDialog (inpu_data, this);
            crop_dialog.show ();
            crop_dialog.request_avatar_change.connect ((pixbuf)=> {
                apply_cover_pixbuf (pixbuf);
                string nameimage = cache_image ("setcover");
                permanent_delete (File.new_for_path (nameimage));
                pix_to_file (pixbuf, nameimage);
            });
        }
    }
}
