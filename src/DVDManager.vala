// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2014 Audience Developers (http://launchpad.net/pantheon-chat)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Corentin Noël <corentin@elementaryos.org>
 */
namespace niki {
    public class DVDManager : GLib.Object {
        private static DVDManager _instance = null;
        public static DVDManager instance {
            get {
                if (_instance == null) {
                    _instance = new DVDManager ();
                }
                return _instance;
            }
        }

        private GLib.VolumeMonitor monitor;
        private Gee.TreeSet<Volume> volumes;

        construct {
            monitor = GLib.VolumeMonitor.get ();
            volumes = new Gee.TreeSet<Volume> ();
            monitor.get_volumes ().foreach ((volume) => {
                if (has_dvd_media (volume)) {
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

        public Gee.TreeSet<Volume> get_volumes () {
            return volumes;
        }

        public Gee.TreeSet<Volume> get_media_volumes () {
            var return_value = new Gee.TreeSet<Volume> ();
            foreach (Volume volume in volumes) {
                if (has_dvd_media (volume)) {
                    return_value.add (volume);
                }
            }
            return return_value;
        }

        public bool has_media_volumes () {
            return (get_media_volumes ().size > 0);
        }

        private void check_for_volume (Volume volume) {
            if (has_dvd_media (volume)) {
                volumes.add (volume);
            }
        }

        private bool has_dvd_media (Volume volume) {
            var icon_name = volume.get_icon ().to_string ();
            if (!icon_name.contains ("optical")) {
                return false;
            }

            if (volume.get_drive () != null && volume.get_drive ().has_media ()) {
                var root = volume.get_mount ().get_default_location ();
                if (root != null) {
                    var video = root.get_child ("VIDEO_TS");
                    var bdmv = root.get_child ("BDMV");
                    if (video.query_exists () || bdmv.query_exists ()) {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}
