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
    public class DeviceMonitor : Gtk.Stack {
        public Gtk.ListStore liststore;
        public Welcome devibut;
        private Gst.DeviceMonitor monitor;

        construct {
            liststore = new Gtk.ListStore (DeviceColumns.N_COLUMNS, typeof (string), typeof (string), typeof (Gtk.ListStore), typeof (string));
            devibut = new Welcome ();
            devibut.valign = Gtk.Align.CENTER;
            devibut.activated.connect ((index) => {
		        NikiApp.window.main_stack.visible_child_name = "camera";
		        NikiApp.window.camera_page.cameraplayer.video_source (get_device (index));
		        NikiApp.window.camera_page.cameratopbar.menu_res (get_model (index));
		        NikiApp.window.camera_page.ready_play ();
            });
            monitor = new Gst.DeviceMonitor ();
            Gst.Bus bus = monitor.get_bus ();
            bus.add_signal_watch ();
            bus.message.connect (bus_msg_handler);
            monitor.set_show_all_devices (true);
            monitor.get_devices ().foreach (device_added);
            var title_label = new Gtk.Label (_("No Device"));
            title_label.justify = Gtk.Justification.CENTER;
            title_label.hexpand = true;
            title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

            var subtitle_label = new Gtk.Label (_("Plug And Play"));
            subtitle_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            subtitle_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            subtitle_label.justify = Gtk.Justification.CENTER;
            subtitle_label.hexpand = true;
            subtitle_label.wrap = true;
            subtitle_label.wrap_mode = Pango.WrapMode.WORD;
            subtitle_label.margin_bottom = 10;
            var image_menu = new Gtk.Image ();
            image_menu.set_from_pixbuf (align_and_scale_pixbuf (from_theme_icon ("face-sad-symbolic", 128, 128), 128));
            var not_found = new Gtk.Grid ();
            not_found.orientation = Gtk.Orientation.VERTICAL;
            not_found.valign = Gtk.Align.CENTER;
            not_found.add (title_label);
            not_found.add (subtitle_label);
            not_found.add (image_menu);
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            homogeneous = false;
            transition_duration = 500;
            add_named (not_found, "not_found");
            add_named (devibut, "devibut");
        }
        public void start_init () {
            if (!monitor.start ()) {
                notify_app (_("Niki Camera"), _("Failed Device Monitor"));
            }
            monitor.get_devices ().foreach (device_added);
            devibut.show_all ();
        }
        private Gtk.ListStore get_model (int index) {
            Gtk.ListStore model;
            Gtk.TreeIter iter;
            liststore.get_iter_from_string (out iter, index.to_string ());
            liststore.get (iter, DeviceColumns.RESOLUTION, out model);
            return model;
        }
        private string? get_device (int index) {
            Gtk.TreeIter iter;
            string device_name;
            liststore.get_iter_from_string (out iter, index.to_string ());
            liststore.get (iter, DeviceColumns.DEVICEPATH, out device_name);
            return device_name;
        }

        private void device_added (Gst.Device device) {
            string device_class = device.get_device_class ();
            if (devibut.get_item () < 0) {
                visible_child_name = "not_found";
            }
            if (device_class != "Video/Source") {
                return;
            }
            string name = device.get_display_name ();
            bool exist = false;
            liststore.foreach ((model, path, iter) => {
                string devname;
                model.get (iter, DeviceColumns.NAME, out devname);
                if (devname == name) {
                    exist = true;
                }
                return false;
            });
            if (exist) {
                return;
            }
            Gtk.TreeIter iter;
            liststore.append (out iter);
            liststore.set (iter, DeviceColumns.NAME, name, DeviceColumns.CLASS, device_class);
            Gst.Caps caps = device.get_caps ();
            uint size = 0;
            if (caps != null) {
                size = caps.get_size ();
            }
            var restore = new Gtk.ListStore (ColumnResolution.N_COLUMNS, typeof (Icon), typeof (string), typeof (int), typeof (int));
            restore.clear ();
            for (uint i = 0; i < size; ++i) {
                unowned Gst.Structure structure = caps.get_structure (i);
                if (structure.get_name () == "video/x-raw") {
                    Gtk.TreeIter reiter;
                    restore.append (out reiter);
                    int width, height;
                    structure.get_int ("width", out width);
                    structure.get_int ("height", out height);
                    string label_reso = @"$(name) $(width) x $(height)";
                    restore.foreach ((model, path, iter) => {
                        string names;
                        model.get (iter, ColumnResolution.NAME, out names);
                            if (names == label_reso) {
                                restore.remove (ref iter);
                            }
                        return false;
                    });
                    restore.set (reiter, ColumnResolution.ICON, new ThemedIcon ("preferences-desktop-display-symbolic"), ColumnResolution.NAME, label_reso, ColumnResolution.WIDTH, width, ColumnResolution.HEIGHT, height);
                }
            }
            liststore.set (iter, DeviceColumns.RESOLUTION, restore);
            Gst.Structure props = device.get_properties ();
            string device_path = "";
            if (props != null) {
                props.foreach ((field_id, value)=> {
                    if (field_id.to_string () == "device.path") {
                        device_path = Gst.Value.serialize (value);
                        liststore.set (iter, DeviceColumns.DEVICEPATH, device_path);
                    }
                    return true;
                });
            }
            devibut.append ("camera-web", name, @"$(device_class) $(device_path)");
            visible_child = devibut;
        }
        private void device_removed (Gst.Device device) {
            string name = device.get_display_name ();
            Gtk.TreeIter iter;
            for (int i = 0; liststore.get_iter_from_string (out iter, i.to_string ()); ++i) {
                if (!liststore.iter_is_valid (iter)) {
                    return;
                }
                string devname;
                liststore.get (iter, DeviceColumns.NAME, out devname);
                if (devname == name) {
                    liststore.remove (ref iter);
                    devibut.remove_item (i);
                }
            }
            if (devibut.get_item () < 0) {
                visible_child_name = "not_found";
            }
        }
        private void bus_msg_handler (Gst.Bus bus, Gst.Message msg) {
            Gst.Device device;
            switch (msg.type) {
                case Gst.MessageType.DEVICE_ADDED:
                    msg.parse_device_added (out device);
                    device_added (device);
                    break;
                case Gst.MessageType.DEVICE_REMOVED:
                    msg.parse_device_removed (out device);
                    device_removed (device);
                    break;
            }
        }
    }
}
