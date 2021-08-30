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
    public class EngineSubtittle4Songs : Object {
        private const string S4S_SEARCH_RESULT_PATTERN = "<a [^<]*?href=\"getsubtitle.aspx.*?(artist=.*?)(song=.*?)\">";
        private const string S4S_LRC_PATTERN = "<span id=\"ctl00_ContentPlaceHolder1_lbllyrics\"><h3>(.*?)</h3>(.*?)</span>";

        public signal void send_data (string title, string artist, string type, string text, string server);
        public signal void send_lrc (string lrc, string filename);

        public void download_lyric (string lrc_location, string filename) {
            var msg = new Soup.Message ("GET", lrc_location);
            var session = new Soup.Session () {
                user_agent = "Niki/0.5"
            };
            session.queue_message (msg, (sess, mess) => {
                string[] array_word = ((string) (mess.response_body.flatten ().data)).split ("\n");
                string word_entry = "";
                foreach (string list_data in array_word) {
                    word_entry += list_data.strip ();
                }
                try {
                    MatchInfo match_info;
                    Regex regex = new Regex (S4S_LRC_PATTERN);
                    regex.match_full (word_entry, -1, 0, 0, out match_info);
                    string match = match_info.fetch (0);
                    string[] split_h3 = match.split ("</h3>");
                    string[] split_br = split_h3[1].replace ("www.RentAnAdviser.com", "").replace ("RentAnAdviser.com", "").replace ("</span>", "").split ("<br />");
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
            var msg = new Soup.Message ("GET", @"https://www.rentanadviser.com/en/subtitles/subtitles4songs.aspx?q=$(search_lrc)");
            var session = new Soup.Session () {
                user_agent = "Niki/0.5"
            };
            session.queue_message (msg, (sess, mess) => {
                string[] array_word = ((string) (mess.response_body.flatten ().data)).split ("\n");
                string word_entry = "";
                foreach (string list_data in array_word) {
                    word_entry += list_data.strip () + " ";
                    if (Regex.match_simple (S4S_SEARCH_RESULT_PATTERN, word_entry)) {
                        try {
                            MatchInfo match_info;
                            Regex regex = new Regex (S4S_SEARCH_RESULT_PATTERN);
                            regex.match_full (word_entry, -1, 0, 0, out match_info);
                            string match_ar = match_info.fetch (1);
                            string match_so = match_info.fetch (2);
                            string url_dw = @"https://www.rentanadviser.com/en/subtitles/getsubtitle.aspx?$(match_ar)$(match_so)&type=lrc";
                            string[] title_song = match_so.replace ("%20", " ").split ("song=");
                            string[] artist_song = match_ar.replace ("%20", " ").replace ("%2C", " ").split ("artist=");
                            int last_and = artist_song[1].last_index_of ("&");
                            string without_and = artist_song[1].slice (0, last_and);
                            send_data (Markup.escape_text (title_song[1]), Markup.escape_text (without_and), "LRC", url_dw, "Subtittle4Songs");
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
