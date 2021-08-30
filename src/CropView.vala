/*
* Copyright (c) 2014-2017 elementary LLC. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
* Authored by: Tom Beckmann
*              Marvin Beckers <beckersmarvin@gmail.com>
*/

namespace Niki {
    public class CropView : Gtk.EventBox {
        public signal void area_changed ();
        private Gdk.Pixbuf _pixbuf;
        public Gdk.Pixbuf pixbuf {
            get {
                return _pixbuf;
            }
            set {
                _pixbuf = value;
                queue_draw ();
            }
        }

        private Gdk.CursorType current_operation = Gdk.CursorType.ARROW;
        private Gdk.Rectangle area;
        public bool quadratic_selection = false;
        public bool handles_visible = true;
        private double current_scale;
        private int[,] pos = {
            { 0, 0 },
            { 0, 0 },
            { 0, 0 },
            { 0, 0 },
            { 0, 0 },
            { 0, 0 },
            { 0, 0 },
            { 0, 0 }
        };

        private int temp_x = 0;
        private int temp_y = 0;
        private int offset_x = 0;
        private int offset_y = 0;
        private int r = 12;

        construct {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            bool mouse_button_down = false;
            button_press_event.connect ((event)=> {
                mouse_button_down = true;
                temp_x = (int) event.x;
                temp_y = (int) event.y;
                return Gdk.EVENT_PROPAGATE;
            });

            button_release_event.connect ((event)=> {
                current_operation = Gdk.CursorType.ARROW;
                mouse_button_down = false;
                apply_cursor ();
                return Gdk.EVENT_PROPAGATE;
            });

            motion_notify_event.connect ((event)=> {
                if (!mouse_button_down) {
                    bool determined_cursortype = false;
                    Gdk.CursorType[] cursor = {
                        Gdk.CursorType.TOP_LEFT_CORNER,
                        Gdk.CursorType.TOP_SIDE,
                        Gdk.CursorType.TOP_RIGHT_CORNER,
                        Gdk.CursorType.RIGHT_SIDE,
                        Gdk.CursorType.BOTTOM_RIGHT_CORNER,
                        Gdk.CursorType.BOTTOM_SIDE,
                        Gdk.CursorType.BOTTOM_LEFT_CORNER,
                        Gdk.CursorType.LEFT_SIDE
                    };

                    for (var i = 0; i < 8; i++) {
                        if (in_quad (pos[i, 0] - r, pos[i, 1] - r, r * 2, r * 2, (int) event.x, (int) event.y)) {
                            current_operation = cursor[i];
                            determined_cursortype = true;
                            break;
                        }
                    }

                    if (!determined_cursortype) {
                        if (in_quad ((int) Math.floor (area.x * current_scale),
                                     (int) Math.floor (area.y * current_scale),
                                     (int) Math.floor (area.width * current_scale),
                                     (int) Math.floor (area.height * current_scale),
                                     (int) (event.x - offset_x), (int) (event.y - offset_y))) {
                            current_operation = Gdk.CursorType.FLEUR;
                        } else {
                            current_operation = Gdk.CursorType.ARROW;
                        }
                    }
                    apply_cursor ();
                    return true;
                } else {
                    switch (current_operation) {
                        case Gdk.CursorType.FLEUR:
                            int motion_x = (int) (area.x + ((int) event.x - temp_x) / current_scale);
                            int motion_y = (int) (area.y + ((int) event.y - temp_y) / current_scale);
                            switch (x_in_pixbuf (motion_x)) {
                                case 0:
                                    area.x = motion_x;
                                    area_changed ();
                                    break;
                                case 1:
                                    area.x = 0;
                                    break;
                                case 2:
                                    area.x = _pixbuf.get_width () - area.width;
                                    break;
                            }

                            switch (y_in_pixbuf (motion_y)) {
                                case 0:
                                    area.y = motion_y;
                                    area_changed ();
                                    break;
                                case 1:
                                    area.y = 0;
                                    break;
                                case 2:
                                    area.y = _pixbuf.get_height () - area.height;
                                    break;
                            }
                            break;
                        case Gdk.CursorType.TOP_RIGHT_CORNER:
                        case Gdk.CursorType.TOP_LEFT_CORNER:
                            int motion_width = 0;
                            int motion_height = 0;
                            if (current_operation == Gdk.CursorType.TOP_RIGHT_CORNER) {
                                motion_width = (int) (area.width + ((int) event.x - temp_x) / current_scale);
                                motion_height = (int) (area.height - ((int) event.y - temp_y) / current_scale);
                            } else {
                                motion_width = (int) (area.width - ((int) event.x - temp_x) / current_scale);
                                motion_height = (int) (area.height - ((int) event.y - temp_y) / current_scale);
                            }

                            if (quadratic_selection && motion_width >= motion_height) {
                                motion_height = motion_width;
                            } else if (quadratic_selection && motion_width < motion_height) {
                                motion_width = motion_height;
                            }

                            switch (width_in_pixbuf (motion_width, area.x)) {
                                case 0:
                                    if (height_in_pixbuf (motion_height, area.y) == 0) {
                                        area.width = motion_width;
                                        area.height = motion_height;
                                        area_changed ();
                                    }
                                    break;
                                case 1:
                                    area.width = 0;
                                    break;
                                case 2:
                                    area.width = _pixbuf.get_width () - area.x;
                                    break;
                            }

                            switch (height_in_pixbuf (motion_height, area.y)) {
                                case 0:
                                    if (width_in_pixbuf (motion_width, area.x) == 0) {
                                        area.height = motion_height;
                                        area.width = motion_width;
                                        area_changed ();
                                    }
                                    break;
                                case 1:
                                    area.height = 0;
                                    break;
                                case 2:
                                    area.height = _pixbuf.get_height () - area.y;
                                    break;
                            }
                            break;
                        case Gdk.CursorType.BOTTOM_RIGHT_CORNER:
                        case Gdk.CursorType.BOTTOM_LEFT_CORNER:
                            int motion_width = 0;
                            int motion_height = 0;
                            if (current_operation == Gdk.CursorType.BOTTOM_RIGHT_CORNER) {
                                motion_width = (int) (area.width + ((int) event.x - temp_x) / current_scale);
                                motion_height = (int) (area.height + ((int) event.y - temp_y) / current_scale);
                            } else {
                                motion_width = (int) (area.width - ((int) event.x - temp_x) / current_scale);
                                motion_height = (int) (area.height + ((int) event.y - temp_y) / current_scale);
                            }

                            if (quadratic_selection && motion_width >= motion_height) {
                                motion_height = motion_width;
                            } else if (quadratic_selection && motion_width < motion_height) {
                                motion_width = motion_height;
                            }

                            switch (width_in_pixbuf (motion_width, area.x)) {
                                case 0:
                                    if (height_in_pixbuf (motion_height, area.y) == 0) {
                                        area.width = motion_width;
                                        area.height = motion_height;
                                        area_changed ();
                                    }
                                    break;
                                case 1:
                                    area.width = 0;
                                    break;
                                case 2:
                                    area.width = _pixbuf.get_width () - area.x;
                                    break;
                            }

                            switch (height_in_pixbuf (motion_height, area.y)) {
                                case 0:
                                    if (width_in_pixbuf (motion_width, area.x) == 0) {
                                        area.height = motion_height;
                                        area.width = motion_width;
                                        area_changed ();
                                    }
                                    break;
                                case 1:
                                    area.height = 0;
                                    break;
                                case 2:
                                    area.height = _pixbuf.get_height () - area.y;
                                    break;
                            }
                            break;
                        case Gdk.CursorType.TOP_SIDE:
                        case Gdk.CursorType.BOTTOM_SIDE:
                            int motion_height = 0;
                            if (current_operation == Gdk.CursorType.BOTTOM_SIDE) {
                                motion_height = (int) (area.height + ((int) event.y - temp_y) / current_scale);
                            } else {
                                motion_height = (int) (area.height - ((int) event.y - temp_y) / current_scale);
                            }
                            if (!quadratic_selection) {
                                switch (height_in_pixbuf (motion_height, area.y)) {
                                    case 0:
                                        area.height = motion_height;
                                        area_changed ();
                                        break;
                                    case 1:
                                        area.height = 0;
                                        break;
                                    case 2:
                                        area.height = _pixbuf.get_height () - area.y;
                                        break;
                                }
                            } else {
                                switch (height_in_pixbuf (motion_height, area.y)) {
                                    case 0:
                                        area.width = motion_height;
                                        area.height = motion_height;
                                        area_changed ();
                                        break;
                                    case 1:
                                        area.width = 0;
                                        area.height = 0;
                                        break;
                                    case 2:
                                        area.width = _pixbuf.get_width () - area.x;
                                        area.height = _pixbuf.get_height () - area.y;
                                        break;
                                }
                            }
                            break;
                        case Gdk.CursorType.RIGHT_SIDE:
                        case Gdk.CursorType.LEFT_SIDE:
                            int motion_width = 0;
                            if (current_operation == Gdk.CursorType.RIGHT_SIDE) {
                                motion_width = (int) (area.width + ((int) event.x - temp_x) / current_scale);
                            } else {
                                motion_width = (int) (area.width - ((int) event.x - temp_x) / current_scale);
                            }
                            if (!quadratic_selection) {
                                switch (width_in_pixbuf (motion_width, area.x)) {
                                    case 0:
                                        area.width = motion_width;
                                        area_changed ();
                                        break;
                                    case 1:
                                        area.width = 0;
                                        break;
                                    case 2:
                                        area.width = _pixbuf.get_width () - area.x;
                                        break;
                                }
                            } else {
                                switch (width_in_pixbuf (motion_width, area.x)) {
                                    case 0:
                                        area.width = motion_width;
                                        area.height = motion_width;
                                        area_changed ();
                                        break;
                                    case 1:
                                        area.width = 0;
                                        area.height = 0;
                                        break;
                                    case 2:
                                        area.width = _pixbuf.get_width () - area.x;
                                        area.height = _pixbuf.get_height () - area.y;
                                        break;
                                }
                            }
                            break;
                    }

                    if (area.width != area.height) {
                        var smallest = area.width > area.height ? area.height : area.width;
                        area.width = smallest;
                        area.height = smallest;
                    }
                    temp_x = (int) event.x;
                    temp_y = (int) event.y;
                    queue_draw ();
                }
                return Gdk.EVENT_STOP;
            });

            draw.connect ((cr)=> {
                Gtk.Allocation alloc;
                get_allocation (out alloc);
                var pixbuf_width = _pixbuf.get_width ();
                var pixbuf_height = _pixbuf.get_height ();
                double scale = 1.0;

                if (pixbuf_width > alloc.width) {
                    scale = alloc.width / (double) pixbuf_width;
                    pixbuf_height = (int) Math.floor (scale * pixbuf_height);
                    pixbuf_width = alloc.width;
                }

                if (pixbuf_height > alloc.height) {
                    scale = alloc.height / (double) pixbuf_height;
                    pixbuf_width = (int) Math.floor (scale * pixbuf_width);
                    pixbuf_height = alloc.height;
                }

                var pixbuf = _pixbuf.scale_simple (pixbuf_width, pixbuf_height, Gdk.InterpType.BILINEAR);

                offset_x = alloc.width / 2 - pixbuf_width / 2;
                offset_y = alloc.height / 2 - pixbuf_height / 2;

                Gdk.cairo_set_source_pixbuf (cr, pixbuf, offset_x, offset_y);
                cr.paint ();

                scale = pixbuf_width / (double) _pixbuf.get_width ();

                var x = offset_x + (int) Math.floor (area.x * scale);
                var y = offset_y + (int) Math.floor (area.y * scale);
                var w = (int) Math.floor (area.width * scale);
                var h = (int) Math.floor (area.height * scale);

                pos = {
                    { x, y },
                    { x + w / 2, y },
                    { x + w, y },
                    { x + w, y + h / 2 },
                    { x + w, y + h },
                    { x + w / 2, y + h },
                    { x, y + h },
                    { x, y + h / 2 }
                };

                cr.rectangle (x, y, w, h);
                cr.set_source_rgba (0.1, 0.1, 0.1, 0.2);
                cr.fill ();

                cr.rectangle (x, y, w, h);
                cr.set_source_rgb (1.0, 1.0, 1.0);
                cr.set_line_width (1.0);
                cr.stroke ();

                if (handles_visible) {
                    for (var i = 0; i < 8; i++) {
                        cr.arc (pos[i,0], pos[i,1], r, 0.0, 2 * Math.PI);
                        cr.set_source_rgb (0.7, 0.7, 0.7);
                        cr.fill ();
                    }
                }
                current_scale = scale;
                return Gdk.EVENT_STOP;
            });
        }

        public CropView.from_pixbuf_with_size (Gdk.Pixbuf pixbuf, int x, int y, bool quadratic_selection = false) {
            this.add_events (Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.BUTTON_MOTION_MASK);
            this.pixbuf = pixbuf;
            this.quadratic_selection = quadratic_selection;

            if (pixbuf.get_width () > pixbuf.get_height ()) {
                area = { 5, 5, _pixbuf.get_height () / 2, _pixbuf.get_height () / 2 };
                double temp_scale = (double) x / (double) pixbuf.get_width ();
                if (pixbuf.get_height () * temp_scale < y) {
                    y = (int) (pixbuf.get_height () * temp_scale);
                }
            } else if (pixbuf.get_width () < pixbuf.get_height ()) {
                area = { 5, 5, _pixbuf.get_width () / 2, pixbuf.get_width () / 2 };
                double temp_scale = (double) y / (double) pixbuf.get_height ();
                if (pixbuf.get_width () * temp_scale < x) {
                    x = (int) (pixbuf.get_width () * temp_scale);
                }
            } else {
                area = { 5, 5, _pixbuf.get_width () / 2, pixbuf.get_height () / 2 };
            }
            set_size_request (x, y);
        }

        public Gdk.Pixbuf get_selection () {
            return new Gdk.Pixbuf.subpixbuf (_pixbuf, area.x, area.y, area.width, area.height);
        }

        private bool in_quad (int qx, int qy, int qw, int qh, int x, int y) {
            return ((x > qx) && (x < (qx + qw)) && (y > qy) && (y < qy + qh));
        }

        private void apply_cursor () {
            get_window ().cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), current_operation);
        }

        private int x_in_pixbuf (int ax) {
            if (ax < 0) {
                return 1;
            } else if (ax + area.width > _pixbuf.get_width ()) {
                return 2;
            }
            return 0;
        }

        private int y_in_pixbuf (int ay) {
            if (ay < 0) {
                return 1;
            } else if (ay + area.height > _pixbuf.get_height ()) {
                return 2;
            }
            return 0;
        }

        private int width_in_pixbuf (int aw, int ax) {
            if (aw < 0) {
                return 1;
            } else if (aw > _pixbuf.get_width () - ax) {
                return 2;
            }
            return 0;
        }

        private int height_in_pixbuf (int ah, int ay) {
            if (ah < 0) {
                return 1;
            } else if (ah > _pixbuf.get_height () - ay) {
                return 2;
            }
            return 0;
        }
    }
}
