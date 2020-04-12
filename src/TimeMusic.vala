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
    public class TimeMusic : Gtk.Revealer {
        public signal void position_sec (int64 position);
        public Gtk.Label progression_label;
        public Gtk.Label duration_label;
        private Gtk.Button make_lrc_but;
        private Gtk.Button set_time_lrc;
        private Pango.Layout layout;
        private Gtk.DrawingArea anim_area;
        private uint remove_time = 0;
        private int animstep = 0;
        private int state = 0;

        private double _playback_duration;
        public double playback_duration {
            get {
                return _playback_duration;
            }
            set {
                double duration = value;
                if (duration < 0.0) {
                    duration = 0.0;
                }
                _playback_duration = duration;
                duration_label.label = seconds_to_time ((int) duration);
            }
        }

        private double _playback_progress;
        public double playback_progress {
            get {
                return _playback_progress;
            }
            set {
                double progress = value;
                if (progress < 0.0) {
                    progress = 0.0;
                } else if (progress > 1.0) {
                    progress = 1.0;
                }
                _playback_progress = progress;
                progression_label.label = seconds_to_time ((int) (progress * playback_duration));
            }
        }

        public TimeMusic (ClutterGst.Playback playback) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            transition_duration = 500;
            playback.notify["progress"].connect (() => {
                playback_progress = playback.progress;
            });
            playback.notify["duration"].connect (() => {
                playback_duration = playback.duration;
            });

            progression_label = new Gtk.Label (null);
            progression_label.get_style_context ().add_class ("selectedlabel");
            progression_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            progression_label.selectable = true;
            progression_label.width_request = 50;
            duration_label = new Gtk.Label (null);
            duration_label.get_style_context ().add_class ("selectedlabel");
            duration_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            duration_label.selectable = true;
            duration_label.width_request = 50;

            make_lrc_but = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.make-lrc-symbolic", Gtk.IconSize.BUTTON);
            make_lrc_but.get_style_context ().add_class ("button_action");
            make_lrc_but.tooltip_text = StringPot.Make_Lyric;
            make_lrc_but.clicked.connect (() => {
                NikiApp.settings.set_boolean ("make-lrc", !NikiApp.settings.get_boolean ("make-lrc"));
            });
            set_time_lrc = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.time-lrc-symbolic", Gtk.IconSize.BUTTON);
            set_time_lrc.get_style_context ().add_class ("button_action");
            set_time_lrc.tooltip_text = StringPot.Set_Time_Lyric;
            set_time_lrc.clicked.connect (() => {
                position_sec ((int64)(playback.get_position () * 1000000));
            });
            anim_area = new Gtk.DrawingArea ();
            anim_area.halign = Gtk.Align.CENTER;
            layout = anim_area.create_pango_layout (null);
            int height;
            layout.get_pixel_size (null, out height);
            anim_area.height_request = height;
            anim_area.draw.connect (anim_draw);
            anim_area.show ();

            var actionbar = new Gtk.ActionBar ();
            actionbar.get_style_context ().add_class ("transbgborder");
            actionbar.pack_start (progression_label);
            actionbar.pack_start (set_time_lrc);
            actionbar.set_center_widget (anim_area);
            actionbar.pack_end (duration_label);
            actionbar.pack_end (make_lrc_but);
            actionbar.hexpand = true;
            add (actionbar);
            show_all ();
            NikiApp.settings.changed["player-mode"].connect (start_anime);
            playback.notify["playing"].connect (start_anime);
        }
        private void start_anime () {
            if (remove_time > 0 && NikiApp.settings.get_boolean("audio-video") && NikiApp.window.main_stack.visible_child_name == "player") {
                Source.remove (remove_time);
            }
            remove_time = Timeout.add (40, animation_timer);
        }
        private bool anim_draw (Cairo.Context cr) {
            double alpha = 0;
            if (animstep < 16) {
                alpha = animstep / 15.0;
            } else if (animstep < 18) {
                alpha = 1.0;
            } else if (animstep < 35) {
                alpha = 1.0 - (animstep - 17) / 15.0;
            }

            Gtk.StyleContext style = get_style_context ();
            Gdk.RGBA color = style.get_color (style.get_state ());
            Gdk.cairo_set_source_rgba (cr, color);
            Gtk.Allocation allocation;
            get_allocation (out allocation);
            int height, y;
            layout.get_pixel_size (null, out height);
            y = (allocation.height - height) / 2;
            cr.move_to (-1, y);
            cr.push_group ();
            Pango.cairo_show_layout (cr, layout);
            cr.pop_group_to_source ();
            cr.paint_with_alpha (alpha);
            return false;
        }
        private void decorate_text (int anim_type, double time) {
            Pango.Attribute attr;
            string text = layout.get_text ();
            int width;
            layout.get_pixel_size (out width, null);
            anim_area.width_request = width;
            Pango.AttrList attrlist = new Pango.AttrList ();

            switch (anim_type) {
                case 0:
                    break;
                case 1:
                    for (int i = 0; i < text.char_count (); i++) {
                        attr = Pango.attr_rise_new ((int)((1.0 -time) * 60000));
                        attrlist.change ((owned) attr);
                    }
                    break;
                case 2:
                    int letter_count = 0;
                    for (int i = 0; i < text.char_count (); i++) {
                        attr = Pango.attr_rise_new ((int)((1.0 -time) * 18000 * GLib.Math.sin (6.0 * time + letter_count * 0.7)));
                        attr.start_index = i;
                        attr.end_index = text.char_count ();
                        attrlist.change ((owned) attr);
                        letter_count++;
                    }
                    break;
            }
            layout.set_attributes (attrlist);
        }
        private bool animation_timer () {
            int timeout = 0;
            if (animstep == 0) {
                string text = null;
                switch (state) {
                    case 0:
                        remove_time = Timeout.add (40, animation_timer);
                        state += 1;
                        return false;
                    case 1:
                        text = StringPot.Title;
                        state += 1;
                        break;
                    case 2:
                        text = NikiApp.settings.get_string ("title-playing");
                        state += 1;
                      break;
                    case 3:
                        text = StringPot.Artist;
                        state += 1;
                        break;
                    case 4:
                        text = NikiApp.settings.get_string ("artist-music");
                        state += 1;
                        break;
                    case 5:
                        text = StringPot.Album;
                        state += 1;
                        break;
                    case 6:
                        text = NikiApp.settings.get_string ("album-music");
                        state += 1;
                        break;
                    case 7:
                        text = StringPot.Equalizer;
                        state += 1;
                        break;
                    case 8:
                        text = NikiApp.settings.get_string ("tooltip-equalizer");
                        state = 0;
                        break;
                }
                layout.set_text (NikiApp.settings.get_boolean("audio-video")? text : "", -1);
                layout.set_attributes (null);
            }

            if (animstep < 16) {
                decorate_text (2, (animstep) / 15.0);
            } else if (animstep == 16) {
                timeout = 900;
            } else if (animstep == 17) {
                timeout = 40;
            } else if (animstep < 35) {
                decorate_text (1, 1.0 - (animstep - 17) / 15.0);
            } else if (animstep == 35) {
                timeout = 300;
            } else {
                animstep = -1;
                timeout = 40;
            }
            animstep++;
            anim_area.queue_draw ();
            if (timeout > 0) { 
                remove_time = Timeout.add (timeout, animation_timer);
                return false;
            }
            return NikiApp.settings.get_boolean("audio-video") && NikiApp.window.main_stack.visible_child_name == "player";
        }
    }
}
