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
    public class Spectrum : Gtk.Grid {
        private const int c_offset = 10;
        public PlaybackPlayer playback;
        private double[] m_magnitudes;
        private Gtk.Grid m_bands;
        private Gtk.Label label;
        private bool m_update;
        public int nb_bands = 10;

        public Spectrum (PlaybackPlayer playback) {
            this.playback = playback;
            set_size_request (250, 250);
            orientation = Gtk.Orientation.VERTICAL;
            m_bands = new Gtk.Grid ();
            m_bands.orientation = Gtk.Orientation.HORIZONTAL;
            m_bands.column_spacing = 6;
            m_bands.row_homogeneous = true;
            m_bands.column_homogeneous = true;
            m_bands.margin = 5;
            m_bands.show_all ();
            playback.updated.connect (on_spectrum_updated);
            m_magnitudes = new double[nb_bands];
            for (int cpt = 0; cpt < nb_bands; ++cpt) {
                m_bands.add (level_music (this, cpt));
            }
            label = new Gtk.Label (null);
            label.get_style_context ().add_class ("label_popover");
            label.ellipsize = Pango.EllipsizeMode.END;
            label.max_width_chars = 20;
            add (label);
            add (m_bands);
            NikiApp.settings.changed["album-music"].connect (label_set);
            label_set ();
        }
        private void label_set () {
            label.tooltip_text = label.label = NikiApp.settings.get_string ("album-music");
        }

        private void on_spectrum_updated () {
            unowned float[] magnitudes = playback.audiomix.get_magnitudes ();
            for (int band = 0; band < nb_bands; ++band) {
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

        private double iec_scale (double inDB) {
            double def = 0.0;

            if (inDB < -70.0) {
                def = 00.0;
            } else if (inDB < -60.0) {
                def = (inDB + 70.0) * 0.25;
            } else if (inDB < -50.0) {
                def = (inDB + 60.0) * 0.5 + 2.5;
            } else if (inDB < -40.0) {
                def = (inDB + 50.0) * 0.75 + 7.5;
            } else if (inDB < -30.0) {
                def = (inDB + 40.0) * 1.5 + 15.0;
            } else if (inDB < -20.0) {
                def = (inDB + 30.0) * 2.0 + 30.0;
            } else if (inDB < 0.0) {
                def = (inDB + 20.0) * 2.5 + 50.0;
            } else {
                def = 100.0;
            }
            return def / 100.0;
        }

        private new double @get (int in_index) requires (in_index >= 0 && in_index < m_magnitudes.length) {
            return iec_scale (c_offset + m_magnitudes[in_index]);
        }
        private Gtk.DrawingArea level_music (Spectrum spectrum, int m_band) {
            var drawing = new Gtk.DrawingArea ();
            double m_max = 0;
            drawing.expand = true;
            drawing.draw.connect ((in_ctx)=> {
                int width = drawing.get_allocated_width ();
                int height = drawing.get_allocated_height ();

                var gradient = new Cairo.Pattern.linear (0, height, 0, 0);
                gradient.add_color_stop_rgb (0.0, (double)0x2d / (double)0xff, (double)0xb7 / (double)0xff, (double)0x23 / (double)0xff);
                gradient.add_color_stop_rgb (spectrum.iec_scale (-10), (double)0xd4 / (double)0xff, (double)0x8e / (double)0xff, (double)0x15 / (double)0xff);
                gradient.add_color_stop_rgb (spectrum.iec_scale (-5), (double)0xc6 / (double)0xff, (double)0x26 / (double)0xff, (double)0x2e / (double)0xff);

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
