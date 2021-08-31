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
    public class ACDManager : GLib.Object {
        private static ACDManager _instance = null;
        public static ACDManager instance {
            get {
                if (_instance == null) {
                    _instance = new ACDManager ();
                }
                return _instance;
            }
        }

        const string FILE_ATTRIBUTE_TITLE = "xattr::org.gnome.audio.title";
        const string FILE_ATTRIBUTE_ARTIST = "xattr::org.gnome.audio.artist";
        const string FILE_ATTRIBUTE_ALBUM = "xattr::org.gnome.audio.album";
        public string mb_disc_id;
        private GLib.VolumeMonitor monitor;
        private Gee.TreeSet<Volume> volumes;

        construct {
            monitor = GLib.VolumeMonitor.get ();
            volumes = new Gee.TreeSet<Volume> ();
            monitor.get_volumes ().foreach ((volume) => {
                if (has_acd_media (volume)) {
                    volumes.add (volume);
                }
            });

            monitor.volume_added.connect ((volume) => {
                check_for_volume (volume);
            });

            monitor.volume_changed.connect ((volume) => {
                check_for_volume (volume);
            });

            monitor.volume_removed.connect ((volume) => {
                volumes.remove (volume);
            });
        }

        private void check_for_volume (Volume volume) {
            if (has_acd_media (volume)) {
                volumes.add (volume);
            }
        }
        public Gee.TreeSet<Volume> get_volumes () {
            return volumes;
        }
        public Gee.TreeSet<Volume> get_media_volumes () {
            var return_value = new Gee.TreeSet<Volume> ();
            foreach (Volume volume in volumes) {
                if (has_acd_media (volume)) {
                    return_value.add (volume);
                }
            }
            return return_value;
        }
        public bool has_media_volumes () {
            return (get_media_volumes ().size > 0);
        }
        private bool has_acd_media (Volume volume) {
            var icon_name = volume.get_icon ().to_string ();
            return icon_name.contains ("optical");
        }

        public void get_acd_vol (Volume volume) {
            volume.mount.begin (MountMountFlags.NONE, null, null, (obj, res)=>{
                create_list (volume);
                disc_id ();
            });
        }

        public void create_list (Volume volume) {
            var file = volume.get_activation_root ();
            var attributes = new string[0];
            attributes += FILE_ATTRIBUTE_TITLE;
            attributes += FILE_ATTRIBUTE_ALBUM;
            attributes += FILE_ATTRIBUTE_ARTIST;
            attributes += FileAttribute.STANDARD_NAME;

            file.query_info_async.begin (string.joinv (",", attributes), FileQueryInfoFlags.NONE, Priority.DEFAULT, null, (obj, res) => {
                try {
                    FileInfo file_info = file.query_info_async.end (res);
                    int counter = 1;
                    var children = file.enumerate_children (string.joinv (",", attributes), GLib.FileQueryInfoFlags.NONE);
                    while ((file_info = children.next_file ()) != null) {
                        string? title = file_info.get_attribute_string (FILE_ATTRIBUTE_TITLE) != null? file_info.get_attribute_string (FILE_ATTRIBUTE_TITLE).strip () : _ ("Track %d").printf (counter);
                        string? artist = file_info.get_attribute_string (FILE_ATTRIBUTE_ARTIST) != null? file_info.get_attribute_string (FILE_ATTRIBUTE_ARTIST) : _("Unknown");
                        string album = file_info.get_attribute_string (FILE_ATTRIBUTE_ALBUM);
                        string uri = GLib.Path.build_filename (file.get_uri (), file_info.get_name ());
                        NikiApp.window.player_page.right_bar.playlist.add_acd (uri, title, album, artist);
                        counter++;
                    }
                } catch (Error err) {
                    warning (err.message);
                }
            });

            if (NikiApp.window.player_page.right_bar.playlist.liststore.iter_n_children (null) > 0 && NikiApp.window.main_stack.visible_child_name == "welcome") {
                NikiApp.window.player_page.right_bar.playlist.play_first ();
            }
        }

        private void disc_id () {
            new Thread<void*> ("disc_id", () => {
                dynamic Gst.Element source = null;
                try {
                    source = Gst.Element.make_from_uri (Gst.URIType.SRC, "cdda://", null);
                } catch (Error err) {
                    warning (err.message);
                }
                if (source == null) {
                    return null;
                }
                source.@set ("device", "/dev/cdrom", null);
                dynamic Gst.Element pipeline = new Gst.Pipeline (null);
                dynamic Gst.Element sink = Gst.ElementFactory.make ("fakesink", null);
                ((Gst.Bin)pipeline).add_many (source, sink);
                source.link (sink);
                pipeline.set_state (Gst.State.PAUSED);
                Gst.Bus bus = pipeline.get_bus ();
                bool done = false;
                while (!done) {
                    Gst.Message? msg;
                    Gst.TagList tags;
                    msg = bus.timed_pop (10 * Gst.SECOND);
                    if (msg == null) {
                        break;
                    }
                    if (msg.type == Gst.MessageType.TAG) {
                        msg.parse_tag (out tags);
                        string s;
                        if (tags.get_string (Gst.Tag.CDDA.MUSICBRAINZ_DISCID, out s)) {
                            mb_disc_id = s;
                        }
                        done = true;
                    } else if (msg.type == Gst.MessageType.ERROR) {
                        string debug;
                        GLib.Error err;
                        msg.parse_error (out err, out debug);
                        warning ("Error: %s\n%s\n", err.message, debug);
                        done = true;
                    }
                }
                pipeline.set_state (Gst.State.NULL);
                return null;
            });
        }
    }
}
