/*
* Copyright (c) {2021} torikulhabib (https://github.com/torikulhabib)
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
    public class EngineMegalobiz : Object {
        private const string MEGALOBIZ_SEARCH_RESULT_PATTERN = "<a class=\"entity_name\".*?id=\"([0-9]+)\".*?name=\"(.*?)\".*?href=\"(.*?)\".+?</a>";
        private const string MEGALOBIZ_LRC_PATTERN = "lyrics_details.*?<span.*?>(.*?)</span>";
        public signal void send_data (string title, string artist, string type, string text, string server);
        public signal void send_lrc (string lrc, string filename);

        public void download_lyric (string lrc_location, string filename) {
            var msg = new Soup.Message ("GET", @"https://www.megalobiz.com$(lrc_location)");
            var session = new Soup.Session ();
            session.user_agent = "Niki/0.5";
            session.queue_message (msg, (sess, mess) => {
                string[] array_word = ((string) (mess.response_body.flatten ().data)).split ("\n");
                string word_entry = "";
                foreach (string list_data in array_word) {
                    word_entry += list_data.strip ();
                }
                try {
                    MatchInfo match_info;
                    Regex regex = new Regex (MEGALOBIZ_LRC_PATTERN);
                    regex.match_full (word_entry, -1, 0, 0, out match_info);
                    string match = match_info.fetch (1);
                    string[] split_br = match.replace ("</span>", "").split ("<br>");
                    string full_lyric = "";
                    foreach (string lyric in split_br) {
                        full_lyric += @"$(lyric)\n";
                    }
                    send_lrc (full_lyric, filename);
                } catch (Error e) {
                    GLib.warning (e.message);
                }
            });
        }

        public void search_lyrics (string title, string artist) {
            string search_lrc = artist.replace (" ", "+") + "+" + title.replace (" ", "+");
            var msg = new Soup.Message ("GET", @"https://www.megalobiz.com/search/all?qry=$(search_lrc)");
            var session = new Soup.Session ();
            session.user_agent = "Niki/0.5";
            session.queue_message (msg, (sess, mess) => {
                string[] array_word = ((string) (mess.response_body.flatten ().data)).split ("\n");
                string word_entry = "";
                foreach (string list_data in array_word) {
                    word_entry += list_data.strip () + " ";
                    if (Regex.match_simple (MEGALOBIZ_SEARCH_RESULT_PATTERN, word_entry)) {
                        try {
                            MatchInfo match_info;
                            Regex regex = new Regex (MEGALOBIZ_SEARCH_RESULT_PATTERN);
                            regex.match_full (word_entry, -1, 0, 0, out match_info);
                            string match = match_info.fetch (2);
                            string title_song = "";
                            string artist_song = "";
                            if (match.down ().contains ("by")) {
                                string[] songs = match.split ("by");
                                title_song = songs[0].strip ();
                                artist_song = songs[1].strip ();
                            } else {
                                title_song = title;
                                artist_song = match;
                            }
                            send_data (title_song, artist_song, "LRC", match_info.fetch (3), "MegaLobiz");
                        } catch (Error e) {
                            GLib.warning (e.message);
                        }
                        word_entry = "";
                    }
                }
            });
        }
    }
}
