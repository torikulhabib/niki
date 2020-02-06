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
        public static string get_contract_dir () {
            return Path.build_filename (Environment.get_home_dir (), ".local", "share", "contractor");
        }

        public static string create_if_not_exists_contract_dir () {
            if (!File.new_for_path(Contractor.get_contract_dir ()).query_exists ()) {
                DirUtils.create (Contractor.get_contract_dir (), 0700);
            }
            return Contractor.get_contract_dir ();
        }

        public static void create_contract () {
            try {
                var contract_file = Path.build_filename (Contractor.create_if_not_exists_contract_dir (), Environment.get_application_name () + ".contract");

                File file = File.new_for_path (contract_file);
                if (file.query_exists () == true) {
                    file.delete ();
                }


        		FileOutputStream os = file.create (FileCreateFlags.PRIVATE);
                string str_name="Name=%s \n".printf (StringPot.Add_Niki_Playlist);
                string str_desc="Description=%s \n".printf (StringPot.Add_Niki_Playlist);
                string str_command  ="Exec=com.github.torikulhabib.niki --playlist %U \n";
        		os.write ("[Contractor Entry]\n".data);
                os.write (str_name.data);
                os.write (str_desc.data);
                os.write ("MimeType=audio/aac;audio/aiff;audio/x-aiff;audio/m4a;audio/x-m4a;audio/mp1;audio/x-mp1;audio/mp2;audio/x-mp2;audio/mp3;audio/x-mp3;audio/mpeg;audio/mpeg2;audio/mpeg3;audio/mpegurl;audio/x-mpegurl;audio/mpg;audio/x-mpg;audio/rn-mpeg;audio/musepack;audio/x-musepack;audio/ogg;audio/scpls;audio/x-scpls;audio/vnd.rn-realaudio;audio/wav;audio/x-pn-wav;audio/x-pn-windows-pcm;audio/x-realaudio;audio/x-pn-realaudio;audio/x-ms-wma;audio/x-pls;audio/x-wav;video/mpeg;video/x-mpeg2;video/x-mpeg3;video/mp4v-es;video/x-m4v;video/mp4;video/divx;video/vnd.divx;video/msvideo;video/x-msvideo;video/ogg;video/quicktime;video/vnd.rn-realvideo;video/x-ms-afs;video/x-ms-asf;audio/x-ms-asf;video/x-ms-wmv;video/x-ms-wmx;video/x-ms-wvxvideo;video/x-avi;video/avi;video/x-flic;video/fli;video/x-flc;video/flv;video/x-flv;video/x-theora;video/x-theora+ogg;video/x-matroska;video/mkv;audio/x-matroska;video/webm;audio/webm;audio/vorbis;audio/x-vorbis;audio/x-vorbis+ogg;video/x-ogm;video/x-ogm+ogg;audio/x-shorten;audio/x-ape;audio/x-wavpack;audio/x-tta;audio/AMR;audio/ac3;audio/eac3;audio/amr-wb;video/mp2t;audio/flac;audio/mp4;video/vnd.mpegurl;audio/x-pn-au;video/3gp;video/3gpp;video/3gpp2;audio/3gpp;audio/3gpp2;video/dv;audio/dv;audio/opus;audio/vnd.dts;audio/vnd.dts.hd;audio/x-adpcm;audio/m3u;application/vnd.smaf;\n".data);
                os.write (str_command.data);
        	} catch (Error e) {
        		warning ("Error: %s\n", e.message);
        	}
        }

        public static void remove_contract () {
            try {
                var contract_file = Path.build_filename (Contractor.create_if_not_exists_contract_dir (), Environment.get_application_name () + ".contract");
                File file = File.new_for_path (contract_file);
                if (file.query_exists ()) {
                    file.delete ();
                }
            } catch (Error e) {
        		warning ("Error: %s\n", e.message);
        	}
        }
    }
}
