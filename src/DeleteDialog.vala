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
    public class DeleteDialog : MessageDialog {
        public signal void permanents ();
        public signal void trash ();

        public DeleteDialog (Gtk.Widget widget, string file_name) {
            Object (
                text_image: "user-trash",
                header: _("Delete File"),
                primary_text: _("Do you really want to remove this from device?"),
                secondary_text: _("This will remove the file from your playlist and from any device."),
                third_text: File.new_for_uri (file_name).get_path (),
                selectable_text: false,
                deletable: false,
                resizable: false,
                use_header_bar: 1,
                border_width: 0,
                transient_for: (Gtk.Window) widget.get_toplevel (),
                destroy_with_parent: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );

            var delete_permanent = new Gtk.Button.with_label (_("Delete Permanent"));
            delete_permanent.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            delete_permanent.clicked.connect (() => {
		        permanent_delete (File.new_for_uri (file_name));
                permanents ();
		        destroy ();
            });
            var move_trash = new Gtk.Button.with_label (_("Move Trash"));
            move_trash.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            move_trash.clicked.connect (() => {
		        delete_trash (File.new_for_uri (file_name));
                trash ();
		        destroy ();
            });
            var close_dialog = new Gtk.Button.with_label (_("Close"));
            close_dialog.clicked.connect (() => {
		        destroy ();
            });

		    var box_action = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box_action.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            box_action.spacing = 5;
            box_action.margin_top = 5;
            box_action.margin_start = 10;
            box_action.margin_end = 10;
            box_action.margin_bottom = 10;
            box_action.pack_start (delete_permanent, true, true, 0);
            box_action.pack_start (move_trash, true, true, 0);
            box_action.pack_end (close_dialog, true, true, 0);
            get_content_area ().add (box_action);
        }

    }
}
