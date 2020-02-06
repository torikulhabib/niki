namespace niki {
    public class MPRIS : GLib.Object {
        private ClutterGst.Playback playback;
        private MprisRoot? mprisroot;
        private MprisPlayer? mprisplayer;
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
                reload_mpris ();
            }
            owner_id = Bus.own_name (BusType.SESSION, "org.mpris.MediaPlayer2.Niki", GLib.BusNameOwnerFlags.NONE, on_bus_acquired, null, null);
            if (owner_id == 0) {
                warning ("Could not initialize MPRIS session.\n");
            }
        }

        private void on_bus_acquired (DBusConnection connection) {
            this.connecting = connection;
            mprisroot = new MprisRoot ();
            mprisplayer = new MprisPlayer (connection, playback);
            try {
                root_id = connection.register_object ("/org/mpris/MediaPlayer2", mprisroot);
                player_id = connection.register_object ("/org/mpris/MediaPlayer2", mprisplayer);
            } catch (IOError e) {
                warning ("could not create MPRIS player: %s\n", e.message);
            }
        }

        public void reload_mpris () {
            this.connecting.unregister_object (root_id);
            this.connecting.unregister_object (player_id);
            Bus.unown_name (owner_id);
        }
    }
}
