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
    public class DownloadDialog : Gtk.Dialog {
        private Gtk.ProgressBar progress_bar;
        private Gtk.Label bottom_label;
        private Cancellable cancellable;
        private bool loop_run = false;
        private int start_time = 0;

        public DownloadDialog (Gtk.Widget widget, string primary_text, string secondary_text, int mode_type) {
            Object (
                deletable: false,
                skip_taskbar_hint: true,
                transient_for: (Gtk.Window) widget.get_toplevel (),
                destroy_with_parent: true,
                use_header_bar: 1,
                type_hint: Gdk.WindowTypeHint.DIALOG,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );
            set_size_request (600, 30);
            get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_style_context ().add_class ("niki");

            var header_label = new Gtk.Label (_("Downloading…")) {
                halign = Gtk.Align.CENTER,
                hexpand = true
            };
            header_label.get_style_context ().add_class ("h4");
            get_header_bar ().set_custom_title (header_label);

            var top_label = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                max_width_chars = 45,
                xalign = 0
            };

            progress_bar = new Gtk.ProgressBar () {
                hexpand = true
            };

            var image = new Gtk.Image () {
                halign = Gtk.Align.END,
                valign = Gtk.Align.END
            };
            image.set_from_gicon (new ThemedIcon ("go-down"), Gtk.IconSize.DIALOG);

            var device_image = new Gtk.Image () {
                halign = Gtk.Align.END,
                valign = Gtk.Align.END
            };
            device_image.set_from_gicon (new ThemedIcon ("computer"), Gtk.IconSize.BUTTON);

            var overlay = new Gtk.Overlay ();
            overlay.add (image);
            overlay.add_overlay (device_image);

            bottom_label = new Gtk.Label (null) {
                ellipsize = Pango.EllipsizeMode.END,
                xalign = 0
            };

            var stop_button = new Gtk.Button.from_icon_name ("process-stop-symbolic");
            stop_button.get_style_context ().add_class ("transparantbg");
            stop_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var start_holder = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL,
                margin_start = 6,
                margin_end = 6
            };
            start_holder.add (top_label);
            start_holder.add (progress_bar);
            start_holder.add (bottom_label);

            var holder = new Gtk.Grid () {
                orientation = Gtk.Orientation.HORIZONTAL,
                margin_start = 6,
                margin_end = 6
            };
            holder.add (overlay);
            holder.add (start_holder);
            holder.add (stop_button);

            var content = get_content_area () as Gtk.Box;
            content.margin = 6;
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

            top_label.label = _("File: %s to %s").printf (secondary_text, file_save);
            string without_ext = primary_text.substring (primary_text.last_index_of ("."));
            string file_out = @"$(file_save)/$(secondary_text)$(without_ext)";

            show.connect (() => {
                download_dlna (primary_text, file_out);
            });

            stop_button.clicked.connect (() => {
                cancellable.cancel ();
                if (loop_run) {
                    permanent_delete (File.new_for_path (file_out));
                }
                destroy ();
            });
            move_widget (this);
        }

        public void download_dlna (string uri, string uriout) {
            var file_path = File.new_for_path (uriout);
            var file_from_uri = File.new_for_uri (uri);
            cancellable = new Cancellable ();
            progress_bar.set_fraction (0.0);
            file_from_uri.copy_async.begin (file_path, FileCopyFlags.BACKUP | FileCopyFlags.ALL_METADATA, GLib.Priority.DEFAULT, cancellable, (transferred, total_size) => {
                loop_run = true;
                if (progress_bar.fraction == 0.0) {
                    start_time = (int) get_real_time ();
                }
                on_transfer_progress (transferred, total_size);
            }, (obj, res) => {
                loop_run = false;
                try {
                    file_from_uri.copy_async.end (res);
                } catch (Error e) {
                    notify_app (_("Niki DLNA Browser"), e.message);
                }
                destroy ();
            });
        }

        private void on_transfer_progress (uint64 transferred, uint64 total_size) {
            bottom_label.label = _("%s received %s").printf (GLib.format_size (total_size), GLib.format_size (transferred));
            progress_bar.fraction = (double) transferred / (double) total_size;
            int current_time = (int) get_real_time ();
            int elapsed_time = (current_time - start_time) / 1000000;
            if (current_time < start_time + 1000000) {
                return;
            }
            if (elapsed_time == 0) {
                return;
            }

            uint64 transfer_rate = transferred / elapsed_time;
            if (transfer_rate == 0) {
                return;
            }
            uint64 remaining_time = (total_size - transferred) / transfer_rate;
            string time = format_time ((int)remaining_time);
            bottom_label.label = _("%s received %s speed %s remaining %s").printf (GLib.format_size (total_size), GLib.format_size (transferred), GLib.format_size (transfer_rate), time);
        }

        private string format_time (int seconds) {
            if (seconds < 0) {
                seconds = 0;
            }

            if (seconds < 60) {
                return ngettext ("%'d second", "%'d seconds", seconds).printf (seconds);
            }

            int minutes;
            if (seconds < 60 * 60) {
                minutes = (seconds + 30) / 60;
                return ngettext ("%'d minute", "%'d minutes", minutes).printf (minutes);
            }

            int hours = seconds / (60 * 60);
            if (seconds < 60 * 60 * 4) {
                minutes = (seconds - hours * 60 * 60 + 30) / 60;
                string h = ngettext ("%'u hour", "%'u hours", hours).printf (hours);
                string m = ngettext ("%'u minute", "%'u minutes", minutes).printf (minutes);
                return h.concat (", ", m);
            }

            return ngettext ("approximately %'d hour", "approximately %'d hours", hours).printf (hours);
        }
    }
}
