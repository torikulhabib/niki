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
    public class EngineNetease : Object {
        public signal void send_data (string title, string artist, string type, string text, string server);
        public signal void send_lrc (string lrc, string filename);

        public void download_lyric (string lrc_location, string filename) {
            var msg = new Soup.Message ("GET", @"http://music.163.com/api/song/lyric?id=$(lrc_location)&lv=-1&kv=-1&tv=-1");
            var session = new Soup.Session ();
            session.user_agent = "Niki/0.5";
            session.queue_message (msg, (sess, mess) => {
                try {
                    var parser = new Json.Parser ();
                    parser.load_from_data ((string) mess.response_body.flatten ().data, -1);
                    var root_object = parser.get_root ().get_object ();
                    if(root_object.get_int_member ("code") == 200){
                        if (!root_object.has_member ("lrc")) {
                            return;
                        }
                        var result = root_object.get_object_member ("lrc");
                        send_lrc (result.get_string_member("lyric"), filename);
                    }
                } catch (Error e) {
                    GLib.warning (e.message);
                }
            });
        }

        public void search_lyrics (string title, string artist) {
            var msg = new Soup.Message ("POST", @"http://music.163.com/api/search/get?s=$(title),$(artist)&type=1");
            var session = new Soup.Session ();
            session.user_agent = "Niki/0.5";
            session.queue_message (msg, (sess, mess) => {
                try {
                    var parser = new Json.Parser ();
                    parser.load_from_data ((string) mess.response_body.flatten ().data, -1);
                    if (parser.get_root () == null) {
                        return;
                    }
                    var root_object = parser.get_root ().get_object ();
                    if(root_object.get_int_member ("code") == 200){
                        if (!root_object.has_member ("result")) {
                            return;
                        }
                        var result = root_object.get_object_member ("result");
                        if (!result.has_member ("songs")) {
                            return;
                        }
                        var songs = result.get_array_member ("songs");
                        for (uint niki = 0; niki < songs.get_length (); niki++) {
                            var song = songs.get_object_element(niki);
                            var song_id = song.get_int_member("id");
                            var song_name = song.get_string_member("name");
                            var songs_artists = song.get_array_member("artists");
                            var song_artists = songs_artists.get_object_element(0);
                            var song_artist = song_artists.get_string_member("name");
                            send_data (song_name, song_artist, "LRC", song_id.to_string (), "NetEase");
                        }
                    }
                } catch (Error e) {
                    GLib.warning (e.message);
                }
            });
        }
    }
}
