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
        private Gtk.Label label_duration;
        private Gtk.Label label_bitrate;
        private Gtk.Label label_chanel;
        private Gtk.Label label_sample;
        private Gtk.Label label_name;
        private Gst.TagList tag_list;
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
                transient_for: window,
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
            var comment_scrolledwindow = new Gtk.ScrolledWindow (null, null);
            comment_scrolledwindow.set_policy (Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.AUTOMATIC);
            comment_scrolledwindow.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            comment_scrolledwindow.add (comment_textview);
            var local_time = new DateTime.now_local ();
            date_spinbutton = new Gtk.SpinButton.with_range (0, local_time.get_year (), 1);
            date_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            track_spinbutton = new Gtk.SpinButton.with_range (0, local_time.get_year (), 1);
            track_spinbutton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var comment_frame = new Gtk.Frame (null);
            comment_frame.expand = true;
            comment_frame.add (comment_scrolledwindow);

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
            grid.margin_start = grid.column_spacing = grid.margin_end = 10;
            grid.attach (new Granite.HeaderLabel (StringPot.Cover), 0, 0, 1, 1);
            grid.attach (imagege_box, 0, 1, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NComment), 1, 0, 1, 1);
            grid.attach (comment_frame, 1, 1, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NTitle), 0, 2, 1, 1);
            grid.attach (title_entry, 0, 3, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NArtist), 1, 2, 1, 1);
            grid.attach (artist_entry, 1, 3, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.Album), 0, 4, 1, 1);
            grid.attach (album_entry, 0, 5, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NGenre), 1, 4, 1, 1);
            grid.attach (genre_entry, 1, 5, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NComposer), 0, 6, 1, 1);
            grid.attach (composer_entry, 0, 7, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NGroup), 1, 6, 1, 1);
            grid.attach (group_entry, 1, 7, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NTrack), 0, 8, 1, 1);
            grid.attach (track_spinbutton, 0, 9, 1, 1);
            grid.attach (new Granite.HeaderLabel (StringPot.NDate), 1, 8, 1, 1);
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

            var grid_combine = new Gtk.Grid ();
            grid_combine.set_size_request (425, 380);
            grid_combine.orientation = Gtk.Orientation.VERTICAL;
            grid_combine.valign = Gtk.Align.FILL;
            grid_combine.add (arrows_grid);
            grid_combine.add (grid);
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
            bool mouse_primary_down = false;
            motion_notify_event.connect ((event) => {
                if (mouse_primary_down) {
                    mouse_primary_down = false;
                    begin_move_drag (Gdk.BUTTON_PRIMARY, (int)event.x_root, (int)event.y_root, event.time);
                }
                return false;
            });

            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    mouse_primary_down = true;
                }
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    mouse_primary_down = false;
                }
                return false;
            });
            string file_name;
            playlist.liststore.get (playlist.select_iter, PlaylistColumns.FILENAME, out file_name);
            set_media (file_name);
        }

        private void previous_track () {
            if (!playlist.liststore.iter_is_valid (playlist.select_iter)) {
                if (!playlist.get_selection().get_selected(null, out playlist.select_iter)) {
                    return;
                }
            }
            if (playlist.model.iter_previous (ref playlist.select_iter)) {
                playlist.get_selection().select_iter (playlist.select_iter);
            }
            if (!playlist.liststore.iter_is_valid (playlist.select_iter)) {
                return;
            }
            string file_name;
            playlist.liststore.get (playlist.select_iter, PlaylistColumns.FILENAME, out file_name);
            set_media (file_name);
        }

        private void next_track () {
            if (!playlist.liststore.iter_is_valid (playlist.select_iter)) {
                if (!playlist.get_selection().get_selected(null, out playlist.select_iter)) {
                    return;
                }
            }
            if (playlist.model.iter_next (ref playlist.select_iter)) {
                playlist.get_selection().select_iter (playlist.select_iter);
            }
            if (!playlist.liststore.iter_is_valid (playlist.select_iter)) {
                return;
            }
            string file_name;
            playlist.liststore.get (playlist.select_iter, PlaylistColumns.FILENAME, out file_name);
            set_media (file_name);
        }

        private bool bus_message_cb (Gst.Bus bus, Gst.Message message) {
            print ("%s\n", message.src.name);
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
                case Gst.MessageType.ELEMENT:
                        unowned Gst.Structure structure = message.get_structure ();
                        print ("%s\n", structure.get_name ());
                    break;
                default :
                    break;
            }
            return true;
        }

        private Gst.TagList create_tags (int mask) {
            Gst.TagList tags = new Gst.TagList.empty ();

            if (mask == 0) {
                tags.add (Gst.TagMergeMode.REPLACE_ALL, Gst.Tags.ARTIST, artist_entry.text);
            }
            if (mask == 1) {
                tags.add (Gst.TagMergeMode.REPLACE_ALL, Gst.Tags.TITLE, title_entry.text);
            }
            if (mask == 2) {
                tags.add (Gst.TagMergeMode.REPLACE_ALL, Gst.Tags.ALBUM, album_entry.text);
            }
  /*          if (mask == (1 << 3)) {
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
       //     if (mask == (1 << 13)) {
       //     }
            return tags;
        }
        private void save_to_file () {
            if (!playlist.get_selection().get_selected(null, out playlist.select_iter)) {
                return;
            }
            string file_name;
            playlist.liststore.get (playlist.select_iter, PlaylistColumns.FILENAME, out file_name);
            for (int i = 0; i < 3; ++i) {
                int mask = (int)Random.next_int ();
     //           print ("tag mask = %i (i=%d)\n", mask, i);
  //              if (mask == 0) {
    //                continue;
   //             }
                Gst.TagList tags = create_tags (mask);
      //          GST_LOG ("tags for mask %08x = %" GST_PTR_FORMAT, mask, tags);

                /* double-check for internal consistency */
       //         test_taglib_id3mux_check_tags (tags, mask);

                /* test with pipeline */
                taglib_gst_tags (tags, mask, file_name);
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
     //       fakesink["signal-handoffs"] = true;
      //      Signal.connect (fakesink, "handoff", (GLib.Callback) got_buffer, outbuf);

            fakesink["silent"] = true;
            filesrc["location"] = File.new_for_uri (file_name).get_path ();
            ((Gst.Bin)pipeline).add_many (filesrc, id3v2mux, identity, id3mux, fakesink);
            Gst.TagSetter tagsetteradd = (Gst.TagSetter) id3v2mux;
            Gst.TagMergeMode merge_mode = tagsetteradd.get_tag_merge_mode ();
           Gst.TagList application_tags = tagsetteradd.get_tag_list ();
            Gst.TagList result = application_tags.merge (tags, merge_mode);
            ((Gst.TagSetter)id3v2mux).merge_tags (result, merge_mode);
            filesrc.link_many (id3v2mux, identity, id3mux, fakesink);
            pipeline.get_bus ().add_watch (Priority.DEFAULT, bus_message_cb);
     //       id3v2mux.link (id3mux);
        //    pipeline.set_state (Gst.State.PAUSED);
            /* set up source */
     //       fakesrc.set ("signal-handoffs", true, "can-activate-pull", false, "filltype", 2, "sizetype", 2, "sizemax", 626, "num-buffers", 16);
        //    pipeline.set_state (Gst.State.NULL);
/*
          offset = 0;
          g_signal_connect (fakesrc, "handoff", G_CALLBACK (fill_mp3_buffer), &offset);


          g_signal_connect (identity, "handoff", G_CALLBACK (identity_cb), &tagbuf);

          GST_LOG ("setting and getting state ...");
          gst_element_set_state (pipeline, GST_STATE_PLAYING);
          Gst.StateChangeReturn state_result = pipeline.get_state (pipeline, NULL, NULL, -1);
          fail_unless (state_result == GST_STATE_CHANGE_SUCCESS,
              "Unexpected result from get_state(). Expected success, got %d",
              state_result);

          bus = gst_pipeline_get_bus (GST_PIPELINE (pipeline));

          GST_LOG ("Waiting for tag ...");
          msg =
              gst_bus_poll (bus, GST_MESSAGE_TAG | GST_MESSAGE_EOS | GST_MESSAGE_ERROR,
              -1);
          if (GST_MESSAGE_TYPE (msg) == GST_MESSAGE_ERROR) {
            GError *err;
            gchar *dbg;

            gst_message_parse_error (msg, &err, &dbg);
            g_printerr ("ERROR from element %s: %s\n%s\n",
                GST_OBJECT_NAME (msg->src), err->message, GST_STR_NULL (dbg));
            g_error_free (err);
            g_free (dbg);
          } else if (GST_MESSAGE_TYPE (msg) == GST_MESSAGE_EOS) {
            g_printerr ("EOS message, but were waiting for TAGS!\n");
          }
          fail_unless (msg->type == GST_MESSAGE_TAG);

          gst_message_parse_tag (msg, &tags_read);
          gst_message_unref (msg);

          GST_LOG ("Got tags: %" GST_PTR_FORMAT, tags_read);
          test_taglib_id3mux_check_tags (tags_read, mask);
          gst_tag_list_unref (tags_read);

          fail_unless (tagbuf != NULL);
          test_taglib_id3mux_check_tag_buffer (tagbuf, mask);
          gst_buffer_unref (tagbuf);

          GST_LOG ("Waiting for EOS ...");
          msg = gst_bus_poll (bus, GST_MESSAGE_EOS | GST_MESSAGE_ERROR, -1);
          if (GST_MESSAGE_TYPE (msg) == GST_MESSAGE_ERROR) {
            GError *err;
            gchar *dbg;

            gst_message_parse_error (msg, &err, &dbg);
            g_printerr ("ERROR from element %s: %s\n%s\n",
                GST_OBJECT_NAME (msg->src), err->message, GST_STR_NULL (dbg));
            g_error_free (err);
            g_free (dbg);
          }
          fail_unless (msg->type == GST_MESSAGE_EOS);
          gst_message_unref (msg);

          gst_object_unref (bus);

          GST_LOG ("Got EOS, shutting down ...");
          gst_element_set_state (pipeline, GST_STATE_NULL);
          gst_object_unref (pipeline);

          test_taglib_id3mux_check_output_buffer (outbuf); */
            uint move_stoped = 0;
                if (move_stoped != 0) {
                    Source.remove (move_stoped);
                }
                move_stoped = GLib.Timeout.add (100,() => {
                pipeline.set_state (Gst.State.PLAYING);
                    move_stoped = 0;
                    return Source.REMOVE;
                });
        }

        private void set_media (string file_name) {
            try {
                Gst.PbUtils.Discoverer discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
                var info = discoverer.discover_uri (file_name);
                Gdk.Pixbuf pixbuf_sample = null;
                tag_list = info.get_tags ();
                var sample = get_cover_sample (tag_list); 
                if (sample == null) {
                    tag_list.get_sample (Gst.Tags.PREVIEW_IMAGE, out sample);
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
                label_name.label = File.new_for_uri (file_name).get_path ();
                label_duration.label = seconds_to_time ((int)(info.get_duration ()/1000000000));
                var file = new TagLib.File (File.new_for_uri (file_name).get_path ());
                label_bitrate.label = file.audioproperties.bitrate.to_string () + _(" kHz");
                label_sample.label = file.audioproperties.samplerate.to_string () + _(" bps");
                label_chanel.label = file.audioproperties.channels == 2? _("Stereo") : _("Mono");
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
                    try {
                        Gdk.Pixbuf pixbuf = null;
                        if (get_mime_type (preview_file).has_prefix ("image/")) {
                            pixbuf = new Gdk.Pixbuf.from_file_at_scale (preview_file.get_path (), 256, 256, true);
                            preview_area.set_from_pixbuf (pixbuf);
                            preview_area.show ();
                            file.set_preview_widget_active (true);
                        }
                    } catch (Error e) {
                        GLib.warning (e.message);
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
