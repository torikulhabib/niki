/*
* Copyright (c) 2019 elementary, Inc. (https://elementary.io)
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
*/

/**
 * AccelLabel is meant to be used as a {@link Gtk.MenuItem} child for displaying
 * a {@link GLib.Action}'s accelerator alongside the Menu Item label.
 *
 * The class itself is similar to it's Gtk equivalent {@link Gtk.AccelLabel}
 * but follows elementary OS design conventions. Specifically, this class uses
 * {@link Granite.accel_to_string} for accelerator string parsing.
 *
 * ''Example''<<BR>>
 * {{{
 *   var copy_menuitem = new Gtk.MenuItem ();
 *   copy_menuitem.set_action_name (ACTION_PREFIX + ACTION_COPY);
 *   copy_menuitem.add (new Granite.AccelLabel.from_action_name (_("Copy"), copy_menuitem.action_name));
 * }}}
 *
 */
namespace Niki {
    public class AccelLabel : Gtk.Grid {
        public string action_name { get; construct set; }
        public string? accel_string { get; construct set; }
        public string label { get; construct set; }

        public AccelLabel (string label, string? accel_string = null) {
            Object (
                label: label,
                accel_string: accel_string,
                column_spacing: 3
            );
        }

        construct {
            var label = new Gtk.Label (label) {
                hexpand = true,
                margin_end = 6,
                xalign = 0
            };
            add (label);
            update_accels ();
            notify["accel-string"].connect (update_accels);
            notify["action-name"].connect (update_accels);
            bind_property ("label", label, "label");
        }

        private void update_accels () {
            GLib.List<unowned Gtk.Widget> list = get_children ();
            for (int i = 0; i < list.length () - 1; i++) {
                list.nth_data (i).destroy ();
            }

            string[] accels = {""};
            if (accel_string != null && accel_string != "") {
                accels = accel_to_string (accel_string).split (" + ");
            } else if (action_name != null && action_name != "") {
                accel_string = ((Gtk.Application) GLib.Application.get_default ()).get_accels_for_action (action_name)[0];
            }

            if (accels[0] != "") {
                foreach (unowned string accel in accels) {
                    if (accel == "") {
                        continue;
                    }
                    var accel_label = new Gtk.Label (accel);
                    var accel_label_context = accel_label.get_style_context ();
                    accel_label_context.add_class ("keycap");
                    add (accel_label);
                }
            }
            show_all ();
        }

        public static string accel_to_string (string? accel) {
            if (accel == null) {
                return "";
            }
            uint accel_key;
            Gdk.ModifierType accel_mods;
            Gtk.accelerator_parse (accel, out accel_key, out accel_mods);

            string[] arr = {};
            if (Gdk.ModifierType.SUPER_MASK in accel_mods) {
                arr += "⌘";
            }

            if (Gdk.ModifierType.SHIFT_MASK in accel_mods) {
                arr += _("Shift");
            }

            if (Gdk.ModifierType.CONTROL_MASK in accel_mods) {
                arr += _("Ctrl");
            }

            if (Gdk.ModifierType.MOD1_MASK in accel_mods) {
                arr += _("Alt");
            }

            switch (accel_key) {
                case Gdk.Key.Up:
                    arr += "↑";
                    break;
                case Gdk.Key.Down:
                    arr += "↓";
                    break;
                case Gdk.Key.Left:
                    arr += "←";
                    break;
                case Gdk.Key.Right:
                    arr += "→";
                    break;
                case Gdk.Key.Alt_L:
                    arr += _("Left Alt");
                    break;
                case Gdk.Key.Alt_R:
                    arr += _("Right Alt");
                    break;
                case Gdk.Key.minus:
                case Gdk.Key.KP_Subtract:
                    arr += _("Minus");
                    break;
                case Gdk.Key.KP_Add:
                case Gdk.Key.plus:
                    arr += _("Plus");
                    break;
                case Gdk.Key.KP_Equal:
                case Gdk.Key.equal:
                    arr += _("Equals");
                    break;
                case Gdk.Key.Return:
                    arr += _("Enter");
                    break;
                case Gdk.Key.Shift_L:
                    arr += _("Left Shift");
                    break;
                case Gdk.Key.Shift_R:
                    arr += _("Right Shift");
                    break;
                default:
                    arr += Gtk.accelerator_get_label (accel_key, 0);
                    break;
            }
            return string.joinv (" + ", arr);
        }
    }
}
