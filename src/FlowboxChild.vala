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
    public class EffectColor : Gtk.FlowBoxChild {
        public ColorEffects coloreffects;

        public EffectColor (ColorEffects coloreffects) {
            this.coloreffects = coloreffects;
            var title = new Gtk.Label (coloreffects.get_effect ()) {
                margin_top = 6,
                margin_bottom = 6,
                margin_start = 6,
                margin_end = 12
            };

            var image_menu = new Gtk.Image () {
                margin_start = 4
            };
            image_menu.set_from_gicon (new ThemedIcon ("applications-graphics-symbolic"), Gtk.IconSize.BUTTON);
            var content = new Gtk.Grid () {
                valign = Gtk.Align.CENTER,
                row_spacing = 12
            };
            content.add (image_menu);
            content.add (title);
            add (content);
        }
    }

    public class ProfileCamera : Gtk.FlowBoxChild {
        public CameraProfile cameraprofile;

        public ProfileCamera (CameraProfile cameraprofile) {
            this.cameraprofile = cameraprofile;
            var title = new Gtk.Label (cameraprofile.get_profile ()) {
                margin_top = 6,
                margin_bottom = 6,
                margin_start = 6,
                margin_end = 12
            };
            var image_menu = new Gtk.Image () {
                margin_start = 4
            };
            image_menu.set_from_gicon (new ThemedIcon ("document-save-symbolic"), Gtk.IconSize.BUTTON);
            var content = new Gtk.Grid () {
                valign = Gtk.Align.CENTER,
                row_spacing = 12
            };
            content.add (image_menu);
            content.add (title);
            add (content);
        }
    }
}
