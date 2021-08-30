/*-
 * Copyright (c) 2016 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

[DBus (name = "org.freedesktop.ScreenSaver")]
public interface ScreenSaverIface : Object {
    public abstract uint32 inhibit (string app_name, string reason) throws Error;
    public abstract void un_inhibit (uint32 cookie) throws Error;
}

namespace Niki {
    public class Inhibitor : Object {
        private uint32? inhibit_cookie;
        private ScreenSaverIface? screensaver_iface = null;
        private bool inhibited = false;
        private bool nointerface = false;

        construct {
            try {
                screensaver_iface = Bus.get_proxy_sync (BusType.SESSION, "org.freedesktop.ScreenSaver", "/ScreenSaver", DBusProxyFlags.NONE);
            } catch (Error e) {
                nointerface = true;
                warning ("Could not start screensaver interface: %s", e.message);
            }
        }

        public void inhibit () {
            if (nointerface) {
                return;
            }
            if (screensaver_iface != null && !inhibited) {
                try {
                    inhibited = true;
                    inhibit_cookie = screensaver_iface.inhibit (NikiApp.instance.application_id, "Playing movie");
                } catch (Error e) {
                    nointerface = true;
                    warning ("Could not inhibit screen: %s", e.message);
                }
            }
        }

        public void uninhibit () {
            if (nointerface) {
                return;
            }
            if (screensaver_iface != null && inhibited) {
                try {
                    inhibited = false;
                    screensaver_iface.un_inhibit (inhibit_cookie);
                } catch (Error e) {
                    nointerface = true;
                    warning ("Could not uninhibit screen: %s", e.message);
                }
            }
        }
    }
}
