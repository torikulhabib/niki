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
    public class MessageDialog : Gtk.Dialog {
        private class SingleWidgetBin : Gtk.Bin {}
        public Gtk.Bin custom_bin { get; construct; }
        public string primary_text { get; construct; }
        public string secondary_text { get; construct; }
        public string third_text { get; construct; }
        public string text_image { get; construct; }
        public string header { get; construct; }
        public bool selectable_text { get; construct; }

        public MessageDialog.with_image_from_icon_name (string header, string primary_text, string secondary_text, string third_text, string image_icon_name = "dialog-information", bool selectable_text = true) {
            Object (
                header: header,
                primary_text: primary_text,
                secondary_text: secondary_text,
                third_text: third_text,
                text_image: image_icon_name,
                selectable_text: selectable_text,
                resizable: false,
                deletable: false,
                skip_taskbar_hint: true,
                destroy_with_parent: true
            );
        }

        construct {
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            var image = new Gtk.Image () {
                valign = Gtk.Align.START,
                can_focus = true
            };
            image.set_from_gicon (new ThemedIcon (text_image), Gtk.IconSize.DIALOG);

            var header_label = new Gtk.Label (header) {
                ellipsize = Pango.EllipsizeMode.END
            };
            header_label.get_style_context ().add_class ("h4");
            var header_bar = get_header_bar ();
            header_bar.has_subtitle = false;
            header_bar.set_custom_title (header_label);

            var primary_label = new Gtk.Label (primary_text) {
                max_width_chars = 50,
                wrap = true,
                xalign = 0
            };
            primary_label.get_style_context ().add_class ("primary");
            primary_label.show_all ();

            var secondary_label = new Gtk.Label (secondary_text) {
                max_width_chars = 50,
                wrap = true,
                xalign = 0
            };

            var third_label = new Gtk.Label (third_text) {
                ellipsize = Pango.EllipsizeMode.START,
                max_width_chars = 50,
                xalign = 0
            };
            third_label.set_selectable (selectable_text);

            custom_bin = new SingleWidgetBin () {
                margin_start = 10,
                margin_end = 10,
                margin_bottom = 10
            };
            custom_bin.add.connect (() => {
                third_label.margin_bottom = 10;
            });

            custom_bin.remove.connect (() => {
                third_label.margin_bottom = 5;
            });
            var message_grid = new Gtk.Grid () {
                column_spacing = 5,
                row_spacing = 0,
                margin_start = 6,
                margin_end = 6
            };
            message_grid.attach (image, 0, 0, 1, 3);
            message_grid.attach (primary_label, 1, 0, 1, 1);
            message_grid.attach (secondary_label, 1, 1, 1, 1);
            if (third_label.label != "") {
                message_grid.attach (third_label, 1, 2, 1, 1);
            } else {
                message_grid.margin_bottom = 10;
            }
            message_grid.show_all ();

            var grid_combine = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                valign = Gtk.Align.CENTER
            };
            grid_combine.add (message_grid);
            grid_combine.add (custom_bin);
            grid_combine.show_all ();

            var action_area = get_content_area ();
            action_area.margin = 3;
            action_area.margin_top = 3;
            action_area.add (grid_combine);
            move_widget (this);
        }
    }
}
