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
    public class TittlePango : GLib.Object {
        public signal void draw_position ();
        private Clutter.Text c_text;
        private PlayerPage playerpage;
        private uint remove_time = 0;
        private int animstep = 0;
        private int state = 0;

        public TittlePango (PlayerPage playerpage, Clutter.Text c_text) {
            this.playerpage = playerpage;
            this.c_text = c_text;
            c_text.font_name = "Bitstream Vera Sans Bold 14";
            c_text.line_alignment = Pango.Alignment.CENTER;
            c_text.use_markup = true;
            c_text.color = Clutter.Color.from_string ("white");
            c_text.background_color = Clutter.Color.from_string ("black") { alpha = 100 };
            NikiApp.settings.changed["title-playing"].connect (()=>{
                if (remove_time > 0) {
                    Source.remove (remove_time);
                }
                remove_time = 0;
                animstep = 0;
                state = 0;
                remove_time = Timeout.add (50, animation_timer);
            });
            Timeout.add (50, animation_timer);
        }

        private void decorate_text (double time) {
            Pango.Attribute attr;
            Pango.AttrList attrlist = new Pango.AttrList ();
            attr = Pango.attr_letter_spacing_new ((int)((1.0 - time) * 60000));
            attrlist.change ((owned) attr);
            c_text.set_attributes (attrlist);
        }

        private bool animation_timer () {
            int timeout = 0;
            if (animstep == 0) {
                string text = null;
                switch (state) {
                    case 0:
                        remove_time = Timeout.add (50, animation_timer);
                        state += 1;
                        return false;
                    case 1:
                        text = _("Tittle");
                        state += 1;
                        break;
                    case 2:
                        text = NikiApp.settings.get_string ("title-playing");
                        state += 1;
                        break;
                    case 3:
                        remove_time = 0;
                        animstep = 0;
                        state = 0;
                        return false;
                }
                c_text.text = @" $(text.dup ()) ";
            }

            if (animstep < 16) {
                decorate_text ((animstep) / 15.0);
            } else if (animstep == 16) {
                timeout = 900;
            } else if (animstep == 17) {
                timeout = 40;
            } else if (animstep < 35) {
                if (state != 3) {
                    decorate_text (1.0 - (animstep - 17) / 15.0);
                }
            } else if (animstep == 35) {
                timeout = 300;
            } else {
                animstep = -1;
                timeout = 40;
            }
            animstep++;
            draw_position ();
            if (timeout > 0) {
                remove_time = Timeout.add (timeout, animation_timer);
                return false;
            }
            return true;
        }
    }
}
