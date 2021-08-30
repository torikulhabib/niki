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
    public class Spectrum : Gtk.Grid {
        private PlayerPage playerpage;
        private double[] m_magnitudes;
        private Gtk.Grid m_bands;
        private bool m_update;
        private Gtk.Label anim_area;
        private Pango.Layout layout;
        private uint remove_time = 0;
        private int animstep = 0;
        private int state = 0;
        private Gtk.Allocation allocation;

        public Spectrum (PlayerPage playerpage) {
            this.playerpage = playerpage;
            orientation = Gtk.Orientation.VERTICAL;
            m_bands = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                column_spacing = 6,
                row_homogeneous = true,
                column_homogeneous = false,
                margin = 5
            };
            m_bands.show_all ();
            playerpage.playback.updated.connect (on_spectrum_updated);
            m_magnitudes = new double[10];
            for (int cpt = 0; cpt < 10; ++cpt) {
                m_bands.add (level_music (this, cpt));
            }
            anim_area = new Gtk.Label (null) {
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            layout = anim_area.create_pango_layout (null);
            anim_area.draw.connect (anim_draw);
            anim_area.show_all ();
            add (anim_area);
            add (m_bands);
            NikiApp.settings.changed["album-music"].connect (()=>{
                if (remove_time > 0) {
                    Source.remove (remove_time);
                }
                remove_time = 0;
                animstep = 0;
                state = 0;
                remove_time = Timeout.add (50, animation_timer);
            });
            remove_time = Timeout.add (50, animation_timer);
            playerpage.size_allocate.connect (size_alocate);
        }

        public void size_alocate () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                int height;
                ((Gtk.Window) playerpage.get_toplevel ()).get_size (null, out height);
                var n_width = playerpage.cover_center.width = 150 + ((height / 10));
                var n_height = playerpage.cover_center.height = 150 + ((height / 10));
                set_size_request ((int)n_width, (int)n_height);
                allocation.height = (int) n_height;
                allocation.width = (int) n_width;
                set_allocation (allocation);
                anim_area.width_request = allocation.width;
            }
        }

        private bool anim_draw (Cairo.Context cr) {
            int width, height;
            layout.get_pixel_size (out width, out height);
            cr.set_source_rgba (0, 0, 0, 0.3);
            cr.rectangle (0, 0, get_allocated_width (), 15);
            cr.fill ();
            Gtk.Allocation c_allocation;
            anim_area.get_allocation (out c_allocation);

            int y = (c_allocation.height - height) / 2;
            int x = (c_allocation.width - width) / 2;
            cr.set_source_rgba (1, 1, 1, 1);
            cr.move_to (x, y);
            cr.push_group ();
            Pango.cairo_show_layout (cr, layout);
            cr.pop_group_to_source ();
            cr.paint ();
            return false;
        }

        private void decorate_text (double time) {
            Pango.Attribute attr;
            Pango.AttrList attrlist = new Pango.AttrList ();
            attr = Pango.attr_letter_spacing_new ((int)((1.0 - time) * 60000));
            attrlist.change ((owned) attr);
            attr = Pango.attr_weight_new (Pango.Weight.BOLD);
            attrlist.change ((owned) attr);
            layout.set_attributes (attrlist);
        }

        private bool animation_timer () {
            int timeout = 0;
            if (animstep == 0) {
                string text = null;
                switch (state) {
                    case 0:
                        remove_time = Timeout.add (50, animation_timer);
                        state += 1;
                        return false;
                    case 1:
                        text = _("Album");
                        state += 1;
                        break;
                    case 2:
                        text = NikiApp.settings.get_string ("album-music");
                        state += 1;
                        break;
                    case 3:
                        remove_time = 0;
                        animstep = 0;
                        state = 0;
                        return false;
                }
                layout.set_text (NikiApp.settings.get_boolean ("audio-video") && NikiApp.window.main_stack.visible_child_name == "player"? text : "Niki", -1);
                layout.set_attributes (null);
            }

            if (animstep < 16) {
                decorate_text ((animstep) / 15.0);
            } else if (animstep == 16) {
                timeout = 900;
            } else if (animstep == 17) {
                timeout = 40;
            } else if (animstep < 35) {
                if (state != 3) {
                    decorate_text (1.0 - (animstep - 17) / 15.0);
                }
            } else if (animstep == 35) {
                timeout = 300;
            } else {
                animstep = -1;
                timeout = 40;
            }
            animstep++;
            if (timeout > 0) {
                remove_time = Timeout.add (timeout, animation_timer);
                return false;
            }
            return true;
        }

        private void on_spectrum_updated () {
            unowned float[] magnitudes = playerpage.playback.m_magnitudes;
            for (int band = 0; band < 10; ++band) {
                double val = magnitudes[band];
                if (m_magnitudes[band] != val) {
                    m_magnitudes[band] = val;
                    m_update = true;
                }
            }
            if (m_update) {
                queue_draw ();
            }
        }

        private double iec_scale (double in_db) {
            double def = 0.0;

            if (in_db < -70.0) {
                def = 00.0;
            } else if (in_db < -60.0) {
                def = (in_db + 70.0) * 0.25;
            } else if (in_db < -50.0) {
                def = (in_db + 60.0) * 0.5 + 2.5;
            } else if (in_db < -40.0) {
                def = (in_db + 50.0) * 0.75 + 7.5;
            } else if (in_db < -30.0) {
                def = (in_db + 40.0) * 1.5 + 15.0;
            } else if (in_db < -20.0) {
                def = (in_db + 30.0) * 2.0 + 30.0;
            } else if (in_db < 0.0) {
                def = (in_db + 20.0) * 2.5 + 50.0;
            } else {
                def = 100.0;
            }
            return def / 100.0;
        }

        private new double @get (int in_index) requires (in_index >= 0 && in_index < m_magnitudes.length) {
            return iec_scale (10 + m_magnitudes[in_index]);
        }
        private Gtk.DrawingArea level_music (Spectrum spectrum, int m_band) {
            var drawing = new Gtk.DrawingArea ();
            double m_max = 0;
            drawing.expand = true;
            drawing.draw.connect ((in_ctx)=> {
                int width = drawing.get_allocated_width ();
                int height = drawing.get_allocated_height ();

                var gradient = new Cairo.Pattern.linear (0, height, 0, 0);
                gradient.add_color_stop_rgba (0.0, (double)0x40 / (double)0xff, (double)0xff / (double)0xff, (double)0x00 / (double)0xff, 0.15);
                gradient.add_color_stop_rgba (spectrum.iec_scale (-10), (double)0xd4 / (double)0xff, (double)0x8e / (double)0xff, (double)0x15 / (double)0xff, 0.15);
                gradient.add_color_stop_rgba (spectrum.iec_scale (-5), (double)0xc6 / (double)0xff, (double)0x26 / (double)0xff, (double)0x2e / (double)0xff, 0.15);

                double gain = spectrum[m_band];
                in_ctx.set_source (gradient);
                in_ctx.rectangle (0, height - height * gain, width, height * gain);
                in_ctx.fill ();

                if (gain >= m_max) {
                    m_max = gain;
                } else {
                    double pos = (double)height * m_max;
                    pos -= 4.0;
                    m_max = double.max (0.0, pos / (double)height);
                }
                in_ctx.rectangle (0, height - height * m_max, width, 4.0);
                in_ctx.fill ();
                spectrum.m_update |= m_max > 0;
                return false;
            });
            return drawing;
        }
    }
}
