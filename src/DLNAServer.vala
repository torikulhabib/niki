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
            content_directory.begin_action ("Browse", on_browse, "ObjectID", Type.STRING, container_id, "BrowseFlag", Type.STRING, "BrowseDirectChildren", "Filter", Type.STRING, "@childCount", "StartingIndex", Type.UINT, 0, "RequestedCount", Type.UINT, 0, "SortCriteria", Type.STRING, "");
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
            content_directory.begin_action("Browse", on_browse_metadata, "ObjectID", Type.STRING, id, "BrowseFlag", Type.STRING, "BrowseMetadata", "Filter", Type.STRING, "*", "StartingIndex", Type.UINT, 0, "RequestedCount", Type.UINT, 0, "SortCriteria", Type.STRING, "");
        }

        public void search_async (string container_id, string search_criteria, string filter, uint32 starting_index, uint32 requested_count) {
            content_directory.begin_action ("Search", on_browse, "ContainerID", Type.STRING, container_id, "SearchCriteria", Type.STRING, search_criteria, "Filter", Type.STRING, "*", "StartingIndex", Type.UINT, starting_index, "RequestedCount", Type.UINT, requested_count, "SortCriteria", Type.STRING, "");
        }
    }
}
