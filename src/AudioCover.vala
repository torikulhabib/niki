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
    public class AudioCover : Object {
        public Gdk.Pixbuf? pixbuf_playlist;
        public Gdk.Pixbuf? pixbuf_albumart;
        public Gdk.Pixbuf? pixbuf_background;
        public Gdk.Pixbuf? pixbuf_blur;

        public void import (string path) {
            if (!File.new_for_uri (path).query_exists ()) {
                return;
            }
            try {
                Gst.PbUtils.Discoverer discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
                var info = discoverer.discover_uri (path);
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
                            apply_cover_pixbuf (pixbuf_sample, path);
                            create_background (pixbuf_sample);
                        }
                    }
                }  else {
                    pixbuf_sample = unknown_cover ();
                    if (pixbuf_sample != null) {
                        apply_cover_pixbuf (pixbuf_sample, path);
                        create_background (pixbuf_sample);
                    }
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

        private void apply_cover_pixbuf (Gdk.Pixbuf save_pixbuf, string path) {
            string album_path = cache_image (get_song_info (File.new_for_uri (path)) + " " + get_artist_music (path));
            if (!FileUtils.test (album_path, FileTest.EXISTS)) {
                pixbuf_playlist = align_and_scale_pixbuf (save_pixbuf, 48);
                pix_to_file (pixbuf_playlist, album_path);
            }
        }
        public void create_background (Gdk.Pixbuf in_pixbuf) {
            pixbuf_albumart = align_and_scale_pixbuf (in_pixbuf, 256);
            pixbuf_background = align_and_scale_pixbuf (in_pixbuf, 768);
            var surface = new Granite.Drawing.BufferSurface ((int)768, (int)768);
            Gdk.cairo_set_source_pixbuf (surface.context, pixbuf_background, 0, 0);
            surface.context.paint ();
            surface.exponential_blur (15);
            surface.context.paint ();
            pixbuf_blur = Gdk.pixbuf_get_from_surface (surface.surface, 0, 0, 768, 768);
        }
    }
}
