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
                primary_text: StringPot.Video_Crop,
                secondary_text: StringPot.Choose_Crop,
                selectable_text: false,
                deletable: false,
                resizable: false,
                border_width: 0,
                transient_for: NikiApp.window,
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
            this.playerpage = playerpage;
            var top_label = new LabelEntry (StringPot.Top, playerpage.video_height / 2);
            var bottom_label = new LabelEntry (StringPot.Bottom, playerpage.video_height / 2);
            var left_label = new LabelEntry (StringPot.Left, playerpage.video_width / 2);
            var right_label = new LabelEntry (StringPot.Right, playerpage.video_width / 2);

            var frame = new Gtk.Grid ();
            frame.orientation = Gtk.Orientation.VERTICAL;
            frame.valign = Gtk.Align.CENTER;
            frame.halign = Gtk.Align.CENTER;
            frame.row_spacing = 5;
            frame.add (top_label);
            frame.add (bottom_label);
            frame.add (left_label);
            frame.add (right_label);
            custom_bin.add (frame);
            custom_bin.set_size_request (300, 150);
            show_all ();
            add_button (StringPot.Close, Gtk.ResponseType.CLOSE);
            var button_change = add_button (StringPot.Set_Crop, Gtk.ResponseType.OK);
            button_change.has_default = true;
            button_change.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            response.connect ((source, response_id)=>{
                if (response_id == Gtk.ResponseType.OK) {
                    int top_value = (int) top_label.number_entry.get_value ();
                    int bottom_value = (int) bottom_label.number_entry.get_value ();
                    int left_value = (int) left_label.number_entry.get_value ();
                    int right_value = (int) right_label.number_entry.get_value ();
                    NikiApp.window.player_page.playback.videomix.set_videocrp (top_value, bottom_value, left_value, right_value);
                } else if (response_id == Gtk.ResponseType.CLOSE) {
                    destroy ();
                }
            });
        }

    }
}
