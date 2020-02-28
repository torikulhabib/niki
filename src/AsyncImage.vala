namespace niki {
    public class AsyncImage : Gtk.Image {
        private class CacheEntry {
            public string icon;
            public Cairo.Surface? surface;
            public int size;
            public int scale_factor;

            public CacheEntry (string icon, Cairo.Surface? surface, int size, int scale_factor) {
                this.icon = icon;
                this.surface = surface;
                this.size = size;
                this.scale_factor = scale_factor;
            }
        }

        private static Gee.ArrayList<CacheEntry> cache;
        public bool load_on_realize { construct; private get; }
        public bool auto_size_request { construct; private get; }
        public Icon? gicon_async { get; private set; default = null; }
        public int size_async { get; private set; default = -1; }
        private int current_scale_factor = 1;
        public AsyncImage (bool load_on_realize = true, bool auto_size_request = true) {
            Object (load_on_realize: load_on_realize, auto_size_request: auto_size_request);
        }

        static construct {
            cache = new Gee.ArrayList<CacheEntry> ();
        }

        construct {
            if (load_on_realize) {
                realize.connect (() => update.begin ());
            }

            style_updated.connect (() => {
                if (get_realized ()) {
                    update.begin (true);
                }
            });

            direction_changed.connect (() => update.begin (true));

            notify["scale-factor"].connect (() => {
                if (get_scale_factor () != current_scale_factor) {
                    update.begin ();
                }
            });
        }

        public async void set_from_gicon_async (Icon icon, int size, Cancellable? cancellable = null) throws Error {
            gicon_async = icon;
            size_async = size;

            if (auto_size_request) {
                set_size_request (size, size);
            }

            if (!load_on_realize) {
                try {
                    yield set_from_gicon_async_internal (gicon_async, size_async, cancellable, false);
                } catch (Error e) {
                    throw e;
                }
            }
        }

        public async void set_from_icon_name_async (string icon_name, Gtk.IconSize icon_size, Cancellable? cancellable = null) throws Error {
            int width, height;
            if (!Gtk.icon_size_lookup (icon_size, out width, out height)) {
                warning ("Invalid icon size %d", icon_size);
                return;
            }

            try {
                yield set_from_gicon_async (new ThemedIcon (icon_name), int.min (width, height), cancellable);
            } catch (Error e) {
                throw e;
            }
        }

        public async void set_from_file_async (File file, int width, int height, bool preserve_aspect_ratio, Cancellable? cancellable = null) throws Error {
            gicon_async = null;
            size_async = -1;

            if (auto_size_request) {
                set_size_request (width, height);
            }

            try {
                var stream = yield file.read_async ();
                var pixbuf = yield new Gdk.Pixbuf.from_stream_at_scale_async (stream, width * current_scale_factor, height * current_scale_factor, preserve_aspect_ratio, cancellable);
                surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, current_scale_factor, null);
                reset_size_request ();
            } catch (Error e) {
                reset_size_request ();
                throw e;
            }
        }

        private async void set_from_gicon_async_internal (Icon icon, int size, Cancellable? cancellable = null, bool bypass_cache) throws Error {
            current_scale_factor = get_scale_factor ();

            if (size == 0) {
                clear ();
                return;
            } else if (size != -1 && !bypass_cache) {
                string target_icon = icon.to_string ();
                foreach (var entry in cache) {
                    if (entry.icon == target_icon && entry.size == size && entry.scale_factor == current_scale_factor) {
                        surface = entry.surface;
                        reset_size_request ();
                        return;
                    }
                }
            }

            if (icon is FileIcon) {
                try {
                    yield set_from_file_async (((FileIcon)icon).file, size, size, true);
                } catch (Error e) {
                    throw e;
                }
                return;
            }

            var style_context = get_style_context ();
            var theme = Gtk.IconTheme.get_for_screen (style_context.get_screen ());

            var flags = Gtk.IconLookupFlags.FORCE_SIZE | Gtk.IconLookupFlags.USE_BUILTIN;
            if (Gtk.StateFlags.DIR_RTL in style_context.get_state ()) {
                flags |= Gtk.IconLookupFlags.DIR_RTL;
            } else {
                flags |= Gtk.IconLookupFlags.DIR_LTR;
            }

            var info = theme.lookup_by_gicon_for_scale (icon, size, current_scale_factor, flags);
            if (info == null) {
                reset_size_request ();
                throw new IOError.NOT_FOUND ("Failed to lookup icon \"%s\" at size %i".printf (icon.to_string (), size));
            }

            try {
                Gdk.Pixbuf pixbuf;
                if (info.is_symbolic ()) {
                    pixbuf = yield info.load_symbolic_for_context_async (style_context, cancellable);
                } else {
                    pixbuf = yield info.load_icon_async ();
                }

                surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, current_scale_factor, null);
                reset_size_request ();

                var entry = new CacheEntry (icon.to_string (), surface, size, current_scale_factor);
                cache.add (entry);
            } catch (Error e) {
                reset_size_request ();
                throw e;
            }
        }

        private async void update (bool bypass_cache = false) {
            if (gicon_async != null && (gicon_async is ThemedIcon || gicon_async is FileIcon)) {
                try {
                    yield set_from_gicon_async_internal (gicon_async, size_async, null, bypass_cache);
                } catch (Error e) {
                    warning (e.message);
                }
            }
        }

        private void reset_size_request () {
            if (auto_size_request) {
                set_size_request (-1, -1);
            }
        }
    }
}
