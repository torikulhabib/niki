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
    public class MessageDialog : Gtk.Dialog {
        private class SingleWidgetBin : Gtk.Bin {}
        public Gtk.Bin custom_bin { get; construct; }
        public string primary_text { get; construct; }
        public string secondary_text { get; construct; }
        public string third_text { get; construct; }
        public string text_image { get; construct; }
        public bool selectable_text { get; construct; }

        public MessageDialog.with_image_from_icon_name (string primary_text, string secondary_text, string third_text, string image_icon_name = "dialog-information", bool selectable_text = true) {
            Object (
                primary_text: primary_text,
                secondary_text: secondary_text,
                third_text: third_text,
                text_image: image_icon_name,
                selectable_text: selectable_text,
                resizable: false,
                deletable: false,
                skip_taskbar_hint: true,
                transient_for: NikiApp.window,
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
        }

        construct {
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            var image = new Gtk.Image ();
            image.valign = Gtk.Align.START;
            image.can_focus = true;
            image.set_from_gicon (new ThemedIcon (text_image), Gtk.IconSize.DIALOG);

            var primary_label = new Gtk.Label (primary_text);
            primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);
            primary_label.max_width_chars = 50;
            primary_label.wrap = true;
            primary_label.xalign = 0;
            primary_label.show_all ();

            var secondary_label = new Gtk.Label (secondary_text);
            secondary_label.max_width_chars = 50;
            secondary_label.wrap = true;
            secondary_label.xalign = 0;

            var third_label = new Gtk.Label (third_text);
            third_label.set_selectable (selectable_text);
            third_label.ellipsize = Pango.EllipsizeMode.START;
            third_label.max_width_chars = 50;
            third_label.xalign = 0;

            custom_bin = new SingleWidgetBin ();
            custom_bin.margin_start = custom_bin.margin_end = custom_bin.margin_bottom = 10;
            custom_bin.add.connect (() => {
                third_label.margin_bottom = 10;
            });

            custom_bin.remove.connect (() => {
                third_label.margin_bottom = 5;
            });
            var message_grid = new Gtk.Grid ();
            message_grid.column_spacing = 5;
            message_grid.row_spacing = 0;
            message_grid.margin_start = message_grid.margin_end = 6;
            message_grid.attach (image, 0, 0, 1, 3);
            message_grid.attach (primary_label, 1, 0, 1, 1);
            message_grid.attach (secondary_label, 1, 1, 1, 1);
            message_grid.attach (third_label, 1, 2, 1, 1);
            message_grid.show_all ();

            var grid_combine = new Gtk.Grid ();
            grid_combine.orientation = Gtk.Orientation.VERTICAL;
            grid_combine.valign = Gtk.Align.CENTER;
            grid_combine.add (message_grid);
            grid_combine.add (custom_bin);
            grid_combine.show_all ();

            var action_area = get_content_area ();
            action_area.margin = 3;
            action_area.margin_top = 3;
            action_area.add (grid_combine);
            move_widget (this, this);
        }
    }
}
