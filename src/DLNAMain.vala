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
    public class DLNAMain : Object {
        private WelcomePage? welcompage;
        public GUPnP.ContextManager contextmanager_media_server;
        public GUPnP.ContextManager contextmanager_media_render;
        private GUPnP.ControlPoint controlpoint_dms_cp;
        private GUPnP.ControlPoint controlpoint_dmr_cp;
        private GUPnP.WhiteList wihitelist_media_server;
        private GUPnP.WhiteList wihitelist_media_render;

        public DLNAMain (WelcomePage welcompage) {
            this.welcompage = welcompage;
            init_upnp_media_server ();
            init_upnp_media_render ();
        }

        public void dms_proxy_available_cb (GUPnP.ControlPoint controlpoint, GUPnP.DeviceProxy proxy) {
            welcompage.treview.add_media_server (proxy);
        }
        public void dmr_proxy_available_cb (GUPnP.ControlPoint controlpoint, GUPnP.DeviceProxy proxy) {
            welcompage.dlnarendercontrol.add_media_renderer (proxy);
        }
        public void dms_proxy_unavailable_cb (GUPnP.ControlPoint controlpoint, GUPnP.DeviceProxy proxy) {
            welcompage.treview.remove_media_server (proxy);
        }
        public void dmr_proxy_unavailable_cb (GUPnP.ControlPoint controlpoint, GUPnP.DeviceProxy proxy) {
            welcompage.dlnarendercontrol.remove_media_renderer (proxy);
        }

        public void init_upnp_media_server () {
            wihitelist_media_server = new GUPnP.WhiteList ();
            contextmanager_media_server = context_media_server ();
            wihitelist_media_server = contextmanager_media_server.get_white_list ();
            wihitelist_media_server.set_enabled (true);
        }

        public void init_upnp_media_render () {
            wihitelist_media_render = new GUPnP.WhiteList ();
            contextmanager_media_render = context_media_render ();
            wihitelist_media_render = contextmanager_media_render.get_white_list ();
            wihitelist_media_render.set_enabled (true);
        }

        private GUPnP.ContextManager context_media_server () {
            int port = 0;
            var manager = GUPnP.ContextManager.create (port);
            manager.context_available.connect (on_context_media_server_available);
            return manager;
        }

        private GUPnP.ContextManager context_media_render () {
            int port = 0;
            var manager = GUPnP.ContextManager.create (port);
            manager.context_available.connect (on_context_media_render_available);
            return manager;
        }

        private void on_context_media_server_available (GUPnP.ContextManager manager, GUPnP.Context context) {
            controlpoint_dms_cp = new GUPnP.ControlPoint (context, "urn:schemas-upnp-org:device:MediaServer:1");
            controlpoint_dms_cp.device_proxy_available.connect (dms_proxy_available_cb);
            controlpoint_dms_cp.device_proxy_unavailable.connect (dms_proxy_unavailable_cb);
            ((GSSDP.ResourceBrowser) controlpoint_dms_cp).set_active (true);
            manager.manage_control_point (controlpoint_dms_cp);
        }
        private void on_context_media_render_available (GUPnP.ContextManager manager, GUPnP.Context context) {
            controlpoint_dmr_cp = new GUPnP.ControlPoint (context, "urn:schemas-upnp-org:device:MediaRenderer:1");
            controlpoint_dmr_cp.device_proxy_available.connect (dmr_proxy_available_cb);
            controlpoint_dmr_cp.device_proxy_unavailable.connect (dmr_proxy_unavailable_cb);
            ((GSSDP.ResourceBrowser) controlpoint_dmr_cp).set_active (true);
            manager.manage_control_point (controlpoint_dmr_cp);
        }
    }
}
