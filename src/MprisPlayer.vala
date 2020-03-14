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
    [DBus (name = "org.mpris.MediaPlayer2.Player")]
    public class MprisPlayer : GLib.Object {
        [DBus (visible = false)]
        public unowned DBusConnection connection { get; construct set; }
        private ClutterGst.Playback playback;
        private uint send_property_source = 0;
        private HashTable<string,Variant> changed_properties = null;
        private HashTable<string,Variant> metadata;

        public MprisPlayer (DBusConnection connection, ClutterGst.Playback playback) {
            this.connection = connection;
            this.playback = playback;
            metadata = new HashTable<string, Variant> (str_hash, str_equal);
            playback.notify["playing"].connect (playing_changed);
            playback.eos.connect (update_metadata);
            playback.notify["idle"].connect (update_metadata);
            NikiApp.settings.changed["next-status"].connect (update_metadata);
            NikiApp.settings.changed["previous-status"].connect (update_metadata);
        }

        private uint update_metadata_source = 0;
        private void playing_changed () {
            if (update_metadata_source != 0) {
                Source.remove (update_metadata_source);
            }

            update_metadata_source = Timeout.add (300, () => {
                Variant variant = playback_status;
                queue_property_for_notification ("PlaybackStatus", variant);
                queue_property_for_notification ("Metadata", metadata);
                update_metadata_source = 0;
                return false;
            });
        }

        private void update_metadata () {
            playing_changed ();
            string album_path = cache_image (NikiApp.settings.get_string("title-playing"));
            switch (NikiApp.settings.get_enum ("player-mode")) {
                case PlayerMode.VIDEO :
                    string hash_file_poster = GLib.Checksum.compute_for_string (ChecksumType.MD5, NikiApp.settings.get_string ("uri-video"), NikiApp.settings.get_string ("uri-video").length);
                    string preview_path = Path.build_filename (GLib.Environment.get_user_cache_dir (), "thumbnails", "normal", hash_file_poster + ".png");
                    metadata = new HashTable<string, Variant> (null, null);
                    metadata.insert ("mpris:length", playback.duration * 1000000);
                    metadata.insert ("mpris:artUrl", "file://" + preview_path);
                    metadata.insert ("xesam:title", NikiApp.settings.get_string("title-playing"));
                    metadata.insert ("xesam:album", "Unknown");
                    metadata.insert ("xesam:artist", get_simple_string_array ("Unknown"));
                    metadata.insert ("xesam:url", NikiApp.settings.get_string ("uri-video"));
                    break;
                case PlayerMode.AUDIO :
                    string album_path_music = cache_image (NikiApp.settings.get_string("title-playing") + " " + NikiApp.settings.get_string ("artist-music"));
                    metadata = new HashTable<string, Variant> (null, null);
                    metadata.insert ("mpris:length", playback.duration * 1000000);
                    metadata.insert ("mpris:artUrl", "file://" + album_path_music);
                    metadata.insert ("xesam:title", NikiApp.settings.get_string ("title-playing"));
                    metadata.insert ("xesam:album", NikiApp.settings.get_string ("album-music"));
                    metadata.insert ("xesam:artist", get_simple_string_array (NikiApp.settings.get_string ("artist-music")));
                    metadata.insert ("xesam:url", NikiApp.settings.get_string ("uri-video"));
                    break;
                case PlayerMode.STREAMAUD :
                    metadata = new HashTable<string, Variant> (null, null);
                    metadata.insert ("mpris:length", playback.duration * 1000000);
                    metadata.insert ("mpris:artUrl", "file://" + album_path);
                    metadata.insert ("xesam:title", NikiApp.settings.get_string("title-playing"));
                    break;
                case PlayerMode.STREAMVID :
                    metadata = new HashTable<string, Variant> (null, null);
                    metadata.insert ("mpris:length", playback.duration * 1000000);
                    metadata.insert ("mpris:artUrl", "file://" + album_path);
                    metadata.insert ("xesam:title", NikiApp.settings.get_string("title-playing"));
                    break;
            }
        }

        private static string[] get_simple_string_array (string? text) {
            if (text == null) {
                return new string[0];
            }
            string[] array = new string[0];
            array += text;
            return array;
        }

        private bool send_property_change () {
            if (changed_properties == null) {
                return false;
            }

            var builder = new VariantBuilder (VariantType.ARRAY);
            var invalidated_builder = new VariantBuilder (new VariantType ("as"));

            foreach (string name in changed_properties.get_keys ()) {
                Variant variant = changed_properties.lookup (name);
                builder.add ("{sv}", name, variant);
            }

            changed_properties = null;

            try {
                this.connection.emit_signal (null, "/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", "PropertiesChanged",
 new Variant ("(sa{sv}as)", "org.mpris.MediaPlayer2.Player", builder, invalidated_builder));
            } catch (Error e) {
                print ("Could not send MPRIS property change: %s\n", e.message);
            }
            send_property_source = 0;
            return false;
        }

        private void queue_property_for_notification (string property, Variant val) {
            if (changed_properties == null) {
                changed_properties = new HashTable<string, Variant> (str_hash, str_equal);
            }
            changed_properties.insert (property, val);

            if (send_property_source == 0) {
                send_property_source = Idle.add (send_property_change);
            }
        }

        public string playback_status {
            owned get {
                if (playback.playing) {
                    return "Playing";
                } else if (!playback.playing && playback.progress == 0.0) {
                    return "Stopped";
                } else if (!playback.playing) {
                    return "Paused";
                } else {
                    return "Stopped";
                }
            }
        }

        public double volume {
            get {
                return NikiApp.settings.get_double ("volume-adjust");
            }
            set {
                NikiApp.settings.set_double ("volume-adjust", value);
            }
        }

        public int64 position {
            get {
                return ((int64)(playback.get_position () * 1000000));
            }
        }
        public bool CanGoNext {
            get {
                return NikiApp.settings.get_boolean ("next-status"); 
            }
        }
        public bool CanGoPrevious {
            get {
                return NikiApp.settings.get_boolean ("previous-status");
            }
        }
        public bool CanPlay {
            get {
                return true;
            }
        }
        public bool CanPause {
            get {
                return true;
            }
        }
        public signal void seeked (int64 Position);

        public void previous () throws GLib.Error {
            if (NikiApp.settings.get_boolean ("previous-status")) {
                window.player_page.previous ();
                GLib.Timeout.add (250, () => {
                    window.player_page.string_notify (StringPot.Previous);
                    return Source.REMOVE;
                });
            }
        }

        public void next () throws GLib.Error {
            if (NikiApp.settings.get_boolean("next-status")) {
                window.player_page.next ();
                GLib.Timeout.add (250, () => {
                    window.player_page.string_notify (StringPot.Next);
                    return Source.REMOVE;
                });
            }
        }

        public void pause () throws GLib.Error {
            playback.playing = false;
            window.player_page.string_notify (StringPot.Pause);
        }

        public void play () throws GLib.Error {
            playback.playing = true;
            window.player_page.string_notify (StringPot.Play);
        }

        public void stop () throws GLib.Error {
            playback.playing = false;
            playback.progress = 0.0;
            window.player_page.string_notify (StringPot.Stop);
        }

        public void PlayPause () throws GLib.Error {
            playback.playing = playback.playing? false : true;
            window.player_page.string_notify (playback.playing? StringPot.Play : StringPot.Pause);
        }

        public void seek (int64 offset) throws GLib.Error {
            var duration = playback.duration;
            var progress = playback.progress;
            var new_progress = ((duration * progress) + ((double)(offset/1000000))/duration);
            playback.progress = new_progress.clamp (0.0, 1.0);
        }

        public void set_position (string dobj, int64 Position) throws GLib.Error {
            playback.progress = ((double)(Position/1000000)).clamp (0.0, 1.0);
        }
    }
}
