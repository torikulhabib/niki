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
    public class CropDialog : MessageDialog {
        public signal void request_avatar_change (Gdk.Pixbuf pixbuf);
        public string pixbuf_path { get; construct; }
        private CropView? cropview;

        public CropDialog (string pixbuf_path, Gtk.Widget widget) {
            Object (
                text_image: "image-crop",
                header: _("Image Crop"),
                primary_text: _("Crop Position"),
                secondary_text: _("Choose the part of the image to use as a cover."),
                pixbuf_path: pixbuf_path,
                selectable_text: false,
                deletable: false,
                resizable: false,
                use_header_bar: 1,
                transient_for: (Gtk.Window) widget.get_toplevel (),
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
        }

        construct {
            try {
                cropview = new CropView.from_pixbuf_with_size (new Gdk.Pixbuf.from_file (pixbuf_path), 450, 350) {
                    quadratic_selection = true,
                    handles_visible = false
                };

                var frame = new Gtk.Grid () {
                    valign = Gtk.Align.CENTER,
                    halign = Gtk.Align.CENTER
                };
                frame.get_style_context ().add_class ("card");
                frame.get_style_context ().add_class ("checkerboard");
                frame.add (cropview);
                custom_bin.add (frame);

                var applyset = new Gtk.Button.with_label (_("Apply"));
                applyset.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
                applyset.clicked.connect (() => {
                    var pixbuf = cropview.get_selection ();
                    if (pixbuf.get_width () > 200) {
                        request_avatar_change (pixbuf.scale_simple (1024, 1024, Gdk.InterpType.BILINEAR));
                    } else {
                        request_avatar_change (pixbuf);
                    }
                    destroy ();
                });

                var close_dialog = new Gtk.Button.with_label (_("Close"));
                close_dialog.clicked.connect (() => {
                    destroy ();
                });

                var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                    margin_top = 5,
                    spacing = 5,
                    margin_start = 10,
                    margin_bottom = 10,
                    margin_end = 10,
                    homogeneous = true
                };
                box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
                box_action.pack_end (applyset, false, true, 0);
                box_action.pack_end (close_dialog, false, true, 0);
                get_content_area ().add (box_action);

            } catch (Error e) {
                critical (e.message);
            }
        }
    }
}
