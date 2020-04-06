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
        private MediaEntry title_entry;
        private MediaEntry artist_entry;
        private MediaEntry composer_entry;
        private MediaEntry group_entry;
        private MediaEntry album_entry;
        private MediaEntry genre_entry;
        private Gtk.TextView comment_textview;
        private Gtk.SpinButton date_spinbutton;
        private Gtk.SpinButton track_spinbutton;
        private AsyncImage asyncimage;
        private AsyncImage video_asyncimage;
        private Gtk.Label label_duration;
        private Gtk.Label label_bitrate;
        private Gtk.Label label_chanel;
        private Gtk.Label label_sample;
        private Gtk.Label label_name;
        private Gtk.Label container;
        private Gtk.Label container_video;
        private Gtk.Label container_audio;
        private MediaEntry duration_video;
        private MediaEntry pixel_ratio;
        private MediaEntry sekable_video;
        private MediaEntry audio_codec;
        private MediaEntry video_codec;
        private MediaEntry date_time_video;
        private MediaEntry interlaced;
        private MediaEntry container_format;
        private MediaEntry video_height;
        private MediaEntry video_width;
        private MediaEntry video_bitrate;
        private MediaEntry video_bitrate_max;
        private MediaEntry frame_rate;
        private MediaEntry video_depth;
        private MediaEntry audio_bitrate;
        private MediaEntry audio_bitrate_max;
        private MediaEntry audio_language;
        private MediaEntry audio_chanel;
        private MediaEntry audio_samplerate;
        private MediaEntry audio_depth;
        private Gtk.Stack stack;
        private Gst.Pipeline pipeline;
        private dynamic Gst.Element id3v2mux;
        private dynamic Gst.Element id3demux;
        private dynamic Gst.Element filesrc;
        private dynamic Gst.Element fakesrc;
        private dynamic Gst.Element fakesink;
        private dynamic Gst.Element identity;
        private dynamic Gst.Element apev2mux;
        private dynamic Gst.Element id3mux;
        private Playlist? playlist;

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
            artist_entry = new MediaEntry ("avatar-default-symbolic", "edit-paste-symbolic");
            group_entry = new MediaEntry ("mail-attachment-symbolic", "edit-paste-symbolic");
            composer_entry = new MediaEntry ("multimedia-player-symbolic", "edit-paste-symbolic");
            album_entry = new MediaEntry ("media-optical-symbolic", "edit-paste-symbolic");
            genre_entry = new MediaEntry ("audio-x-generic-symbolic", "edit-paste-symbolic");
            comment_textview = new Gtk.TextView ();
            comment_textview.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            comment_textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);
            var comment_scr = new Gtk.ScrolledWindow (null, null);
            comment_scr.set_policy (Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.AUTOMATIC);
            comment_scr.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            comment_scr.add (comment_textview);
            var local_time = new DateTime.now_local ();
            date_spinbutton = new Gtk.SpinButton.with_range (0, local_time.get_year (), 1);
            date_spinbutton.margin_end = 10;
            date_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            track_spinbutton = new Gtk.SpinButton.with_range (0, 500, 1);
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
            openimage.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            openimage.get_style_context ().add_class ("transparantbg");
            openimage.add (asyncimage);
            openimage.clicked.connect (run_open_file);

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
            grid.attach (new HeaderLabel (StringPot.Cover, 200), 0, 0, 1, 1);
            grid.attach (imagege_box, 0, 1, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NComment, 200), 1, 0, 1, 1);
            grid.attach (comment_frame, 1, 1, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NTitle, 200), 0, 2, 1, 1);
            grid.attach (title_entry, 0, 3, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NArtist, 200), 1, 2, 1, 1);
            grid.attach (artist_entry, 1, 3, 1, 1);
            grid.attach (new HeaderLabel (StringPot.Album, 200), 0, 4, 1, 1);
            grid.attach (album_entry, 0, 5, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NGenre, 200), 1, 4, 1, 1);
            grid.attach (genre_entry, 1, 5, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NComposer, 200), 0, 6, 1, 1);
            grid.attach (composer_entry, 0, 7, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NGroup, 200), 1, 6, 1, 1);
            grid.attach (group_entry, 1, 7, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NTrack, 200), 0, 8, 1, 1);
            grid.attach (track_spinbutton, 0, 9, 1, 1);
            grid.attach (new HeaderLabel (StringPot.NDate, 200), 1, 8, 1, 1);
            grid.attach (date_spinbutton, 1, 9, 1, 1);

            label_name = new Gtk.Label (null);
            label_name.hexpand = true;
            label_name.halign = Gtk.Align.CENTER;
            label_name.ellipsize = Pango.EllipsizeMode.MIDDLE;
            label_name.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var previous_button = new Gtk.Button.from_icon_name ("go-previous-symbolic");
            previous_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            previous_button.get_style_context ().add_class ("transparantbg");
            previous_button.clicked.connect (previous_track);

            var next_button = new Gtk.Button.from_icon_name ("go-next-symbolic");
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
            pixel_ratio = new MediaEntry ("view-fullscreen-symbolic", "", false);
            sekable_video = new MediaEntry ("media-seek-forward-symbolic", "", false);
            audio_codec = new MediaEntry ("audio-x-generic-symbolic", "", false);
            video_codec = new MediaEntry ("video-x-generic-symbolic", "", false);
            date_time_video = new MediaEntry ("x-office-calendar-symbolic", "", false);
            interlaced = new MediaEntry ("insert-link-symbolic", "", false);
            video_width = new MediaEntry ("video-display-symbolic", "", false);
            video_height = new MediaEntry ("video-display-symbolic", "", false);
            container_format = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_bitrate = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_bitrate_max = new MediaEntry ("video-x-generic-symbolic", "", false);
            frame_rate = new MediaEntry ("video-x-generic-symbolic", "", false);
            video_depth = new MediaEntry ("video-x-generic-symbolic", "", false);
            audio_bitrate = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_bitrate_max = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_language = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_chanel = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_samplerate = new MediaEntry ("audio-x-generic-symbolic", "", false);
            audio_depth = new MediaEntry ("audio-x-generic-symbolic", "", false);

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
            video_grid.attach (new HeaderLabel ("Thumbnail:", 200), 0, 0, 1, 1);
            video_grid.attach (thumbnail, 0, 1, 1, 1);
            video_grid.attach (new HeaderLabel ("Topology:", 200), 1, 0, 1, 1);
            video_grid.attach (topology_box, 1, 1, 1, 1);
            video_grid.attach (new HeaderLabel ("Duration:", 200), 0, 2, 1, 1);
            video_grid.attach (duration_video, 0, 3, 1, 1);
            video_grid.attach (new HeaderLabel ("Seekable:", 200), 1, 2, 1, 1);
            video_grid.attach (sekable_video, 1, 3, 1, 1);
            video_grid.attach (new HeaderLabel ("Container format:", 200), 0, 4, 1, 1);
            video_grid.attach (container_format, 0, 5, 1, 1);
            video_grid.attach (new HeaderLabel ("Date time:", 200), 1, 4, 1, 1);
            video_grid.attach (date_time_video, 1, 5, 1, 1);
            video_grid.attach (new HeaderLabel ("Audio codec", 200), 0, 6, 1, 1);
            video_grid.attach (audio_codec, 0, 7, 1, 1);
            video_grid.attach (new HeaderLabel ("Video codec:", 200), 1, 6, 1, 1);
            video_grid.attach (video_codec, 1, 7, 1, 1);
            video_grid.attach (new HeaderLabel ("Pixel aspect ratio:", 200), 0, 8, 1, 1);
            video_grid.attach (pixel_ratio, 0, 9, 1, 1);
            video_grid.attach (new HeaderLabel ("Interlaced:", 200), 1, 8, 1, 1);
            video_grid.attach (interlaced, 1, 9, 1, 1);
            video_grid.attach (new HeaderLabel ("Video bitrate:", 200), 0, 10, 1, 1);
            video_grid.attach (video_bitrate, 0, 11, 1, 1);
            video_grid.attach (new HeaderLabel ("Video bitrate max", 200), 1, 10, 1, 1);
            video_grid.attach (video_bitrate_max, 1, 11, 1, 1);
            video_grid.attach (new HeaderLabel ("Frame rate:", 200), 0, 12, 1, 1);
            video_grid.attach (frame_rate, 0, 13, 1, 1);
            video_grid.attach (new HeaderLabel ("Video depth", 200), 1, 12, 1, 1);
            video_grid.attach (video_depth, 1, 13, 1, 1);
            video_grid.attach (new HeaderLabel ("Video Width:", 200), 0, 14, 1, 1);
            video_grid.attach (video_width, 0, 15, 1, 1);
            video_grid.attach (new HeaderLabel ("Video height", 200), 1, 14, 1, 1);
            video_grid.attach (video_height, 1, 15, 1, 1);
            video_grid.attach (new HeaderLabel ("audio bitrate:", 200), 0, 16, 1, 1);
            video_grid.attach (audio_bitrate, 0, 17, 1, 1);
            video_grid.attach (new HeaderLabel ("audio bitrate max", 200), 1, 16, 1, 1);
            video_grid.attach (audio_bitrate_max, 1, 17, 1, 1);
            video_grid.attach (new HeaderLabel ("Audio language:", 200), 0, 18, 1, 1);
            video_grid.attach (audio_language, 0, 19, 1, 1);
            video_grid.attach (new HeaderLabel ("Audio chanels", 200), 1, 18, 1, 1);
            video_grid.attach (audio_chanel, 1, 19, 1, 1);
            video_grid.attach (new HeaderLabel ("Audio Sample rate:", 200), 0, 20, 1, 1);
            video_grid.attach (audio_samplerate, 0, 21, 1, 1);
            video_grid.attach (new HeaderLabel ("Audio depth", 200), 1, 20, 1, 1);
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

            get_content_area ().add (grid_combine);

            add_button (StringPot.Close, Gtk.ResponseType.CLOSE);

            var save_button = (Gtk.Button) add_button (StringPot.Save, Gtk.ResponseType.APPLY);
            save_button.has_default = true;
            save_button.margin_end = 5;
            save_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.APPLY) {
                    save_to_file ();
                }
                if (response_id == Gtk.ResponseType.CLOSE) {
                    destroy ();
                }
            });
            move_widget (this, this);
            string file_name;
            playlist.liststore.get (playlist.selected_iter (), PlaylistColumns.FILENAME, out file_name);
            set_media (file_name);
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
        }

        private void bus_message_cb (Gst.Bus bus, Gst.Message message) {
            switch (message.type) {
                case Gst.MessageType.ERROR :
                    GLib.Error err;
                    string debug;
                    message.parse_error (out err, out debug);
                    print (":\n%s\n\n[%s]".printf (err.message, debug));
                    stderr.printf ("Error: %s\n", debug);
                    pipeline.set_state (Gst.State.NULL);
                    break;
                case Gst.MessageType.EOS :
                    pipeline.set_state (Gst.State.PAUSED);
                    break;
                case Gst.MessageType.TAG:
//                    unowned Gst.Structure structure = message.get_structure ();
                    break;
                default :
                    break;
            }
        }

        private Gst.TagList create_tags (int mask) {
            Gst.TagList tags = new Gst.TagList.empty ();
            if (mask == 0) {
                tags.add (Gst.TagMergeMode.KEEP, Gst.Tags.ARTIST, artist_entry.text);
            }
            if (mask == 1) {
                tags.add (Gst.TagMergeMode.KEEP, Gst.Tags.TITLE, title_entry.text);
            }
            if (mask == 2) {
                tags.add (Gst.TagMergeMode.KEEP, Gst.Tags.ALBUM, album_entry.text);
           }
  /*          if (mask = (1 << 3)) {
                if (date_spinbutton.value > 0) {
                    Gst.DateTime date_time = new Gst.DateTime.y ((int)date_spinbutton.value);
                    tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.DATE_TIME, date_time);
                }
            }
            if (mask == (1 << 4)) {
                tags.add (Gst.TagMergeMode.KEEP, Gst.Tags.TRACK_NUMBER, track_spinbutton.value);
            }
            if (mask == (1 << 5)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.COMPOSER, composer_entry.text);
            }
            if (mask == (1 << 6)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.GENRE, genre_entry.text);
            }
            if (mask == (1 << 7)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.COMMENT, comment_textview.buffer.text);
            }
            if (mask == (1 << 8)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.GROUPING, group_entry.text);
            }
            if (mask & (1 << 9)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.ALBUM_GAIN, TEST_ALBUM_GAIN, NULL);
            }
            if (mask & (1 << 10)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.TRACK_PEAK, TEST_TRACK_PEAK, NULL);
            }
            if (mask & (1 << 11)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.ALBUM_PEAK, TEST_ALBUM_PEAK, NULL);
            }
            if (mask & (1 << 12)) {
                tags.add (Gst.TagMergeMode.REPLACE, Gst.Tags.BEATS_PER_MINUTE, TEST_BPM, NULL);
            } */
            return tags;
        }
        private void save_to_file () {
            string file_name;
            playlist.liststore.get (playlist.selected_iter (), PlaylistColumns.FILENAME, out file_name);
            pipeline.set_state (Gst.State.NULL);
            for (int i = 0; i < 3; ++i) {
       //         int mask = (int)Random.next_int ();
                Gst.TagList tags = create_tags (i);
                taglib_gst_tags (tags, i, file_name);
            }
        }

        private void taglib_gst_tags (Gst.TagList tags, int mask, string file_name) {
            pipeline = new Gst.Pipeline ("pipeline");
            filesrc = Gst.ElementFactory.make ("filesrc", "filesrc");
            fakesrc =  Gst.ElementFactory.make ("fakesrc", "fakesrc");
            apev2mux =  Gst.ElementFactory.make ("apev2mux", "apev2mux");
            id3v2mux =  Gst.ElementFactory.make ("id3v2mux", "id3v2mux");
            identity =  Gst.ElementFactory.make ("identity", "identity");
            id3demux =  Gst.ElementFactory.make ("id3demux", "id3demux");
            id3mux =  Gst.ElementFactory.make ("id3mux", "id3mux");
            fakesink =  Gst.ElementFactory.make ("fakesink", "fakesink");
            filesrc["location"] = File.new_for_uri (file_name).get_path ();
            ((Gst.Bin)pipeline).add_many (filesrc, apev2mux, fakesink);
            ((Gst.TagSetter)apev2mux).merge_tags (tags, Gst.TagMergeMode.APPEND);
            filesrc.link_many (apev2mux, fakesink);
            Gst.Bus bus = pipeline.get_bus ();
            bus.add_signal_watch ();
            bus.message.connect (bus_message_cb);
            uint move_stoped = 0;
            if (move_stoped != 0) {
                Source.remove (move_stoped);
            }
            move_stoped = GLib.Timeout.add (100,() => {
                pipeline.set_state (Gst.State.PLAYING);
                pipeline.set_state (Gst.State.PAUSED);
                move_stoped = 0;
                return Source.REMOVE;
            });
        }

        private void set_media (string file_name) {
            if (file_name.has_prefix ("http")) {
                return;
            }
	        try {
		        FileInfo infos = File.new_for_uri (file_name).query_info ("standard::*",0);
                string mime_types = infos.get_content_type ();
                if (mime_types.has_prefix ("video/")) {
		            stack.visible_child_name = "video_info";
                    video_info (file_name);
                }
                if (mime_types.has_prefix ("audio/")) {
                    stack.visible_child_name = "audio_info";
                    audio_info (file_name);
                }
	        } catch (Error e) {
                GLib.warning (e.message);
	        }
        }
        private void video_info (string file_name) {
            File path = File.new_for_uri (file_name);
            label_name.label = path.get_path ();
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

            try {
                Gst.PbUtils.Discoverer discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
                var info = discoverer.discover_uri (file_name);
                var stream_info = info.get_stream_info ();
                Gst.Caps caps = stream_info.get_caps ();
                container.label = "%s: %s".printf(stream_info.get_stream_type_nick (), caps.is_fixed () == true? Gst.PbUtils.get_codec_description (caps) : caps.to_string ());
                container.tooltip_text = "%s: %s".printf(stream_info.get_stream_type_nick (), caps.is_fixed () == true? Gst.PbUtils.get_codec_description (caps) : caps.to_string ());
                ((Gst.PbUtils.DiscovererContainerInfo) stream_info).get_streams ().foreach ((list)=> {
                    if (list.get_stream_type_nick () == "audio") {
                        Gst.Caps acaps = list.get_caps ();
                        container_audio.label = "%s: %s".printf(list.get_stream_type_nick (), acaps.is_fixed () == true? Gst.PbUtils.get_codec_description (acaps) : acaps.to_string ());
                        container_audio.tooltip_text = "%s: %s".printf(list.get_stream_type_nick (), acaps.is_fixed () == true? Gst.PbUtils.get_codec_description (acaps) : acaps.to_string ());
                    }
                    if (list.get_stream_type_nick () == "video") {
                        Gst.Caps vcaps = list.get_caps ();
                        container_video.label = "%s: %s".printf(list.get_stream_type_nick (), vcaps.is_fixed () == true? Gst.PbUtils.get_codec_description (vcaps) : vcaps.to_string ());
                        container_video.tooltip_text = "%s: %s".printf(list.get_stream_type_nick (), vcaps.is_fixed () == true? Gst.PbUtils.get_codec_description (vcaps) : vcaps.to_string ());
                    }
                });
                duration_video.text = seconds_to_time ((int)(info.get_duration ()/1000000000));
                sekable_video.text = info.get_seekable ()? "Yes" : "No";
                info.get_video_streams ().foreach ((list)=> {
                    var stream_video = (Gst.PbUtils.DiscovererVideoInfo)list;
                    video_height.text = "%u".printf (stream_video.get_height ());
                    video_width.text = "%u".printf (stream_video.get_width ());
                    interlaced.text = "%s".printf (stream_video.is_interlaced ()? "Yes" : "No");
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
                string container_fmt;
                if (tag_list.get_string (Gst.Tags.CONTAINER_FORMAT, out container_fmt)) {
                    container_format.text = container_fmt;
                } else {
                    container_format.text = "";
                }
                string audio_cod;
                if (tag_list.get_string (Gst.Tags.AUDIO_CODEC, out audio_cod)) {
                    audio_codec.text = audio_cod;
                } else {
                    audio_codec.text = "";
                }
                string video_cod;
                if (tag_list.get_string (Gst.Tags.VIDEO_CODEC, out video_cod)) {
                    video_codec.text = video_cod;
                } else {
                    video_codec.text = "";
                }
                Gst.DateTime? date_time;
                GLib.Date? time_date;
                if (tag_list.get_date_time (Gst.Tags.DATE_TIME, out date_time)) {
                    date_time_video.text = date_time.to_iso8601_string ();
                } else if (tag_list.get_date (Gst.Tags.DATE, out time_date)) {
                    date_time_video.text = time_date.get_year ().to_string ();
                } else {
                    date_time_video.text = "";
                }
            } catch (Error err) {
                critical ("%s", err.message);
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
                astring.append ("unknown layout");
            }
            return astring.str;
        }

        private void audio_info (string file_name) {
            label_name.label = File.new_for_uri (file_name).get_path ();
            var file = new TagLib.File (File.new_for_uri (file_name).get_path ());
            label_bitrate.label = file.audioproperties.bitrate.to_string () + _(" kHz");
            label_sample.label = file.audioproperties.samplerate.to_string () + _(" bps");
            label_chanel.label = file.audioproperties.channels == 2? _("Stereo") : _("Mono");

            try {
                Gst.PbUtils.Discoverer discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (10 * Gst.SECOND));
                var info = discoverer.discover_uri (file_name);
                label_duration.label = seconds_to_time ((int)(info.get_duration ()/1000000000));
                Gdk.Pixbuf pixbuf_sample = null;
                var tag_list = info.get_tags ();
                var sample = get_cover_sample (tag_list); 
                if (sample == null) {
                    tag_list.get_sample (Gst.Tags.IMAGE, out sample);
                }
                if (sample != null) {
                    var buffer = sample.get_buffer ();
                    if (buffer != null) {
                        pixbuf_sample = get_pixbuf_from_buffer (buffer);
                        if (pixbuf_sample != null) {
                            apply_cover_pixbuf (pixbuf_sample);
                        }
                    }
                } else {
                    apply_cover_pixbuf (new ObjectPixbuf().from_theme_icon ("avatar-default-symbolic", 128, 85));
                }
                string title;
                if (tag_list.get_string (Gst.Tags.TITLE, out title)) {
                    title_entry.text = title;
                } else {
                    title_entry.text = "";
                }
                string artist;
                if (tag_list.get_string (Gst.Tags.ARTIST, out artist)) {
                    artist_entry.text = artist;
                } else {
                    artist_entry.text = "";
                }
                string composer;
                if (tag_list.get_string (Gst.Tags.COMPOSER, out composer)) {
                    composer_entry.text = composer;
                } else {
                    composer_entry.text = "";
                }
                string album;
                if (tag_list.get_string (Gst.Tags.ALBUM, out album)) {
                    album_entry.text = album;
                } else {
                    album_entry.text = "";
                }
                string genre;
                if (tag_list.get_string (Gst.Tags.GENRE, out genre)) {
                    genre_entry.text = genre;
                } else {
                    genre_entry.text = "";
                }
                string comment;
                if (tag_list.get_string (Gst.Tags.COMMENT, out comment)) {
                    comment_textview.buffer.text = comment;
                } else {
                    comment_textview.buffer.text = "";
                }
                string group;
                if (tag_list.get_string (Gst.Tags.GROUPING, out group)) {
                    group_entry.text = group;
                } else {
                    group_entry.text = "";
                }
                uint track_num;
                if (tag_list.get_uint (Gst.Tags.TRACK_NUMBER, out track_num)) {
                    track_spinbutton.value = track_num;
                } else {
                    track_spinbutton.value = 0;
                }
                Gst.DateTime? date_time;
                GLib.Date? time_date;
                if (tag_list.get_date_time (Gst.Tags.DATE_TIME, out date_time)) {
                    date_spinbutton.value = date_time.get_year ();
                } else if (tag_list.get_date (Gst.Tags.DATE, out time_date)) {
                    date_spinbutton.value = time_date.get_year ();
                } else {
                    date_spinbutton.value = 0;
                }
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }
        private Gst.Sample? get_cover_sample (Gst.TagList tag_list) {
            Gst.Sample sample;
            for (int i = 0; tag_list.get_sample_index (Gst.Tags.IMAGE, i, out sample); i++) {
                unowned Gst.Structure caps_struct = sample.get_info ();
                int image_type = Gst.Tag.ImageType.UNDEFINED;
                caps_struct.get_enum ("image-type", typeof (Gst.Tag.ImageType), out image_type);
                if (image_type == Gst.Tag.ImageType.FRONT_COVER) {
                    return sample;
                }
            }
            return sample;
        }

        private Gdk.Pixbuf? get_pixbuf_from_buffer (Gst.Buffer buffer) {
            Gst.MapInfo map_info;
            if (!buffer.map (out map_info, Gst.MapFlags.READ)) {
                return null;
            }
            Gdk.Pixbuf pixbuf_loader = null;
            try {
                var loader = new Gdk.PixbufLoader ();
                if (loader.write (map_info.data) && loader.close ()) {
                    pixbuf_loader = loader.get_pixbuf ();
                }
            } catch (Error err) {
                warning ("%s", err.message);
            }
            buffer.unmap (map_info);
            return pixbuf_loader;
        }
        private void apply_cover_pixbuf (Gdk.Pixbuf save_pixbuf) {
            asyncimage.set_from_pixbuf (align_and_scale_pixbuf (save_pixbuf, 85));
            asyncimage.show ();
        }

        private void run_open_file () {
            var file = new Gtk.FileChooserDialog (
            StringPot.Open, this, Gtk.FileChooserAction.OPEN,
            StringPot.Cancel, Gtk.ResponseType.CANCEL,
            StringPot.Open, Gtk.ResponseType.ACCEPT);
            var preview_area = new AsyncImage (true);
            preview_area.pixel_size = 256;
            preview_area.margin_end = 12;

            var all_files_filter = new Gtk.FileFilter ();
            all_files_filter.set_filter_name (StringPot.All_Files);
            all_files_filter.add_pattern ("*");

            var video_filter = new Gtk.FileFilter ();
            video_filter.set_filter_name (StringPot.Image);
            video_filter.add_mime_type ("image/*");

            file.add_filter (video_filter);
            file.add_filter (all_files_filter);
            file.set_preview_widget (preview_area);
            file.set_preview_widget_active (false);
            file.set_use_preview_label (false);
            file.update_preview.connect (() => {
                string uri = file.get_preview_uri ();
                if (uri != null && uri.has_prefix ("file://")) {
                    var preview_file = File.new_for_uri (uri);
                    if (get_mime_type (preview_file).has_prefix ("image/")) {
                        Gdk.Pixbuf pixbuf = pix_scale (preview_file.get_path (), 256);
                        preview_area.set_from_pixbuf (pixbuf);
                        preview_area.show ();
                        file.set_preview_widget_active (true);
                    }
                } else {
                    preview_area.hide ();
                    file.set_preview_widget_active (false);
                }
            });

            if (file.run () == Gtk.ResponseType.ACCEPT) {
                select_image (file.get_file ().get_path ());
            }
            file.destroy ();
        }

        private void select_image (string inpu_data) {
            var crop_dialog = new CropDialog (inpu_data);
            crop_dialog.show_all ();
            crop_dialog.request_avatar_change.connect (pixbuf_crop);
        }

        private void pixbuf_crop (Gdk.Pixbuf pixbuf) {
            asyncimage.set_from_pixbuf (align_and_scale_pixbuf (pixbuf, 85));
            asyncimage.show ();
        }
    }
}
