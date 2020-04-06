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
    public class DownloadDialog : Gtk.Dialog {
        private Gtk.ProgressBar progress_bar;
        private Gtk.Label bottom_label;
        private bool loop_run = false;
	    private Cancellable cancellable;

        public DownloadDialog (string primary_text, string secondary_text, int mode_type) {
            Object (
                deletable: false,
                skip_taskbar_hint: true,
                transient_for: NikiApp.window,
                destroy_with_parent: true,
                type_hint: Gdk.WindowTypeHint.DIALOG,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
            set_size_request (600, 30);
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");
            var top_label = new Gtk.Label (null);
            top_label.ellipsize = Pango.EllipsizeMode.END;
            top_label.max_width_chars = 55;
            top_label.xalign = 0;

            progress_bar = new Gtk.ProgressBar ();
            progress_bar.hexpand = true;

            var image = new Gtk.Image ();
            image.valign = Gtk.Align.START;
            image.set_from_gicon (new ThemedIcon ("drive-harddisk"), Gtk.IconSize.DIALOG);
            bottom_label = new Gtk.Label (null);
            bottom_label.ellipsize = Pango.EllipsizeMode.START;
            bottom_label.xalign = 0;
            var stop_button = new Gtk.Button.from_icon_name ("process-stop-symbolic");
            stop_button.get_style_context ().add_class ("transparantbg");
            stop_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            var start_holder = new Gtk.Grid ();
            start_holder.orientation = Gtk.Orientation.VERTICAL;
            start_holder.margin = start_holder.margin_start = start_holder.margin_end = 6;
            start_holder.add (top_label);
            start_holder.add (progress_bar);
            start_holder.add (bottom_label);
            var holder = new Gtk.Grid ();
            holder.margin = holder.margin_start = holder.margin_end = 6;
            holder.orientation = Gtk.Orientation.HORIZONTAL;
            holder.add (image);
            holder.add (start_holder);
            holder.add (stop_button);
            holder.show_all ();

            var content = get_content_area () as Gtk.Box;
            content.margin = 6;
            content.margin_top = 0;
            content.add (holder);
            string file_save = null;
            switch (mode_type) {
                case 0 :
                    file_save = GLib.Environment.get_user_special_dir (UserDirectory.VIDEOS);
                    break;
                case 2 :
                    file_save = GLib.Environment.get_user_special_dir (UserDirectory.MUSIC);
                    break;
                case 4 :
                    file_save = GLib.Environment.get_user_special_dir (UserDirectory.PICTURES);
                    break;
            }
            top_label.label = "Save... " + secondary_text + " to " + file_save;
            string without_ext = primary_text.substring (primary_text.last_index_of ("."));
            string file_out = file_save + "/" + secondary_text + without_ext;
            show.connect (() => {
                download_dlna (primary_text, file_out);
            });
            stop_button.clicked.connect (() => {
				cancellable.cancel ();
                if (loop_run) {
	                try {
		                File file = File.new_for_uri ("file://" + file_out);
		                file.delete ();
	                } catch (Error e) {
		                print ("Error: %s\n", e.message);
	                }
		        }
		        destroy ();
            });
            move_widget (this, this);
        }
        public void download_dlna (string uri, string uriout) {
            var file_path = File.new_for_path (uriout);
            var file_from_uri = File.new_for_uri (uri);
            cancellable = new Cancellable ();
            double progress = 0.0;
            progress_bar.set_fraction (0);

            file_from_uri.copy_async.begin (file_path, FileCopyFlags.BACKUP | FileCopyFlags.ALL_METADATA, GLib.Priority.DEFAULT, cancellable, (current_num_bytes, total_num_bytes) => {
                loop_run = true;
                progress = (double) current_num_bytes / total_num_bytes;
                progress_bar.set_fraction (progress);
                bottom_label.label = int64_to_size (current_num_bytes, false) + " / " + int64_to_size (total_num_bytes, false);
	        }, (obj, res) => {
	            loop_run = false;
		        try {
			        file_from_uri.copy_async.end (res);
		        } catch (Error e) {
			        print ("%s\n", e.message);
		        }
		        destroy ();
		    });
        }
    }
}
