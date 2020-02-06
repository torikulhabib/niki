namespace niki {
    public class DLNAServer : Object {
        public GUPnP.ServiceProxy content_directory;
        public signal void browse_finish (string didl_xml);
        public signal void browse_metadata_finish (string container_id);

        public GUPnP.ServiceProxy get_content_directory (GUPnP.DeviceInfo infoproxy) {
            GUPnP.ServiceInfo info = infoproxy.get_service ("urn:schemas-upnp-org:service:ContentDirectory");
            content_directory = ((GUPnP.ServiceProxy)info);
            return content_directory;
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
 
        public void browse_async (string container_id) {
            content_directory.begin_action ("Browse", on_browse, "ObjectID", Type.STRING, container_id, "BrowseFlag", Type.STRING, "BrowseDirectChildren", "Filter", Type.STRING, "@childCount", "StartingIndex", Type.UINT, 0, "RequestedCount", Type.UINT, 0, "SortCriteria", Type.STRING, "");
        }

        public void on_browse_metadata (GUPnP.ServiceProxy content_dir, GUPnP.ServiceProxyAction action) {
            string didl_xml;
            try {
                if (content_dir.end_action (action, "Result", Type.STRING, out didl_xml)) {
                    browse_metadata_finish (didl_xml);
                }
	        } catch (Error e) {
                GLib.warning (e.message);
	        }
        }
        public void browse_metadata_async (string id) {
            content_directory.begin_action("Browse", on_browse_metadata, "ObjectID", Type.STRING, id, "BrowseFlag", Type.STRING, "BrowseMetadata", "Filter", Type.STRING, "*", "StartingIndex", Type.UINT, 0, "RequestedCount", Type.UINT, 0, "SortCriteria", Type.STRING, "");
        }

        public void search_async (string container_id, string search_criteria, string filter, uint32 starting_index, uint32 requested_count) {
            content_directory.begin_action ("Search", on_browse, "ContainerID", Type.STRING, container_id, "SearchCriteria", Type.STRING, search_criteria, "Filter", Type.STRING, "*", "StartingIndex", Type.UINT, starting_index, "RequestedCount", Type.UINT, requested_count, "SortCriteria", Type.STRING, "");
        }
    }
}
