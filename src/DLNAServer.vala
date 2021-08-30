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
    public class DLNAServer : Object {
        private GUPnP.ServiceProxy content_directory;
        public signal void browse_finish (string didl_xml);
        public signal void browse_metadata_finish (string container_id);

        public GUPnP.ServiceProxy get_content_directory (GUPnP.DeviceInfo infoproxy) {
            GUPnP.ServiceInfo info = infoproxy.get_service ("urn:schemas-upnp-org:service:ContentDirectory");
            return content_directory = ((GUPnP.ServiceProxy)info);
        }

        private void on_browse (GUPnP.ServiceProxy content_dir, GUPnP.ServiceProxyAction action) {
            string didl_xml;
            try {
                if (content_dir.end_action (action, "Result", Type.STRING, out didl_xml)) {
                    browse_finish (didl_xml);
                }
            } catch (Error e) {
                GLib.warning (e.message);
            }
        }

        public void browse (string container_id) {
            var in_names = new GLib.List <string> ();
            in_names.append ("ObjectID");
            in_names.append ("BrowseFlag");
            in_names.append ("Filter");
            in_names.append ("StartingIndex");
            in_names.append ("RequestedCount");
            in_names.append ("SortCriteria");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueid = Value (Type.STRING);
            valueid.set_string (container_id);
            in_values.append (valueid);
            Value valuemet = Value (Type.STRING);
            valuemet.set_string ("BrowseDirectChildren");
            in_values.append (valuemet);
            Value valuefil = Value (Type.STRING);
            valuefil.set_string ("@childCount");
            in_values.append (valuefil);
            Value valuestart = Value (Type.UINT);
            valuestart.set_uint (0);
            in_values.append (valuestart);
            Value valuereq = Value (Type.UINT);
            valuereq.set_uint (0);
            in_values.append (valuestart);
            Value valuesort = Value (Type.STRING);
            valuesort.set_string ("");
            in_values.append (valuesort);
            content_directory.begin_action_list ("Browse", in_names, in_values, on_browse);
        }

        private void on_browse_metadata (GUPnP.ServiceProxy content_dir, GUPnP.ServiceProxyAction action) {
            string didl_xml;
            try {
                if (content_dir.end_action (action, "Result", Type.STRING, out didl_xml)) {
                    browse_metadata_finish (didl_xml);
                }
            } catch (Error e) {
                GLib.warning (e.message);
            }
        }
        public void browse_metadata (string id) {
            var in_names = new GLib.List <string> ();
            in_names.append ("ObjectID");
            in_names.append ("BrowseFlag");
            in_names.append ("Filter");
            in_names.append ("StartingIndex");
            in_names.append ("RequestedCount");
            in_names.append ("SortCriteria");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueid = Value (Type.STRING);
            valueid.set_string (id);
            in_values.append (valueid);
            Value valuemet = Value (Type.STRING);
            valuemet.set_string ("BrowseMetadata");
            in_values.append (valuemet);
            Value valuefil = Value (Type.STRING);
            valuefil.set_string ("*");
            in_values.append (valuefil);
            Value valuestart = Value (Type.UINT);
            valuestart.set_uint (0);
            in_values.append (valuestart);
            Value valuereq = Value (Type.UINT);
            valuereq.set_uint (0);
            in_values.append (valuestart);
            Value valuesort = Value (Type.STRING);
            valuesort.set_string ("");
            in_values.append (valuesort);
            content_directory.begin_action_list ("Browse", in_names, in_values, on_browse_metadata);
        }

        public void search_async (string container_id, string search_criteria, string filter, uint32 starting_index, uint32 requested_count) {
            var in_names = new GLib.List <string> ();
            in_names.append ("ContainerID");
            in_names.append ("SearchCriteria");
            in_names.append ("Filter");
            in_names.append ("StartingIndex");
            in_names.append ("RequestedCount");
            in_names.append ("SortCriteria");
            var in_values = new GLib.List<GLib.Value?> ();
            Value valueid = Value (Type.STRING);
            valueid.set_string (container_id);
            in_values.append (valueid);
            Value valuemet = Value (Type.STRING);
            valuemet.set_string (search_criteria);
            in_values.append (valuemet);
            Value valuefil = Value (Type.STRING);
            valuefil.set_string ("*");
            in_values.append (valuefil);
            Value valuestart = Value (Type.UINT);
            valuestart.set_uint (starting_index);
            in_values.append (valuestart);
            Value valuereq = Value (Type.UINT);
            valuereq.set_uint (requested_count);
            in_values.append (valuestart);
            Value valuesort = Value (Type.STRING);
            valuesort.set_string ("");
            in_values.append (valuesort);
            content_directory.begin_action_list ("Search", in_names, in_values, on_browse);
        }
    }
}
