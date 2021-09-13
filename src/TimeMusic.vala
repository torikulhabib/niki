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
    public class TimeMusic : Gtk.Revealer {
        public signal void position_sec (int64 position);
        public Gtk.Label progression_label;
        public Gtk.Label duration_label;
        private Gtk.Button make_lrc_but;
        private Gtk.Button search_time_lrc;
        private Gtk.Box actionbar;
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

        public TimeMusic (Player playback) {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
            transition_duration = 500;
            playback.notify["progress"].connect (() => {
                playback_progress = playback.progress;
            });
            playback.notify["duration"].connect (() => {
                playback_duration = playback.duration;
            });

            progression_label = new Gtk.Label (null) {
                selectable = true,
                width_request = 50
            };
            progression_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            progression_label.get_style_context ().add_class ("selectedlabel");
            progression_label.get_style_context ().add_class ("h3");

            duration_label = new Gtk.Label (null) {
                selectable = true,
                width_request = 50
            };
            duration_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            duration_label.get_style_context ().add_class ("selectedlabel");
            duration_label.get_style_context ().add_class ("h3");

            make_lrc_but = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.make-lrc-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Make Lyric")
            };
            make_lrc_but.get_style_context ().add_class ("button_action");
            make_lrc_but.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            make_lrc_but.clicked.connect (() => {
                NikiApp.settings.set_boolean ("make-lrc", !NikiApp.settings.get_boolean ("make-lrc"));
            });
            search_time_lrc = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.time-lrc-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            search_time_lrc.get_style_context ().add_class ("button_action");
            search_time_lrc.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            search_time_lrc.clicked.connect (() => {
                if (NikiApp.settings.get_boolean ("make-lrc")) {
                    position_sec ((int64)playback.position);
                } else {
                    var search_lrc = new SearchDialog ();
                    search_lrc.show_all ();
                }
            });
            anim_area = new Gtk.DrawingArea () {
                halign = Gtk.Align.CENTER
            };
            layout = anim_area.create_pango_layout (null);
            int height;
            layout.get_pixel_size (null, out height);
            anim_area.height_request = height;
            anim_area.draw.connect (anim_draw);

            actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                margin_start = 5,
                margin_end = 5,
                hexpand = true
            };
            actionbar.get_style_context ().add_class ("transbgborder");
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            actionbar.pack_start (progression_label, false, false, 0);
            actionbar.pack_start (search_time_lrc, false, false, 0);
            actionbar.set_center_widget (anim_area);
            actionbar.pack_end (duration_label, false, false, 0);
            actionbar.pack_end (make_lrc_but, false, false, 0);
            add (actionbar);
            show_all ();
            NikiApp.settings.changed["make-lrc"].connect (seach_n_time);
            seach_n_time ();
            Timeout.add (50, animation_timer);
        }

        private void seach_n_time () {
            ((Gtk.Image) search_time_lrc.image).icon_name = NikiApp.settings.get_boolean ("make-lrc")? "com.github.torikulhabib.niki.time-lrc-symbolic" : "system-search-symbolic";
            search_time_lrc.tooltip_text = NikiApp.settings.get_boolean ("make-lrc")? _("Set Time Lyric") : _("Search Lyrics");
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
            actionbar.get_allocation (out allocation);
            int width, height;
            layout.get_pixel_size (out width, out height);
            int y = (allocation.height - height) / 2;
            int x = ((allocation.width / 2) - width) / 2;
            cr.move_to (x, y);
            cr.push_group ();
            Pango.cairo_show_layout (cr, layout);
            cr.pop_group_to_source ();
            cr.paint_with_alpha (alpha);
            return false;
        }

        private void decorate_text (int anim_type, double time, int state) {
            Pango.Attribute attr;
            string text = layout.get_text ();
            if (NikiApp.settings.get_boolean ("audio-video")) {
                anim_area.width_request = (actionbar.get_allocated_width () / 2);
            } else {
                anim_area.width_request = 10;
            }
            Pango.AttrList attrlist = new Pango.AttrList ();

            switch (anim_type) {
                case 0:
                    break;
                case 1:
                    attr = Pango.attr_letter_spacing_new ((int)((1.0 - time) * 60000));
                    attrlist.change ((owned) attr);
                    break;
                case 2:
                    for (int i = 0; i < text.char_count (); i++) {
                        attr = Pango.attr_rise_new ((int)((1.0 - time) * 18000 * GLib.Math.sin (6.0 * time + i * 0.7)));
                        attr.start_index = i;
                        attr.end_index = text.char_count ();
                        attrlist.change ((owned) attr);
                    }
                    break;
            }
            if (state % 2 == 0 && state != 0) {
                attr = Pango.attr_weight_new (Pango.Weight.SEMIBOLD);
                attrlist.change ((owned) attr);
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
                        text = _("Title");
                        state += 1;
                        break;
                    case 2:
                        text = NikiApp.settings.get_string ("title-playing");
                        state += 1;
                      break;
                    case 3:
                        text = _("Artist");
                        state += 1;
                        break;
                    case 4:
                        text = NikiApp.settings.get_string ("artist-music");
                        state += 1;
                        break;
                    case 5:
                        text = _("Album");
                        state += 1;
                        break;
                    case 6:
                        text = NikiApp.settings.get_string ("album-music");
                        state += 1;
                        break;
                    case 7:
                        text = _("Equalizer");
                        state += 1;
                        break;
                    case 8:
                        text = NikiApp.settings.get_string ("tooltip-equalizer");
                        state += 1;
                        break;
                    case 9:
                        if (NikiApp.settings.get_boolean ("make-lrc")) {
                            text = _("Lyric Make ON");
                        } else {
                            text = _("Lyric Make OFF");
                        }
                        state += 1;
                        break;
                    case 10:
                        if (NikiApp.settings.get_boolean ("make-lrc")) {
                            text = _("Lets Make Lyric");
                        } else {
                            text = _("Happy listening!");
                        }
                        state = 0;
                        break;
                }
                layout.set_text (NikiApp.settings.get_boolean ("audio-video") && NikiApp.window.main_stack.visible_child_name == "player"? text : "Niki", -1);
                layout.set_attributes (null);
            }

            if (animstep < 16) {
                decorate_text (2, (animstep) / 15.0, state);
            } else if (animstep == 16) {
                timeout = 900;
            } else if (animstep == 17) {
                timeout = 40;
            } else if (animstep < 35) {
                decorate_text (1, 1.0 - (animstep - 17) / 15.0, state);
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
            return true;
        }
    }
}
