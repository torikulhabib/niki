/*
* Copyright (c) {2018} torikulhabib (https://github.com/torikulhabib/)
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
    public class GetLink : Object {
		public signal void errormsg (string msg);
		public signal void process_all (string [] msg);

        private bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
            if (condition == IOCondition.HUP) {
                return false;
            }
            try {
                string line;
                channel.read_line (out line, null, null);
                switch (stream_name) {
                	case "stdout":
                		sendata (line);
                		break;
                	case "stderr":
                		errormsg (line);
                		break;
                }
            } catch (IOChannelError e) {
                warning ("%s %s\n", stream_name, e.message);
                return false;
            } catch (ConvertError e) {
                warning ("%s %s\n", stream_name, e.message);
                return false;
            }
            return true;
        }

	    public void get_link_stream (string url) {
            string [] spawn_args;
            if (url.contains ("youtu")) {
                if (url.contains ("&" + "list")) {
		            spawn_args = {"youtube-dl", "--get-thumbnail", "--write-thumbnail", "--get-filename", "-f", "18", "-o", "%(title)s.%(ext)s", "--skip-download", "--playlist-items", "1-5", "--get-url", url};
                } else if (url.contains ("?" + "list")) {
		            spawn_args = {"youtube-dl", "--get-thumbnail", "--get-filename", "-f", "18", "-o", "%(title)s.%(ext)s", "--skip-download", "--playlist-items", "1-5", "--get-url", url};
                } else {
                    spawn_args = {"youtube-dl", "--get-thumbnail", "--get-filename", "-f", "18", "-o", "%(title)s.%(ext)s", "--skip-download", "--get-url", url};
                }
            } else {
                spawn_args = {"youtube-dl", "--get-thumbnail", "--get-filename", "-o", "%(title)s.%(ext)s", "--skip-download", "--get-url", url};
            }
            try {
                int standard_input, standard_output, standard_error;
                Process.spawn_async_with_pipes ( cache_folder (), spawn_args, Environ.get (), SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null, null, out standard_input, out standard_output, out standard_error);
                IOChannel output = new IOChannel.unix_new (standard_output);
                output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stdout");
                });
                IOChannel error = new IOChannel.unix_new (standard_error);
                error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stderr");
                });
            } catch (SpawnError e) {
                warning ("Error: %s\n", e.message);
            }
        }
        private string[] string_list = {};
        private void sendata (string datain) {
	        string[] datains = datain.split ("\n");
            string_list += datains [0];
            if (string_list.length > 2) {
                process_all (string_list);
                string_list = {};
                datains = {};
            }
        }
    }
}
