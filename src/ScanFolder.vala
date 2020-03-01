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
    public class ScanFolder : GLib.Object {
        public signal void signal_notify (string output);
        private string [] mimetype_contents = {};
        private uint content_count = 0;
        private uint check_count = 0;
        private bool content_check = false;

        public void scanning (string path, int mode_scan) {
            File directory = File.new_for_path (path);
            try {
                var children = directory.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NONE);
                FileInfo file_info;
                if (check_count != 0) {
                    Source.remove (check_count);
                }
                check_count = GLib.Timeout.add (50, () => {
                    if (mode_scan == 1 && !content_check) {
                        signal_notify (StringPot.Empty_Video);
                    }
                    if (mode_scan == 2 && !content_check) {
                        signal_notify (StringPot.Empty_Audio);
                    }
                    if (mode_scan == 0 && !content_check) {
                        signal_notify (StringPot.Folder_Empty);
                    }
                    content_check = false;
                    check_count = 0;
                    return Source.REMOVE;
                });
                while ((file_info = children.next_file ()) != null) {
                    if (file_info.get_is_hidden ()) {
                        continue;
                    }
                    content_check = true;
                    mimetype_contents += file_info.get_content_type ();
                    if (content_count != 0) {
                        Source.remove (content_count);
                    }
                    content_count = GLib.Timeout.add (50, () => {
                        bool content_video = false;
                        bool content_Audio = false;
                        foreach (string mime_content in mimetype_contents) {
                            if (mime_content.has_prefix ("video/")) {
                                content_video = true;
                            }
                            if (mime_content.has_prefix ("audio/")) {
                                content_Audio = true;
                            }
                        }
                        if (mode_scan == 1 && !content_video) {
                            signal_notify (StringPot.Nothing_Video);
                        }
                        if (mode_scan == 2 && !content_Audio) {
                            signal_notify (StringPot.Nothing_Audio);
                        }
                        if (mode_scan == 0 && !content_Audio && !content_video) {
                            signal_notify (StringPot.Nothing_AV);
                        }
                        if (content_video || content_Audio) {
                            if (window.main_stack.visible_child_name == "welcome") {
                                window.player_page.play_first_in_playlist ();
                            }
                        }
                        mimetype_contents = {};
                        content_count = 0;
                        return Source.REMOVE;
                    });

                    if (file_info.get_is_symlink ()) {
                        string target = file_info.get_symlink_target ();
                        var symlink = File.new_for_path (target);
                        var file_type = symlink.query_file_type (0);
                        if (file_type == FileType.DIRECTORY) {
                            scanning (target, mode_scan);
                        }
                    } else if (file_info.get_file_type () == FileType.DIRECTORY) {
                        if (!directory.get_uri ().has_prefix ("file://")) {
                            Thread.usleep (1000000);
                        }
                        scanning (GLib.Path.build_filename (path, file_info.get_name ()), mode_scan);
                    } else {
                        string mime_type = file_info.get_content_type ();
                        bool video_file = !file_info.get_is_hidden () && mime_type.has_prefix ("video/");
                        bool Audio_file = !file_info.get_is_hidden () && mime_type.has_prefix ("audio/");
                        switch (mode_scan) {
                            case 0:
                                if (video_file) {
                                    var found_path = GLib.File.new_build_filename (path, file_info.get_name ());
                                    add_to_playlist (found_path);
                                }
                                if (Audio_file) {
                                    var found_path = GLib.File.new_build_filename (path, file_info.get_name ());
                                    add_to_playlist (found_path);
                                }
                                break;
                            case 1:
                                if (video_file) {
                                    var found_path = GLib.File.new_build_filename (path, file_info.get_name ());
                                    add_to_playlist (found_path);
                                }
                                break;
                            case 2:
                                if (Audio_file) {
                                    var found_path = GLib.File.new_build_filename (path, file_info.get_name ());
                                    add_to_playlist (found_path);
                                }
                                break;
                        }
                    }
                }
            } catch (Error err) {
                warning (err.message);
            }
        }

        private void add_to_playlist (File found_path) {
            window.player_page.playlist_widget ().add_item (found_path);
        }
    }
}
