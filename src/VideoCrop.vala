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
    public class VideoCrop : MessageDialog {
        private PlayerPage? playerpage;

        public VideoCrop (PlayerPage playerpage) {
            Object (
                text_image: "image-crop",
                header: _("Video Crop"),
                primary_text: _("Crop Position"),
                secondary_text: _("Choose the side of the video to crop."),
                selectable_text: false,
                deletable: false,
                resizable: false,
                use_header_bar: 1,
                border_width: 0,
                transient_for: (Gtk.Window) playerpage.get_toplevel (),
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
            this.playerpage = playerpage;
            var top_label = new LabelSpin (_("Top"), playerpage.video_height / 2);
            top_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            var bottom_label = new LabelSpin (_("Bottom"), playerpage.video_height / 2);
            bottom_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            var left_label = new LabelSpin (_("Left"), playerpage.video_width / 2);
            left_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            var right_label = new LabelSpin (_("Right"), playerpage.video_width / 2);
            right_label.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var frame = new Gtk.Grid ();
            frame.orientation = Gtk.Orientation.VERTICAL;
            frame.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            frame.valign = Gtk.Align.CENTER;
            frame.halign = Gtk.Align.CENTER;
            frame.row_spacing = 5;
            frame.add (top_label);
            frame.add (bottom_label);
            frame.add (left_label);
            frame.add (right_label);
            custom_bin.add (frame);
            custom_bin.set_size_request (300, 150);
            int top_value, bottom_value, left_value, right_value;
            playerpage.playback.videomix.videocrop.get ("top", out top_value, "bottom", out bottom_value, "left", out left_value, "right", out right_value);
            top_label.number_entry.value = top_value;
            bottom_label.number_entry.value = bottom_value;
            left_label.number_entry.value = left_value;
            right_label.number_entry.value = right_value;
            var applyset = new Gtk.Button.with_label (_("Apply"));
            applyset.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            applyset.clicked.connect (() => {
                top_value = (int) top_label.number_entry.get_value ();
                bottom_value = (int) bottom_label.number_entry.get_value ();
                left_value = (int) left_label.number_entry.get_value ();
                right_value = (int) right_label.number_entry.get_value ();
                playerpage.playback.videomix.set_videocrp (top_value, bottom_value, left_value, right_value);
            });
            var close_dialog = new Gtk.Button.with_label (_("Close"));
            close_dialog.clicked.connect (() => {
		        destroy ();
            });

		    var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.margin_top = box_action.spacing = 5;
            box_action.margin_start = box_action.margin_bottom = box_action.margin_end = 10;
            box_action.homogeneous = true;
            box_action.pack_end (applyset, false, true, 0);
            box_action.pack_end (close_dialog, false, true, 0);
            get_content_area ().add (box_action);
        }

    }
}
