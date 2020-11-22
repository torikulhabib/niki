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
    public class MPRIS : GLib.Object {
        private ClutterGst.Playback playback;
        private unowned DBusConnection connecting;
        private uint owner_id;
        private uint root_id;
        private uint player_id;

        public void bus_acive (ClutterGst.Playback playback){
            this.playback = playback;
            initialize ();
            NikiApp.settings.changed["next-status"].connect (initialize);
            NikiApp.settings.changed["previous-status"].connect (initialize);
        }
        public void initialize () {
            if (owner_id != 0) {
                this.connecting.unregister_object (root_id);
                this.connecting.unregister_object (player_id);
                Bus.unown_name (owner_id);
            }
            owner_id = Bus.own_name (BusType.SESSION, "org.mpris.MediaPlayer2.Niki", GLib.BusNameOwnerFlags.NONE, (connection)=>{
                this.connecting = connection;
                try {
                    root_id = connection.register_object ("/org/mpris/MediaPlayer2", new MprisRoot ());
                    player_id = connection.register_object ("/org/mpris/MediaPlayer2", new MprisPlayer (connection, playback));
                } catch (IOError e) {
                    warning ("could not create MPRIS player: %s\n", e.message);
                }
            });
        }
    }
}
