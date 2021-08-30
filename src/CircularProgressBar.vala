namespace Niki {
    public class CircularProgressBar : Gtk.DrawingArea {
        public bool center_filled = false;
        public bool radius_filled = false;

        private int _count_file;
        public int count_file {
            get {
                return _count_file;
            }
            set {
                queue_draw ();
                _count_file = value;
            }
        }
        private int _total_file;
        public int total_file {
            get {
                return _total_file;
            }
            set {
                _total_file = value;
            }
        }
        private double _percentage = 0;
        public double percentage {
            get {
                return _percentage;
            }
            set {
                if (value > 1.0) {
                    _percentage = 1.0;
                } else if (value < 0.0) {
                    _percentage = 0.0;
                } else {
                    _percentage = value;
                }
            }
        }

        construct {
            set_size_request (350, 350);
            draw.connect ((cr)=> {
                cr.save ();
                Gdk.RGBA color = Gdk.RGBA ();
                var center_x = get_allocated_width () / 2;
                var center_y = get_allocated_height () / 2;
                var radius = calculate_radius ();
                int line_width = 15;
                var d = radius - line_width;
                int delta = radius - line_width / 2;
                if (d < 0) {
                    delta = 0;
                    line_width = radius;
                }
                Cairo.LineCap line_cap = Cairo.LineCap.BUTT;
                color = Gdk.RGBA ();
                cr.set_line_cap (line_cap);
                cr.set_line_width (line_width);

                if (center_filled == true) {
                    cr.arc (center_x, center_y, delta, 0, 2 * Math.PI);
                    color.parse ("#adadad");
                    Gdk.cairo_set_source_rgba (cr, color);
                    cr.fill ();
                }

                if (radius_filled == true) {
                    cr.arc (center_x, center_y, delta, 0, 2 * Math.PI);
                    color.parse ("#d3d3d3");
                    Gdk.cairo_set_source_rgba (cr, color);
                    cr.stroke ();
                }

                var progress = ((double) percentage);
                if (progress > 0) {
                    cr.arc (center_x, center_y, delta, 1.5 * Math.PI, (1.5 + progress * 2 ) * Math.PI);
                    color.parse ("#f37329");
                    Gdk.cairo_set_source_rgba (cr, color);
                    cr.stroke ();
                }

                var context = get_style_context ();
                context.save ();
                context.add_class (Gtk.STYLE_CLASS_TROUGH);
                color = context.get_color (context.get_state ());
                Gdk.cairo_set_source_rgba (cr, color);

                Pango.Layout layout = Pango.cairo_create_layout (cr);
                layout.set_text (@"$(count_file)/$(total_file)", -1);
                Pango.FontDescription desc = Pango.FontDescription.from_string ("Bitstream Vera Sans 24");
                layout.set_font_description (desc);
                Pango.cairo_update_layout (cr, layout);
                int w, h;
                layout.get_size (out w, out h);
                cr.move_to (center_x - ((w / Pango.SCALE) / 2), center_y - 27 );
                Pango.cairo_show_layout (cr, layout);

                layout.set_text (_("Loading Files"), -1);
                desc = Pango.FontDescription.from_string ("Bitstream Vera Sans 14");
                layout.set_font_description (desc);
                Pango.cairo_update_layout (cr, layout);
                layout.get_size (out w, out h);
                cr.move_to (center_x - ((w / Pango.SCALE) / 2), center_y + 13);
                Pango.cairo_show_layout (cr, layout);

                context.restore ();
                cr.restore ();
                return Gdk.EVENT_STOP;
            });
        }

        private int calculate_radius () {
            return (int) double.min (get_allocated_width () / 2, get_allocated_height () / 2) - 1;
        }
    }
}
