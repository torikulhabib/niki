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
    public class Contractor {
        public static string cont_dir () {
            string build_path = Path.build_filename (Environment.get_home_dir (), ".local", "share", "contractor");
            if (!File.new_for_path(build_path).query_exists ()) {
                DirUtils.create (build_path, 0700);
            }
            return build_path;
        }
        private static File file_contr () {
            return File.new_for_path (Path.build_filename (cont_dir (), Environment.get_application_name () + ".contract"));
        }
        public static void create_contract () {
            try {
                File file = file_contr ();
                remove_contract ();
        		FileOutputStream os = file.create (FileCreateFlags.PRIVATE);
                string str_name=@"Name=$(StringPot.Add_Niki_Playlist)\n";
                string str_desc=@"Description=$(StringPot.Add_Niki_Playlist)\n";
                string str_command ="Exec=com.github.torikulhabib.niki --playlist %U \n";
        		os.write ("[Contractor Entry]\n".data);
                os.write (str_name.data);
                os.write (str_desc.data);
                os.write (@"$(niki_mime_type ())\n".data);
                os.write (str_command.data);
        	} catch (Error e) {
        		warning ("Error: %s\n", e.message);
        	}
        }

        public static void remove_contract () {
            try {
                File file = file_contr ();
                if (file.query_exists ()) {
                    file.delete ();
                }
            } catch (Error e) {
        		warning ("Error: %s\n", e.message);
        	}
        }
    }
}
