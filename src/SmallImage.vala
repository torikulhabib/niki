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
    public class SmallImage : Clutter.Canvas {
        private PlayerPage playerpage;
        private Gdk.Pixbuf background;
        private Gst.TagList taglist;
        private string urivideo;

        public SmallImage (PlayerPage playerpage) {
            this.playerpage = playerpage;
            playerpage.small_cover.set_pivot_point (0.5f, 0.5f);
            playerpage.playback.ready.connect (audio_banner);
            playerpage.playback.idle.connect (audio_banner);
            playerpage.size_allocate.connect (size_alocate);
            playerpage.playback.albumart_changed.connect ((new_taglist)=> {
                if (urivideo != (NikiApp.settings.get_string ("title-playing") + NikiApp.settings.get_string ("artist-music"))) {
                    Gst.Sample sample;
                    new_taglist.get_sample (Gst.Tags.IMAGE, out sample);
                    if (sample != null) {
                        this.taglist = new_taglist;
                    } else {
                        this.taglist = new_taglist;
                    }
                    urivideo = (NikiApp.settings.get_string ("title-playing") + NikiApp.settings.get_string ("artist-music"));
                }
            });
            audio_banner ();
        }

        public void size_alocate () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                int height;
                ((Gtk.Window) playerpage.get_toplevel ()).get_size (null, out height);
                var n_width = playerpage.small_cover.width = 60 + ((height / 8) / 2);
                var n_height = playerpage.small_cover.height = 60 + ((height / 8) / 2);
                set_size ((int)n_width, (int)n_height);
                invalidate ();
            }
        }

        private void audio_banner () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                Idle.add (()=> {
                    if (NikiApp.settings.get_enum ("player-mode") == PlayerMode.AUDIO) {
                        if (file_exists (NikiApp.settings.get_string ("uri-video"))) {
                            if (taglist != null) {
                                background = align_and_scale_pixbuf (pix_from_tag (taglist), 200);
                            }
                            size_alocate ();
                            playerpage.small_cover.content = this;
                        }
                    }
                    return false;
                });
            }
        }

        public override bool draw (Cairo.Context cr, int cr_width, int cr_height) {
            var scale = get_scale_factor ();
            var width = (int) (cr_width * scale).abs ();
            var height = (int) (cr_height * scale).abs ();
            if (background == null) {
                return true;
            }
            Clutter.cairo_clear (cr);
            double full_ratio = (double)background.height / (double)background.width;
            Gdk.Pixbuf scaled_pixbuf = null;
            if ((width * full_ratio) < height) {
                scaled_pixbuf = background.scale_simple ((int)(height * full_ratio), height, Gdk.InterpType.BILINEAR);
            } else {
                scaled_pixbuf = background.scale_simple (width, (int)(width * full_ratio), Gdk.InterpType.BILINEAR);
            }

            int y = ((height - scaled_pixbuf.height) / 2).abs ();
            int x = ((width - scaled_pixbuf.width) / 2).abs ();

            Gdk.Pixbuf new_pixbuf = new Gdk.Pixbuf (background.colorspace, background.has_alpha, background.bits_per_sample, width, height);
            scaled_pixbuf.copy_area (x, y, width, height, new_pixbuf, 0, 0);

            Gdk.cairo_set_source_pixbuf (cr, circle_pix (new_pixbuf), 0, 0);
            cr.paint ();
            return true;
        }
    }
}
