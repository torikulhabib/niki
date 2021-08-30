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
    public class EngineViewlyrics : Object {
        public signal void send_data (string title, string artist, string type, string text, string server);
        public signal void send_lrc (string lrc, string filename);

        public void download_lyric (string lrc_location, string filename) {
            var msg = new Soup.Message ("GET", @"http://search.crintsoft.com/l/$(lrc_location)");
            var session = new Soup.Session () {
                user_agent = "Niki/0.5"
            };
            session.queue_message (msg, (sess, mess) => {
                send_lrc ((string)mess.response_body.flatten ().data, filename);
            });
        }

        public void search_lyrics (string title, string artist) {
            var msg = new Soup.Message ("POST", "http://search.crintsoft.com/searchlyrics.htm");
            msg.set_request (Soup.FORM_MIME_TYPE_MULTIPART, Soup.MemoryUse.COPY, string_to_uint8 (mount_query (title, artist)));
            var session = new Soup.Session () {
                user_agent = "Niki/0.5"
            };
            session.queue_message (msg, (sess, mess)=> {
                for (int niki = 0; niki < 5000; niki++) {
                    string get_url = uint8_to_string (mess.response_body.flatten ().data, niki);
                    if (get_url != null) {
                        if (niki == get_url.char_count () + niki ) {
                            string found = uint8_to_string (mess.response_body.flatten ().data, niki + 1);
                            if (found.has_prefix ("CT")) {
                                return;
                            }
                            if (found.down ().has_suffix ("lrc")) {
                                send_data (title, artist, "LRC", found, "ViewLRC");
                            }
                            if (found.down ().has_suffix ("txt")) {
                                send_data (title, artist, "TXT", found, "ViewLRC");
                            }
                        }
                    }
                }
            });
        }

        private static string mount_query (string title, string artist) {
            var builder = new StringBuilder ();
            string tmpl = "%s=\"%s\" ";
            builder.append (tmpl.printf ("artist", artist));
            builder.append (tmpl.printf ("title", title));
            builder.append (tmpl.printf ("client", "MiniLyrics"));
            builder.append (tmpl.printf ("RequestPage", "0"));
            return "<?xml version=\'1.0\' encoding=\'utf-8\' ?><searchV1 %s />".printf (builder.str);
        }

        private string uint8_to_string (uint8[] response_data, int input) {
            uint8[] reassembled_string = {};
            var code_key = response_data[1];
                foreach (var character in response_data[input:response_data.length]) {
                    char decoded_char = (char) (character ^ code_key);
                    reassembled_string += decoded_char;
                }
            return (string) reassembled_string;
        }
        private uint8[] string_to_uint8 (string query) {
            uint8[] payload = { 0x02, 0x00, 0x04, 0x00, 0x00, 0x00 };
            foreach (var byte in compute_message_hash ("Mlv1clt4.0", query)) {
                payload += byte;
            }
            foreach (var byte in query.data) {
                payload += byte;
            }
            return payload;
        }

        private static uint8[] compute_message_hash (string key, string query) {
            var message = new Checksum (ChecksumType.MD5);
            message.update (query.data, query.data.length);
            message.update (key.data, key.data.length);
            uint8[] buffer = new uint8[100];
            size_t digest_len = -1;
            message.get_digest (buffer, ref digest_len);
            buffer.resize ((int) digest_len);
            return buffer;
        }
    }
}
