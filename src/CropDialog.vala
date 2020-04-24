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
    public class CropDialog : MessageDialog {
        public signal void request_avatar_change (Gdk.Pixbuf pixbuf);
        public string pixbuf_path { get; construct; }
        private CropView? cropview;

        public CropDialog (string pixbuf_path, Gtk.Window window) {
            Object (
                text_image: "image-crop",
                primary_text: StringPot.Crop_Position,
                secondary_text: StringPot.Choose_Part,
                pixbuf_path: pixbuf_path,
                selectable_text: false,
                deletable: false,
                resizable: false,
                transient_for: window,
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
        }

        construct {
            add_button (StringPot.Close, Gtk.ResponseType.CLOSE);

            var button_change = add_button (StringPot.Set_Cover, Gtk.ResponseType.OK);
            button_change.has_default = true;
            button_change.margin_end = 5;
            button_change.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            response.connect (on_response);

            try {
                cropview = new CropView.from_pixbuf_with_size (new Gdk.Pixbuf.from_file (pixbuf_path), 450, 350);
                cropview.quadratic_selection = true;
                cropview.handles_visible = false;

                var frame = new Gtk.Grid ();
                frame.get_style_context ().add_class ("card");
                frame.get_style_context ().add_class ("checkerboard");
                frame.valign = Gtk.Align.CENTER;
                frame.halign = Gtk.Align.CENTER;
                frame.add (cropview);
                custom_bin.add (frame);
                custom_bin.show_all ();
            } catch (Error e) {
                critical (e.message);
                button_change.set_sensitive (false);
            }
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            if (response_id == Gtk.ResponseType.OK) {
                var pixbuf = cropview.get_selection ();
                if (pixbuf.get_width () > 200) {
                    request_avatar_change (pixbuf.scale_simple (1024, 1024, Gdk.InterpType.BILINEAR));
                } else {
                    request_avatar_change (pixbuf);
                }
            }
            destroy ();
        }
    }
}
