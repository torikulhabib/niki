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
    public class ImageCanvas : Clutter.Canvas {
        private PlayerPage playerpage;
        private Gdk.Pixbuf background;
        private uint last_size_hash = 0;
        private BufferSurface surface;
        private Gst.TagList taglist;
        private string urivideo;

        public ImageCanvas (PlayerPage playerpage) {
            this.playerpage = playerpage;
            playerpage.size_allocate.connect (size_alocate);
            playerpage.playback.idle.connect (audio_banner);
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
            NikiApp.settings.changed["blur-mode"].connect (audio_banner);
            audio_banner ();
        }

        public void size_alocate () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                int width, height;
                ((Gtk.Window) playerpage.get_toplevel ()).get_size (out width, out height);
                var new_hash = GLib.int_hash (width) + GLib.int_hash (height);
                if (new_hash != last_size_hash) {
                    last_size_hash = new_hash;
                    set_size (width, height);
                    invalidate ();
                }
            }
        }

        private void audio_banner () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                Idle.add (()=> {
                    if (NikiApp.settings.get_enum ("player-mode") == PlayerMode.AUDIO) {
                        playerpage.set_size_request (400, 400);
                        if (taglist == null) {
                            return false;
                        }
                        Gdk.Pixbuf pix_art = align_and_scale_pixbuf (pix_from_tag (taglist), 1124);
                        if (pix_art == null) {
                            return false;    
                        }
                        if (NikiApp.settings.get_boolean ("blur-mode")) {
                            surface = new BufferSurface (pix_art.width, pix_art.height);
                            Gdk.cairo_set_source_pixbuf (surface.context, pix_art, 0, 0);
                            surface.context.paint ();
                            surface.exponential_blur (10);
                            surface.context.paint ();
                            background = Gdk.pixbuf_get_from_surface (surface.surface, 0, 0, pix_art.width, pix_art.height);
                        } else {
                            background = pix_art;
                        }
                        int width, height;
                        ((Gtk.Window) playerpage.get_toplevel ()).get_size (out width, out height);
                        set_size (width, height);
                        invalidate ();
                        playerpage.stage.content = this;
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

            Gdk.cairo_set_source_pixbuf (cr, new_pixbuf, 0, 0);
            cr.paint ();
            cr.restore ();
            return true;
        }
    }
}
