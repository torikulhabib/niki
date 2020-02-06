namespace niki {
    public class CameraPage : GtkClutter.Embed {
        public CameraPlayer? cameraplayer;
        public Clutter.Stage stage;
        private ClutterGst.Aspectratio aspect_ratio;
        private Clutter.Text notify_center;
        private Clutter.Text notify_text;
        private Clutter.PropertyTransition transition;
        private CameraLeftBar? cameraleftbar;
        private CameraRightBar? camerarightbar;
        private GtkClutter.Actor left_actor;
        private GtkClutter.Actor right_actor;
        public CameraTopBar? cameratopbar;
        private GtkClutter.Actor top_actor;
        public CameraBottomBar? camerabottombar;
        private GtkClutter.Actor bottom_actor;

        public CameraPage (Window window) {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            cameraplayer = new CameraPlayer (this);
            stage = this.get_stage () as Clutter.Stage;
            stage.background_color = Clutter.Color.from_string ("black");
            aspect_ratio = new ClutterGst.Aspectratio ();
            aspect_ratio.sink = cameraplayer.videosink as ClutterGst.VideoSink;
            stage.content = aspect_ratio;
            set_size_request (570, 450);

            notify_text = new Clutter.Text ();
            notify_text.ellipsize = Pango.EllipsizeMode.END;
            notify_text.color = Clutter.Color.from_string ("white");
            notify_text.background_color = Clutter.Color.from_string ("black") { alpha = 80 };
            notify_text.font_name = "Bitstream Vera Sans Bold 10";
            notify_text.line_alignment = Pango.Alignment.CENTER;
            notify_text.use_markup = true;
            stage.add_child (notify_text);

            notify_center = new Clutter.Text ();
            notify_center.ellipsize = Pango.EllipsizeMode.END;
            notify_center.color = Clutter.Color.from_string ("white");
            notify_center.background_color = Clutter.Color.from_string ("black") { alpha = 0 };
            notify_center.font_name = "Lato Bold 70";
            notify_center.line_alignment = Pango.Alignment.CENTER;
            stage.add_child (notify_center);

            camerarightbar = new CameraRightBar (this);
            right_actor = new GtkClutter.Actor ();
            right_actor.contents = camerarightbar;
            right_actor.opacity = 255;
            right_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.X_AXIS, 1));
            right_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 1));
            stage.add_child (right_actor);

            cameraleftbar = new CameraLeftBar (this);
            left_actor = new GtkClutter.Actor ();
            left_actor.contents = cameraleftbar;
            left_actor.opacity = 255;
            left_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.X_AXIS, 0));
            left_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 1));
            stage.add_child (left_actor);

            cameratopbar = new CameraTopBar ();
            top_actor = new GtkClutter.Actor ();
            top_actor.contents = cameratopbar;
            top_actor.opacity = 255;
            top_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 0));
            top_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            stage.add_child (top_actor);

            camerabottombar = new CameraBottomBar (this);
            bottom_actor = new GtkClutter.Actor ();
            bottom_actor.contents = camerabottombar;
            bottom_actor.opacity = 255;
            bottom_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 1));
            bottom_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 1));
            stage.add_child (bottom_actor); 
            show_all ();
            bool mouse_primary_down = false;
            motion_notify_event.connect ((event) => {
                if (mouse_primary_down) {
                    mouse_primary_down = false;
                    window.begin_move_drag (Gdk.BUTTON_PRIMARY, (int)event.x_root, (int)event.y_root, event.time);
                }
                return false;
            });

            button_press_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    mouse_primary_down = true;
                }
                if (event.button == Gdk.BUTTON_PRIMARY && event.type == Gdk.EventType.2BUTTON_PRESS && !cameraleftbar.hovered && !camerarightbar.hovered && !cameratopbar.hovered && !camerabottombar.hovered) {
                    NikiApp.settings.set_boolean ("fullscreen", !NikiApp.settings.get_boolean ("fullscreen"));
                }
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_PRIMARY) {
                    mouse_primary_down = false;
                }
                return false;
            });
            transition = new Clutter.PropertyTransition ("translation_z");
            notify_center.transition_stopped.connect (transition_stoped);
            size_allocate.connect (reposition);
            NikiApp.settings.changed["camera-video"].connect (camera_record);
            NikiApp.settings.changed["fullscreen"].connect (() => {
                if (!NikiApp.settings.get_boolean("fullscreen")) {
                    notify_fullscreen ();
                } else {
                    notify_blank ();
                }
            });
        }
        public void string_notify (string notify_string) {
            notify_text.text = "\n     " + notify_string + "     \n";
            notify_control ();
        }

        private void camera_record () {
            if (!NikiApp.settings.get_boolean ("camera-video")) {
                string_notify (StringPot.Camera_Mode);
            } else {
                string_notify (StringPot.Video_Mode);
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
        private void reposition () {
            notify_blank ();
            transition.set_to_value(stage.height - notify_center.width);
        }
        private bool animation_on = false;
        public void notify_center_text (string text_in) {
            notify_center.text = text_in;
            notify_center.x = (stage.width / 2) - (notify_center.width / 2);
            notify_center.y = (stage.height / 2) - (notify_center.height / 2);
            if (!animation_on) {
                animation_run ();
            } else {
                transition.set_duration (1524);
            }
            animation_on = true;
        }
        private void animation_run () {
            transition.set_to_value(stage.height - notify_center.width);
            transition.set_progress_mode(Clutter.AnimationMode.EASE_IN_OUT_SINE);
            transition.set_direction(Clutter.TimelineDirection.FORWARD);
            transition.set_duration (2100);
            transition.repeat_count = NikiApp.settings.get_enum ("camera-delay") - 1;
            notify_center.add_transition("animation", transition);
        }
        private void transition_stoped () {
            notify_center.x = -notify_center.width;
            notify_center.y = -notify_center.height;
            notify_center.remove_transition("animation");
            animation_on = false;
        }
        public void capture_record (bool input) {
            if (!NikiApp.settings.get_boolean ("camera-video")) {
                on_take_photo ();
            } else {
                if (input) {
                    cameraplayer.capture_video_photo ();
                } else {
                    cameraplayer.player_stop_recording ();
                }
            }
        }

        private void on_take_photo () {
            var timeout = NikiApp.settings.get_enum ("camera-delay");
            start_timeout (timeout);
            GLib.Timeout.add_seconds (timeout, () => {
                transition.stop ();
                cameraplayer.capture_video_photo ();
                return false;
            });
        }

        private void start_timeout (int time) {
            var timeout_reached = time == 0;
            camerabottombar.sensitive = timeout_reached;
            camerarightbar.sensitive = timeout_reached;
            if (!timeout_reached) {
                notify_center_text (time.to_string ());
                play_sound ("message");
                Timeout.add_seconds (1, () => {
                    start_timeout (time - 1);
                    if (transition.get_elapsed_time () != 0) {
                        transition.skip (1024);
                    }
                    return false;
                });
            }
        }
        public void ready_play () {
		    cameraplayer.init_open ();
        }
        public void zoom_in_out (double zoom) {
            string_notify ("%s %2.1f".printf (StringPot.Zoom_X, zoom));
            cameraplayer.input_zoom (zoom);
        }

        private void notify_fullscreen () {
            GLib.Timeout.add (500, () => {
                if (NikiApp.settings.get_boolean("fullscreen")) {
                    return Source.REMOVE;
                }
                string_notify (StringPot.Press_Esc);
                return Source.REMOVE;
            });
        }
    }
}
