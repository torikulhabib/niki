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
    public class VideoPreview : GLib.Object {
        private File video_file;
        private string mime_type;
        private string preview_path;
        private string preview_large_path;

        public VideoPreview (string directory, string file, string mime_type) {
            this.mime_type = mime_type;
            video_file = File.new_for_path (directory);
            string hash_file_poster = GLib.Checksum.compute_for_string (ChecksumType.MD5, file, file.length);
            preview_path = Path.build_filename (GLib.Environment.get_user_cache_dir (), "thumbnails", "normal", hash_file_poster + ".png");
            preview_large_path = Path.build_filename (GLib.Environment.get_user_cache_dir (),"thumbnails", "large", hash_file_poster + ".png");
        }

        public string set_preview () {
            return preview_path;
        }
        public string set_preview_large () {
            return preview_large_path;
        }

        public void run_preview () {
            if (!FileUtils.test (preview_path, FileTest.EXISTS) || !FileUtils.test (preview_large_path, FileTest.EXISTS)) {
                Gee.ArrayList<string> uris = new Gee.ArrayList<string> ();
                Gee.ArrayList<string> mimes = new Gee.ArrayList<string> ();
                uris.add (video_file.get_uri ());
                mimes.add (mime_type);
                var thumbler = new DbusThumbnailer ();
                thumbler.Instand (uris, mimes, "normal");
                thumbler.Instand (uris, mimes, "large");
            }
        }
    }
}
