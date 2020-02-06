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
    public class PreviewPopover : Gtk.Popover {
        public PreviewClutterGst? playback;
        public Gtk.Label label_progress;
        private double clutter_height;
        private double clutter_width; 
        private uint loop_timer_id = 0;
        private uint show_timer_id = 0;
        private uint hide_timer_id = 0;
        private uint idle_id = 0;
        private double req_progress = 0;
        public bool req_loop = false;
        private signal void open_popover ();

        construct {
            get_style_context ().add_class ("popover");
            playback = new PreviewClutterGst ();
            playback.set_seek_flags (ClutterGst.SeekFlags.ACCURATE);
            playback.size_change.connect ((width, height) => {
                clutter_height = height; 
                clutter_width = width; 
            });
            NikiApp.settings.changed["uri-video"].connect (load_playback);
            var clutter = new GtkClutter.Embed ();
            clutter.margin = 1;
            var stage = (Clutter.Stage)clutter.get_stage ();
            stage.background_color = Clutter.Color.from_string ("black");
            var aspectratio = new ClutterGst.Aspectratio ();
            aspectratio.player = playback;
            open_popover.connect (() => {
                if (clutter_width > 0 && clutter_height > 0 && !NikiApp.settings.get_boolean ("audio-video")) {
                    double diagonal_window = GLib.Math.sqrt (((NikiApp.settings.get_int ("window-width") * NikiApp.settings.get_int ("window-width")) + (NikiApp.settings.get_int ("window-height") * NikiApp.settings.get_int ("window-height")))/45);
                    double diagonal = Math.sqrt ((clutter_width * clutter_width)  + (clutter_height * clutter_height));
                    double k = (diagonal_window / diagonal);
                    stage.set_size ((int)(clutter_width * k), (int)(clutter_height * k));
                    clutter.set_size_request ((int)(clutter_width * k), (int)(clutter_height * k));
                } else {
                    clutter.set_size_request (60, 20);
                }
            });
            label_progress = new Gtk.Label (null);
            label_progress.get_style_context ().add_class ("label_popover");
            var main_actionbar = new Gtk.HeaderBar ();
            main_actionbar.get_style_context ().add_class ("ground_action_button");
            main_actionbar.has_subtitle = false;
            main_actionbar.custom_title = label_progress;
            main_actionbar.show_all ();
            var label_progress_actor = new GtkClutter.Actor.with_contents (main_actionbar);
            label_progress_actor.add_constraint (new Clutter.AlignConstraint (stage, Clutter.AlignAxis.Y_AXIS, 1));
            label_progress_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 1));
            stage.add_child (label_progress_actor);
            stage.content = aspectratio;
            modal = false;
            can_focus = false;
            opacity = 255;
            add (clutter);
            hide ();
            load_playback ();
        }

        public void load_playback () {
            Idle.add (() => {
                if (NikiApp.settings.get_boolean("home-signal")) {
                    playback.uri = null;
                } else {
                    playback.uri = NikiApp.settings.get_string ("uri-video");
                    playback.playing = false;
                }
                return Source.REMOVE;
            });
        }
        public void set_preview_progress (double progress, bool loop = false) {
            req_progress = progress;
            req_loop = loop;
            if (!visible || idle_id > 0) {
                return;
            }

            if (loop) {
                cancel_timer (ref loop_timer_id);
            }

            idle_id = Idle.add_full (GLib.Priority.LOW, () => {
                playback.playing = false;
                playback.progress = progress;
                playback.playing = loop;
                if (loop) {
                    loop_timer_id = Timeout.add_seconds (5, () => {
                        set_preview_progress (progress, true);
                        loop_timer_id = 0;
                        return false;
                    });
                }
                idle_id = 0;
                return false;
            });
        }

        public void update_pointing (int x) {
            var pointing = pointing_to;
            pointing.x = x;
            if (pointing.width == 0) {
                pointing.width = 2;
                pointing.x -= 1;
            } else {
                pointing.width = 0;
            }
            set_pointing_to (pointing);
        }

        public void schedule_show () {
            if (show_timer_id > 0) {
                return;
            }
            cancel_timer (ref hide_timer_id);
            open_popover ();
            show_timer_id = Timeout.add (350, () => {
                show_all ();
                if (req_progress >= 0) {
                    set_preview_progress (req_progress, req_loop);
                }
                show_timer_id = 0;
                return false;
            });
        }

        public void schedule_hide () {
            if (hide_timer_id > 0) {
                return;
            }
            cancel_timer (ref show_timer_id);
            open_popover ();
            hide_timer_id = Timeout.add (350, () => {
                hide ();
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
    }
}
