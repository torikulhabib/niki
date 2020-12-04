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
    public class DLNARenderControl : Gtk.ComboBox {
        private WelcomePage? welcompage;
        private static Gtk.ListStore liststore;
        private static GUPnP.ServiceProxy connection_manager;
        private const string SEPARATOR_NAME = "<separator_item_unique_name>";
        private static string NIKI_MODE = _("Niki Player");

        public DLNARenderControl (WelcomePage welcompage) {
            this.welcompage = welcompage;
            liststore = new Gtk.ListStore (DlnaComboColumns.N_COLUMNS, typeof (Gdk.Pixbuf), typeof (string), typeof (GUPnP.DeviceProxy), typeof (GUPnP.ServiceProxy), typeof (GUPnP.ServiceProxy));
            model = liststore;
		    var cell = new Gtk.CellRendererText ();
		    cell.ellipsize = Pango.EllipsizeMode.END;
		    var cell_pb = new Gtk.CellRendererPixbuf ();
		    pack_start (cell_pb, false);
		    pack_start (cell, false);
		    set_attributes (cell_pb, "pixbuf", DlnaComboColumns.PIXBUF);
		    set_attributes (cell, "text", DlnaComboColumns.DEVICENAME);
		    show_all ();
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, DlnaComboColumns.PIXBUF, from_theme_icon ("com.github.torikulhabib.niki", 64, 16), DlnaComboColumns.DEVICENAME, NIKI_MODE);
            set_row_separator_func ((model, iter) => {
                string content;
                model.get (iter, DlnaComboColumns.DEVICENAME, out content);
                return content == SEPARATOR_NAME;
            });

            Idle.add (()=> {
                set_active_iter (iter);
                return false;
            });
            NikiApp.settings.changed["dlna-muted"].connect (() => {
                muted_control ();
                volume_changed ();
            });
            NikiApp.settings.changed["dlna-volume"].connect (volume_changed);
            NikiApp.settings.changed["dlna-state"].connect (() => {
                set_state_playback (NikiApp.settings.get_enum ("dlna-state"));
            });
            changed.connect (()=> {
                set_state_playback (NikiApp.settings.get_enum ("dlna-state"));
            });
        }

        public bool get_selected_device () {
            string device_name;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return false;
            }
            liststore.get (iter, DlnaComboColumns.DEVICENAME, out device_name);
            if (device_name == NIKI_MODE) {
                return true;
            }
            return false;
        }
        private static GUPnP.ServiceProxy get_connection_manager (GUPnP.DeviceInfo proxy) {
            GUPnP.ServiceInfo cm = proxy.get_service ("urn:schemas-upnp-org:service:ConnectionManager");
            return ((GUPnP.ServiceProxy)cm);
        }
        private static GUPnP.ServiceProxy get_av_transport (GUPnP.DeviceInfo proxy) {
            GUPnP.ServiceInfo info = proxy.get_service ("urn:schemas-upnp-org:service:AVTransport");
            return ((GUPnP.ServiceProxy)info);
        }

        private static GUPnP.ServiceProxy get_rendering_control (GUPnP.DeviceInfo proxy) {
            GUPnP.ServiceInfo info = proxy.get_service ("urn:schemas-upnp-org:service:RenderingControl");
            return ((GUPnP.ServiceProxy)info);
        }

        private void set_state_playback (int state) {
            if (get_selected_device ()) {
                return;
            }
            if (state == PlaybackState.PLAYING || state == PlaybackState.PAUSED || state == PlaybackState.TRANSITIONING) {
                sensitive = false;
            } else {
                sensitive = true;
            }
            controls_state (state);
        }
        private static void set_state_by_name (string state_name) {
            switch (state_name) {
                case "STOPPED" :
                    NikiApp.settings.set_enum ("dlna-state", PlaybackState.STOPPED);
                    break;
                case "PLAYING" :
                    NikiApp.settings.set_enum ("dlna-state", PlaybackState.PLAYING);
                    break;
                case "PAUSED_PLAYBACK" :
                    NikiApp.settings.set_enum ("dlna-state", PlaybackState.PAUSED);
                    break;
                case "TRANSITIONING" :
                    NikiApp.settings.set_enum ("dlna-state", PlaybackState.TRANSITIONING);
                    break;
                case "NO_MEDIA_PRESENT" :
                    NikiApp.settings.set_enum ("dlna-state", PlaybackState.UNKNOWN);
                    break;
            }
        }

        public void clear_selected_renderer_state () {
            playback_control ("Stop");
            set_state_playback (PlaybackState.UNKNOWN);
        }

        public static void on_last_change (GUPnP.ServiceProxy av_transport, string variable_name, Value value) {
            string state_name;
            string last_change_xml = value.get_string ();
            var lc_parser = new GUPnP.LastChangeParser ();
            try {
                if (lc_parser.parse_last_change (0, last_change_xml, "TransportState", GLib.Type.STRING, out state_name)) {
                    if (state_name != null) {
                        set_state_by_name (state_name);
                    }
                }
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }
        private static void on_rendering_control_last_change (GUPnP.ServiceProxy rendering_control, string variable_name, Value value) {
            uint volume = 0;
            bool mute = false;
            string last_change_xml = value.get_string ();
            var lc_parser = new GUPnP.LastChangeParser ();
            try {
                if (lc_parser.parse_last_change (0, last_change_xml, "Volume", Type.UINT, out volume, "Mute", Type.BOOLEAN, out mute)) {
                    NikiApp.settings.set_boolean ("dlna-muted", mute);
                    if (!NikiApp.settings.get_boolean ("dlna-muted") && !mute) {
                        NikiApp.settings.set_int ("dlna-volume", (int) volume);
                    }
                }
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }

        private void append_media_renderer_to_tree (GUPnP.DeviceProxy proxy, GUPnP.ServiceProxy av_transport, GUPnP.ServiceProxy rendering_control, string udn) {
            GUPnP.DeviceInfo info = (GUPnP.DeviceInfo) proxy;
            string name = info.get_friendly_name ();
            Gdk.Pixbuf icon = null;
            string nameimage = cache_image (udn);
            if (!FileUtils.test (nameimage, FileTest.EXISTS)) {
                icon = align_and_scale_pixbuf (get_pixbuf_device_info (info), 16);
            } else {
                icon = pix_scale (nameimage, 16);
	        }
            if (name == null) {
                return;
            }
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, DlnaComboColumns.PIXBUF, icon, DlnaComboColumns.DEVICENAME, name, DlnaComboColumns.DEVICEPROXY, proxy, DlnaComboColumns.SERVICEAVTRANS, av_transport, DlnaComboColumns.SERVICERENDER, rendering_control);
            av_transport.add_notify ("LastChange", Type.STRING, on_last_change);
            rendering_control.add_notify ("LastChange", Type.STRING, on_rendering_control_last_change);
            av_transport.set_subscribed (true);
            rendering_control.set_subscribed (true);
        }

        public void add_media_renderer (GUPnP.DeviceProxy proxy) {
            if (proxy == null) {
                return;
            }
            string udn = proxy.get_udn ();
            GUPnP.DeviceInfo info = (GUPnP.DeviceInfo)proxy;
            GUPnP.ServiceProxy av_transport = get_av_transport (info);
            if (av_transport == null) {
                return;
            }
            GUPnP.ServiceProxy rendering_control = get_rendering_control (info);
            if (rendering_control == null) {
                return;
            }
            bool exist = false;
            bool sparat_bool = false;
            liststore.foreach ((model, path, iter) => {
                GUPnP.DeviceProxy proxy_udn;
                string sparator;
                model.get (iter, DlnaComboColumns.DEVICEPROXY, out proxy_udn, DlnaComboColumns.DEVICENAME, out sparator);
                if (proxy_udn == null) {
                    return false;
                }
                if (udn == proxy_udn.get_udn ()) {
                    exist = true;
                }
                if (sparator == SEPARATOR_NAME) {
                    sparat_bool = true;
                }
                return false;
            });
            if (exist) {
                return;
            }
            if (!sparat_bool) {
                add_separator ();
            }
            append_media_renderer_to_tree (proxy, av_transport, rendering_control, udn);
        }

        public void add_separator () {
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, DlnaComboColumns.PIXBUF, null, DlnaComboColumns.DEVICENAME, SEPARATOR_NAME);
        }

        public void remove_media_renderer (GUPnP.DeviceProxy proxy) {
            if (proxy == null) {
                return;
            }
            string udn = proxy.get_udn ();
            Gtk.TreeIter iter;
            for (int i = 0; liststore.get_iter_from_string (out iter, i.to_string ()); ++i) {
                if (!liststore.iter_is_valid (iter)) {
                    return;
                }
                GUPnP.DeviceProxy proxyit;
                liststore.get (iter, DlnaComboColumns.DEVICEPROXY, out proxyit);
                if (proxyit != null) {
                    if (udn == proxyit.get_udn ()) {
                        liststore.remove (ref iter);
                        set_active (0);
                    }
                }
            }

            if (!get_active_iter (out iter)) {
                return;
            }
            if (liststore.iter_n_children (iter) < 1) {
                for (int i = 0; liststore.get_iter_from_string (out iter, i.to_string ()); ++i) {
                    if (!liststore.iter_is_valid (iter)) {
                        return;
                    }
                    string sparator;
                    liststore.get (iter, DlnaComboColumns.DEVICENAME, out sparator);
                    if (sparator == SEPARATOR_NAME) {
                        liststore.remove (ref iter);
                        set_active (0);
                    }
                }
            }
        }

        private void av_transport_action_cb (GUPnP.ServiceProxy av_transport, GUPnP.ServiceProxyAction action) {
            try {
                if (av_transport.end_action (action)) {}
            } catch (Error e) {
                warning ("%s", e.message);
            }
        }

        public void play (bool pause = true) {
            GUPnP.ServiceProxy av_transport;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            liststore.get (iter, DlnaComboColumns.SERVICEAVTRANS, out av_transport);

            if (av_transport == null) {
                return;
            }
            if (NikiApp.settings.get_enum ("dlna-state") == PlaybackState.PLAYING && pause) {
                playback_control ("Pause");
            } else {
                var in_names = new GLib.List <string> ();
                in_names.append ("InstanceID");
                in_names.append ("Speed");
                var in_values = new GLib.List<GLib.Value?> ();
                Value valueinst = Value (Type.UINT);
                valueinst.set_uint (0);
                in_values.append (valueinst);
                Value valuespe = Value (Type.STRING);
                valuespe.set_string ("1");
                in_values.append (valuespe);
                av_transport.begin_action_list ("Play", in_names, in_values, av_transport_action_cb);
            }
        }

        public void playback_control (string playback) {
            GUPnP.ServiceProxy av_transport;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            liststore.get (iter, DlnaComboColumns.SERVICEAVTRANS, out av_transport);

            if (av_transport == null) {
                return;
            }
            var in_names = new GLib.List <string> ();
            in_names.append ("InstanceID");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (0);
            in_values.append (valueinst);
            av_transport.begin_action_list (playback, in_names, in_values, av_transport_action_cb);
        }

        private void set_av_transport_uri_cb (GUPnP.ServiceProxy av_transport, GUPnP.ServiceProxyAction action) {
            try {
                if (av_transport.end_action (action)) {
                    if (!welcompage.dlnaaction.playing) {
                        play (false);
                    }
                }
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }

        public void set_av_transport_uri (string metadata, bool next_uri = false) {
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            GUPnP.DeviceProxy proxy;
            liststore.get (iter, DlnaComboColumns.DEVICEPROXY, out proxy);
            GUPnP.DeviceInfo info = (GUPnP.DeviceInfo)proxy;
            connection_manager = get_connection_manager (info);
            if (connection_manager == null) {
                return;
            }
            var in_names = new GLib.List <string> ();
            in_names.append ("");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (-1);
            in_values.append (valueinst);
            connection_manager.begin_action_list ("GetProtocolInfo", in_names, in_values, (connection_manager, action)=> {
                string sink_protocol;
                try {
                    if (connection_manager.end_action (action, "Sink", Type.STRING, out sink_protocol)) {
                        if (sink_protocol != null) {
                            int mediatype = 0;
                            var parser = new GUPnP.DIDLLiteParser ();
                            parser.object_available.connect ((parser, object) => {
                                GUPnP.DIDLLiteResource resource = object.get_compat_resource (sink_protocol, false);
                                string title = object.get_title ();
                                string upnp_class = object.get_upnp_class ();
                                GUPnP.ServiceProxy av_transport;
                                liststore.get (iter, DlnaComboColumns.SERVICEAVTRANS, out av_transport);
                                string uri = resource.get_uri ();
                                if (welcompage.treview.downloaded) {
                                    if (upnp_class == "object.item.videoItem") {
                                        mediatype = 0;
                                    } else if (upnp_class == "object.item.audioItem.musicTrack") {
                                        mediatype = 2;
                                    } else if (upnp_class == "object.item.imageItem.photo") {
                                        mediatype = 4;
                                    } else {
                                        mediatype = 0;
                                    }
                                    var download_dialog = new DownloadDialog (this, uri, title, mediatype);
                                    download_dialog.show_all ();
                                    welcompage.treview.downloaded = false;
                                } else {
                                    if (!next_uri) {
                                        var in_namesf = new GLib.List <string> ();
                                        in_namesf.append ("InstanceID");
                                        in_namesf.append ("CurrentURI");
                                        in_namesf.append ("CurrentURIMetaData");
                                        var in_valuesf = new GLib.List<GLib.Value?> ();
                                        Value valueinstf = Value (Type.UINT);
                                        valueinstf.set_uint (0);
                                        in_valuesf.append (valueinstf);
                                        Value valuecur = Value (Type.STRING);
                                        valuecur.set_string (uri);
                                        in_valuesf.append (valuecur);
                                        Value valuecmet = Value (Type.STRING);
                                        valuecmet.set_string (metadata);
                                        in_valuesf.append (valuecmet);
                                        av_transport.begin_action_list ("SetAVTransportURI", in_namesf, in_valuesf, set_av_transport_uri_cb);
                                    } else {
                                        var in_namess = new GLib.List <string> ();
                                        in_namess.append ("InstanceID");
                                        in_namess.append ("NextURI");
                                        in_namess.append ("NextURIMetaData");
                                        var in_valuess = new GLib.List<GLib.Value?> ();
                                        Value valueinsta = Value (Type.UINT);
                                        valueinsta.set_uint (0);
                                        in_valuess.append (valueinsta);
                                        Value valuenext = Value (Type.STRING);
                                        valuenext.set_string (uri);
                                        in_valuess.append (valuenext);
                                        Value valuenmet = Value (Type.STRING);
                                        valuenmet.set_string (metadata);
                                        in_valuess.append (valuenmet);
                                        av_transport.begin_action_list ("SetNextAVTransportURI", in_namess, in_valuess, set_av_transport_uri_cb);
                                        welcompage.treview.next_uri = false;
                                    }
                                }
                            });
                            try {
                                parser.parse_didl (metadata);
                            } catch (Error err) {
                                critical ("%s", err.message);
                            }
                        }
                    }
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            });
        }

        public void on_position_scale_value_changed (uint total_secs) {
            GUPnP.ServiceProxy av_transport;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            liststore.get (iter, DlnaComboColumns.SERVICEAVTRANS, out av_transport);
            if (av_transport == null) {
                return;
            }
            var in_names = new GLib.List <string> ();
            in_names.append ("InstanceID");
            in_names.append ("Unit");
            in_names.append ("Target");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (0);
            in_values.append (valueinst);
            Value valueunit = Value (Type.STRING);
            valueunit.set_string ("ABS_TIME");
            in_values.append (valueunit);
            Value valuetarg = Value (Type.STRING);
            valuetarg.set_string (seconds_to_time ((int)total_secs, false));
            in_values.append (valuetarg);
            av_transport.begin_action_list ("Seek", in_names, in_values, av_transport_action_cb);
        }

        private void get_position_info_cb (GUPnP.ServiceProxy av_transport, GUPnP.ServiceProxyAction action) {
            string position;
            string duration;
            try {
                if (av_transport.end_action (action, "AbsTime", Type.STRING, out position, "TrackDuration", Type.STRING, out duration)) {
                    string [] position_split = position.split (".");
                    string [] duration_split = duration.split (".");
                    welcompage.dlnaaction.progress_duration_label.label = position_split [0] +" / " +  duration_split [0];
                    welcompage.dlnaaction.scale_range.set_range (0, (double) seconds_from_time (duration) / 100);
                    welcompage.dlnaaction.scale_range.set_value ((double) seconds_from_time (position) / 100);
                }
            } catch (Error err) {
                NikiApp.settings.set_enum ("dlna-state", PlaybackState.UNKNOWN);
                critical ("%s", err.message);
            }
        }
        private bool update_position () {
            GUPnP.ServiceProxy av_transport;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return false;
            }
            liststore.get (iter, DlnaComboColumns.SERVICEAVTRANS, out av_transport);
            if (av_transport == null) {
                return false;
            }
            var in_names = new GLib.List <string> ();
            in_names.append ("InstanceID");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (0);
            in_values.append (valueinst);
            av_transport.begin_action_list ("GetPositionInfo", in_names, in_values, get_position_info_cb);
            return true;
        }

        private void get_next_info_cb (GUPnP.ServiceProxy av_transport, GUPnP.ServiceProxyAction action) {
            string uri_next;
            try {
                if (av_transport.end_action (action, "NextURI", Type.STRING, out uri_next)) {
                    if (!File.new_for_uri  (uri_next).query_exists ()) {
                        welcompage.treview.next_signal ();
                    } else {
                        playback_control ("Next");
                    }
                }
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }
        public void next_media () {
            GUPnP.ServiceProxy av_transport;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            liststore.get (iter, DlnaComboColumns.SERVICEAVTRANS, out av_transport);
            if (av_transport == null) {
                return;
            }
            var in_names = new GLib.List <string> ();
            in_names.append ("InstanceID");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (0);
            in_values.append (valueinst);
            av_transport.begin_action_list ("GetMediaInfo", in_names, in_values, get_next_info_cb);
        }
        private uint timeout_id = 0;
        private void add_timeout () {
            if (timeout_id == 0) {
                timeout_id = Timeout.add_seconds (1, update_position);
            }
        }

        private void remove_timeout () {
            if (timeout_id != 0) {
                Source.remove (timeout_id);
                timeout_id = 0;
            }
        }
        private void controls_state (int state) {
            switch (state) {
                case PlaybackState.STOPPED:
                    welcompage.dlnaaction.playing = false;
                    welcompage.dlnaaction.stop_revealer.set_reveal_child (false);
                    remove_timeout ();
                    break;
                case PlaybackState.PAUSED:
                    welcompage.dlnaaction.playing = false;
                    welcompage.dlnaaction.stop_revealer.set_reveal_child (true);
                    remove_timeout ();
                    update_position ();
                    break;
                case PlaybackState.PLAYING:
                    welcompage.dlnaaction.playing = true;
                    welcompage.dlnaaction.stop_revealer.set_reveal_child (true);
                    add_timeout ();
                    break;
                case PlaybackState.TRANSITIONING:
                    remove_timeout ();
                    break;
               case PlaybackState.UNKNOWN:
                    remove_timeout ();
                    break;
            }
        }
        private void rendering_cb (GUPnP.ServiceProxy rendering_control, GUPnP.ServiceProxyAction action) {
            try {
                if (rendering_control.end_action (action)) {}
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }
        private void muted_control () {
            if (get_selected_device ()) {
                return;
            }
            GUPnP.ServiceProxy rendering_control;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            liststore.get (iter, DlnaComboColumns.SERVICERENDER, out rendering_control);
            var in_names = new GLib.List <string> ();
            in_names.append ("InstanceID");
            in_names.append ("Channel");
            in_names.append ("DesiredMute");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (0);
            in_values.append (valueinst);
            Value valuecann = Value (Type.STRING);
            valuecann.set_string ("Master");
            in_values.append (valuecann);
            Value valuedesired = Value (Type.BOOLEAN);
            valuedesired.set_boolean (NikiApp.settings.get_boolean ("dlna-muted"));
            in_values.append (valuedesired);
            rendering_control.begin_action_list ("SetMute", in_names, in_values, rendering_cb);
        }
        private void volume_changed () {
            if (get_selected_device ()) {
                return;
            }
            GUPnP.ServiceProxy rendering_control;
            Gtk.TreeIter iter;
            if (!get_active_iter (out iter)) {
                return;
            }
            liststore.get (iter, DlnaComboColumns.SERVICERENDER, out rendering_control);
            var in_names = new GLib.List <string> ();
            in_names.append ("InstanceID");
            in_names.append ("Channel");
            in_names.append ("DesiredVolume");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueinst = Value (Type.UINT);
            valueinst.set_uint (0);
            in_values.append (valueinst);
            Value valuecann = Value (Type.STRING);
            valuecann.set_string ("Master");
            in_values.append (valuecann);
            Value valuedesired = Value (Type.UINT);
            valuedesired.set_uint ((uint)NikiApp.settings.get_int ("dlna-volume"));
            in_values.append (valuedesired);
            rendering_control.begin_action_list ("SetVolume", in_names, in_values, rendering_cb);
        }
    }
}
