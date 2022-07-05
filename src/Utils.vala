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
    private RepeatMode repeatmode;
    private enum RepeatMode {
        OFF = 0,
        ALL = 1,
        ONE = 2;
        public RepeatMode switch_repeat_mode () {
            switch (NikiApp.settings.get_enum ("repeat-mode")) {
                case ALL:
                    NikiApp.settings.set_enum ("repeat-mode", RepeatMode.ONE);
                    return ONE;
                case ONE:
                    NikiApp.settings.set_enum ("repeat-mode", RepeatMode.OFF);
                    return OFF;
                default:
                    NikiApp.settings.set_enum ("repeat-mode", RepeatMode.ALL);
                    return ALL;
            }
        }
    }

    private Searchentry searchentry;
    private enum Searchentry {
        TITLE = 0,
        ARTIST = 1,
        ALBUM = 2;
        public Searchentry switch_search_mode () {
            switch (NikiApp.settings.get_enum ("search-entry")) {
                case ARTIST:
                    NikiApp.settings.set_enum ("search-entry", Searchentry.ALBUM);
                    return ALBUM;
                case ALBUM:
                    NikiApp.settings.set_enum ("search-entry", Searchentry.TITLE);
                    return TITLE;
                default:
                    NikiApp.settings.set_enum ("search-entry", Searchentry.ARTIST);
                    return ARTIST;
            }
        }
    }

    private CameraDelay cameradelay;
    private enum CameraDelay {
        DISABLED = 0,
        3SEC = 3,
        5SEC = 5,
        10SEC = 10;
        public CameraDelay switch_delay () {
            switch (NikiApp.settings.get_enum ("camera-delay")) {
                case 3SEC:
                    NikiApp.settings.set_enum ("camera-delay", CameraDelay.5SEC);
                    return 5SEC;
                case 5SEC:
                    NikiApp.settings.set_enum ("camera-delay", CameraDelay.10SEC);
                    return 10SEC;
                case 10SEC:
                    NikiApp.settings.set_enum ("camera-delay", CameraDelay.DISABLED);
                    return DISABLED;
                default:
                    NikiApp.settings.set_enum ("camera-delay", CameraDelay.3SEC);
                    return 3SEC;
            }
        }
    }
    private SettingsMode settingsmode;
    private enum SettingsMode {
        EQUALIZER = 0,
        VIDEO = 1,
        OTHER = 2;
        public SettingsMode switch_next_settings_mode () {
            switch (NikiApp.settings.get_enum ("settings-mode")) {
                case VIDEO:
                    NikiApp.settings.set_enum ("settings-mode", SettingsMode.OTHER);
                    return OTHER;
                case EQUALIZER:
                    NikiApp.settings.set_enum ("settings-mode", SettingsMode.VIDEO);
                    return VIDEO;
                default:
                    NikiApp.settings.set_enum ("settings-mode", SettingsMode.EQUALIZER);
                    return EQUALIZER;
            }
        }
        public SettingsMode switch_prev_settings_mode () {
            switch (NikiApp.settings.get_enum ("settings-mode")) {
                case OTHER:
                    NikiApp.settings.set_enum ("settings-mode", SettingsMode.VIDEO);
                    return VIDEO;
                case VIDEO:
                    NikiApp.settings.set_enum ("settings-mode", SettingsMode.EQUALIZER);
                    return EQUALIZER;
                default:
                    NikiApp.settings.set_enum ("settings-mode", SettingsMode.VIDEO);
                    return VIDEO;
            }
        }
    }

    public enum CameraProfile {
        MP4 = 0,
        OGG = 1,
        WEBM = 2,
        MKV = 3;
        public string get_profile () {
            switch (this) {
                case OGG:
                    return "OGG";
                case WEBM:
                    return "WEBM";
                case MKV:
                    return "MKV";
                default:
                    return "MP4";
            }
        }
        public static CameraProfile [] get_all () {
            return { MP4, OGG, WEBM, MKV };
        }
    }

    public enum ColorEffects {
        NONE = 0,
        HEAT = 1,
        SEPIA = 2,
        XRAY = 3,
        XPRO = 4,
        YBLUE = 5;
        public string get_effect () {
            switch (this) {
                case HEAT:
                    return "Heat";
                case SEPIA:
                    return "Sepia";
                case XRAY:
                    return "Xray";
                case XPRO:
                    return "Xpro";
                case YBLUE:
                    return "Yellow Blue";
                default:
                    return "None";
            }
        }
        public static ColorEffects [] get_all () {
            return { NONE, HEAT, SEPIA, XRAY, XPRO, YBLUE };
        }
    }

    private enum PlayerMode {
        VIDEO = 0,
        AUDIO = 1,
        STREAMAUD = 2,
        STREAMVID = 3
    }

    private enum ColumnCamPre {
        FILENAME,
        TITLE,
        N_COLUMNS
    }

    private enum ColumnResolution {
        ICON,
        NAME,
        WIDTH,
        HEIGHT,
        N_COLUMNS
    }

    private enum ColumnScanF {
        FILENAME,
        N_COLUMNS
    }

    private enum Target {
        STRING,
        URILIST
    }

    private enum PlaylistColumns {
        PLAYING,
        PREVIEW,
        TITLE,
        ARTISTTITLE,
        FILENAME,
        FILESIZE,
        ALBUMMUSIC,
        ARTISTMUSIC,
        PLAYNOW,
        MEDIATYPE,
        INPUTMODE,
        N_COLUMNS
    }

    private enum MusicColumns {
        PLAYING,
        TRACK,
        TITLE,
        ARTIST,
        ALBUM,
        GENRE,
        DATE,
        FILEURI,
        N_COLUMNS
    }

    private enum DeviceColumns {
        NAME,
        CLASS,
        RESOLUTION,
        DEVICEPATH,
        N_COLUMNS
    }

    private enum ComboColumns {
        OBJECT,
        STRING,
        ICON,
        N_COLUMNS
    }

    private enum ComboIcon {
        ICON,
        STRING,
        N_COLUMNS
    }

    private enum SearchLyric {
        TITLE,
        ARTIST,
        TYPEFILE,
        LINKFILE,
        SERVER,
        N_COLUMNS
    }

    private enum LyricColumns {
        TIMEVIEW,
        LYRIC,
        N_COLUMNS
    }

    private enum DlnaComboColumns {
        PIXBUF,
        DEVICENAME,
        DEVICEPROXY,
        SERVICEAVTRANS,
        SERVICERENDER,
        N_COLUMNS
    }

    private enum DlnaTreeColumns {
        ICON,
        TITLE,
        DEVICEINFO,
        SERVICEPROXY,
        ID,
        CONTAINER,
        UPNPCLASS,
        N_COLUMNS
    }

    private enum PlaybackState {
        UNKNOWN = 0,
        TRANSITIONING = 1,
        STOPPED = 2,
        PAUSED = 3,
        PLAYING = 4
    }

    private string get_song_info (File path) {
        string output = null;
        if (get_mime_type (path).has_prefix ("video/")) {
            output = path.get_basename ();
        } else if (get_mime_type (path).has_prefix ("audio/")) {
            if (path.get_uri ().down ().has_suffix ("aac") || path.get_uri ().down ().has_suffix ("ac3")) {
                return path.get_basename ();
            }
            var info = new InyTag.File (path.get_path ());
            output = info.tag.title.char_count () < 1? path.get_basename () : info.tag.title;
        }
        return output;
    }

    private string get_artist_music (File path) {
        if (path.get_uri ().down ().has_suffix ("aac") || path.get_uri ().down ().has_suffix ("ac3")) {
            return _("Unknown");
        }
        var info = new InyTag.File (path.get_path ());
        return info.tag.artist.char_count () < 1? _("Unknown") : info.tag.artist;
    }

    private string get_album_music (File path) {
        if (path.get_uri ().down ().has_suffix ("aac") || path.get_uri ().down ().has_suffix ("ac3")) {
            return _("Unknown");
        }
        var info = new InyTag.File (path.get_path ());
        return info.tag.album.char_count () < 1? _("Unknown") : info.tag.album;
    }

    private string get_mime_type (File fileinput) {
        if (!fileinput.query_exists ()) {
            return "";
        }
        string mime_type = null;
        try {
            FileInfo infos = fileinput.query_info ("standard::*", 0);
            mime_type = infos.get_content_type ();
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return mime_type;
    }

    private int file_type (File filein) {
        if (filein.get_uri ().has_prefix ("https://cf-media.sndcdn.com")) {
            return 2;
        }
        if (filein.get_uri ().contains ("googlevideo")) {
            return 3;
        }
        if (filein.get_uri ().char_count () > 1 && filein.query_exists ()) {
            if (get_mime_type (filein).has_prefix ("video/")) {
                return 0;
            }
            if (get_mime_type (filein).has_prefix ("audio/")) {
                return 1;
            }
        }
        return -1;
    }

    private static string get_info_size (string fileinput) {
        string file_info = null;
        if (!File.new_for_uri (fileinput).query_exists ()) {
            return file_info;
        }
        try {
            FileInfo info = File.new_for_uri (fileinput).query_info ("standard::*", 0);
            file_info = " %s: %s".printf ("Size", GLib.format_size (info.get_size ()));
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return file_info;
    }

    private const string[] SUBTITLE_EXTENSIONS = {"sub", "srt", "smi", "ssa", "ass", "asc"};
    private string? get_subtitle_for_uri (string uri) {
        string without_ext;
        int last_dot = uri.last_index_of (".", 0);
        int last_slash = uri.last_index_of ("/", 0);

        if (last_dot < last_slash) {
            without_ext = uri;
        } else {
            without_ext = uri.slice (0, last_dot);
        }

        foreach (string ext in SUBTITLE_EXTENSIONS) {
            string sub_uri = @"$(without_ext).$(ext)";
            if (File.new_for_uri (sub_uri).query_exists ()) {
                return sub_uri;
            }
        }
        return null;
    }

    private bool? is_subtitle (string uri) {
        bool find_sub = false;
        int last_dot = uri.last_index_of (".", 0);

        foreach (string ext in SUBTITLE_EXTENSIONS) {
            if (uri.substring (last_dot + 1) == ext) {
                find_sub = true;
            }
        }
        return find_sub;
    }

    private string? get_playing_lyric (string uri) {
        string without_ext;
        int last_dot = uri.last_index_of (".", 0);
        int last_slash = uri.last_index_of ("/", 0);

        if (last_dot < last_slash) {
            without_ext = uri;
        } else {
            without_ext = uri.slice (0, last_dot);
        }

        string lyric_uri = without_ext + "." + "lrc";
        if (File.new_for_uri (lyric_uri).query_exists ()) {
            return lyric_uri;
        } else {
            return null;
        }
    }

    private string get_name_noext (string filename) {
        var base_name = File.new_for_uri (filename).get_basename ();
        int last_dot = base_name.last_index_of (".", 0);
        return base_name.slice (0, last_dot);
    }

    private string get_path_noname (string filename) {
        var file = File.new_for_uri (filename);
        string [] split_in = file.get_path ().split (file.get_basename ());
        return split_in [0];
    }

    private static bool file_exists (string uri) {
        if (!uri.has_prefix ("http")) {
            return File.new_for_uri (uri).query_exists ();
        } else {
            return false;
        }
    }

    private bool cursor_hand_mode (int cursor_mode) {
        Gdk.CursorType[] cursors = {
            Gdk.CursorType.HAND2,
            Gdk.CursorType.BLANK_CURSOR,
            Gdk.CursorType.ARROW,
            Gdk.CursorType.HAND1
        };
        var display = NikiApp.window.get_display ();
        var cursor = new Gdk.Cursor.for_display (display, cursors [cursor_mode]);
        NikiApp.window.get_window ().set_cursor (cursor_mode == 2? null : cursor);
        return false;
    }

    private bool return_hide_mode = false;
    private bool destroy_mode () {
        if (NikiApp.window.player_page.playback.playing && NikiApp.settings.get_boolean ("audio-video")) {
            return_hide_mode = true;
            NikiApp.window.player_page.signal_playing ();
            return NikiApp.window.hide_on_delete ();
        } else {
            NikiApp.window.player_page.save_destroy ();
            NikiApp.window.player_page.playback.dispose ();
            NikiApp.window.destroy ();
            return false;
        }
    }

    private static string seconds_to_time (int seconds, bool need = true) {
        int sign = 1;
        if (seconds < 0 && need) {
            seconds = -seconds;
            sign = -1;
        }

        int hours = seconds / 3600;
        int min = (seconds % 3600) / 60;
        int sec = (seconds % 60);

        if (hours > 0 || !need) {
            return ("%u:%02u:%02u".printf (sign * hours, min, sec));
        } else {
            return ("%02u:%02u".printf (sign * min, sec));
        }
    }

    private double seconds_from_time (string time_string) {
        string [] tokens = {};
        double seconds = -1.0;
        tokens = time_string.split (":", -1);
        if (tokens == null) {
            return -1.0;
        }

        if (tokens[2] == null) {
            seconds = double.parse (tokens[1]);
            seconds += double.parse (tokens[0]) * 60;
            return seconds;
        }
        seconds = double.parse (tokens[2]);
        seconds += double.parse (tokens[1]) * 60;
        seconds += double.parse (tokens[0]) * 3600;
        return seconds;
    }

    private int64 int_from_time (string time_string) {
        string [] tokens = {};
        tokens = time_string.replace ("[", "").replace ("]", "").split (":", -1);
        if (tokens == null) {
            return 0;
        }

        if (tokens[2] == null) {
            double seconds = double.parse (tokens[1]);
            int minutes = int.parse (tokens[0]);
            return (minutes * 60 * 1000 + (int) (seconds * 1000)) * 1000;
        }
        double second = double.parse (tokens[2]);
        int minute = int.parse (tokens[1]);
        int hours = int.parse (tokens[0]);
        return (hours * 3600 * 1000 + minute * 60 * 1000 + (int) (second * 1000)) * 1000;
    }

    private static string double_to_percent (double seconds) {
        return ((int)(seconds * 100)).to_string () + "%";
    }

    private static string cache_image (string name) {
        return GLib.Path.build_filename (cache_folder (), GLib.Checksum.compute_for_string (ChecksumType.MD5, name, name.length) + ".jpg");
    }

    private static string cache_folder () {
        var cache_dir = File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name ()));
        if (!cache_dir.query_exists ()) {
            try {
                cache_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
        return cache_dir.get_path ();
    }

    private static string config_folder () {
        var config_dir = File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, Environment.get_user_config_dir (), Environment.get_application_name ()));
        if (!config_dir.query_exists ()) {
            try {
                config_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
        return config_dir.get_path ();
    }

    private static string folder_db () {
        return GLib.Path.build_filename (config_folder (), Environment.get_application_name () + ".db");
    }

    private static string? normal_thumb (File thum_file) {
        string hash_file = GLib.Checksum.compute_for_string (ChecksumType.MD5, thum_file.get_uri (), thum_file.get_uri ().length);
        return Path.build_filename (GLib.Environment.get_home_dir (), ".cache", "thumbnails", "normal", hash_file + ".png");
    }

    private static string? large_thumb (File thum_file) {
        string hash_file = GLib.Checksum.compute_for_string (ChecksumType.MD5, thum_file.get_uri (), thum_file.get_uri ().length);
        return Path.build_filename (GLib.Environment.get_home_dir (), ".cache", "thumbnails", "large", hash_file + ".png");
    }

    private string set_filename_media () {
        string time = new GLib.DateTime.now_local ().format ("%F%H:%M:%S");
        int file_id = 0;
        string next_filename = "";
        do {
            next_filename = time + (file_id > 0 ? "-" + file_id.to_string () : "");
            file_id++;
        } while (GLib.FileUtils.test (build_media_filename (next_filename), FileTest.EXISTS));
        return build_media_filename (next_filename);
    }

    private string build_media_filename (string filename) {
        string full_filename = "%s.%s".printf (filename, !NikiApp.settings.get_boolean ("camera-video")? "jpg" : profile_name ());
        string media_directory = get_media_directory ();
        if (!FileUtils.test (media_directory, FileTest.EXISTS)) {
            DirUtils.create (media_directory, 0777);
        }
        return GLib.Path.build_filename (Path.DIR_SEPARATOR_S, media_directory, full_filename);
    }

    private string get_media_directory () {
        UserDirectory user_dir = (!NikiApp.settings.get_boolean ("camera-video")? UserDirectory.PICTURES : UserDirectory.VIDEOS);
        string media_directory = GLib.Environment.get_user_special_dir (user_dir);
        File file = File.new_for_path (GLib.Path.build_path (Path.DIR_SEPARATOR_S, media_directory, "Niki"));
        if (!file.query_exists ()) {
            try {
                file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
        return file.get_path ();
    }

    private string profile_name () {
        string[] filenames = {"mp4", "ogv", "webm", "mkv"};
        return filenames [NikiApp.settings.get_enum ("camera-profile")];
    }

    private static void play_sound (string canbera) {
        Canberra.Context context;
        Canberra.Proplist props;
        Canberra.Context.create (out context);
        Canberra.Proplist.create (out props);
        props.sets (Canberra.PROP_EVENT_ID, canbera);
        props.sets (Canberra.PROP_CANBERRA_CACHE_CONTROL, "permanent");
        props.sets (Canberra.PROP_MEDIA_ROLE, "event");
        context.play_full (0, props, null);
    }

    private Gdk.Pixbuf pix_from_tag (Gst.TagList tag_list, Gst.Tag.ImageType type) {
        var sample = get_cover_sample (tag_list, type);
        if (sample == null) {
            tag_list.get_sample (Gst.Tags.IMAGE, out sample);
        }
        if (sample != null) {
            var buffer = sample.get_buffer ();
            if (buffer != null) {
                return get_pixbuf_from_buffer (buffer);
            }
        }
        return unknown_cover ();
    }

    private Gst.Sample? get_cover_sample (Gst.TagList tag_list, Gst.Tag.ImageType type) {
        Gst.Sample sample;
        for (uint i = 0; tag_list.get_sample_index (Gst.Tags.IMAGE, i, out sample); i++) {
            unowned Gst.Structure caps_struct = sample.get_info ();
            int image_type = Gst.Tag.ImageType.UNDEFINED;
            caps_struct.get_enum ("image-type", typeof (Gst.Tag.ImageType), out image_type);
            if (image_type == type) {
                return sample;
            }
        }
        return sample;
    }

    private void pix_to_file (Gdk.Pixbuf pixbuf, string input) {
        try {
            pixbuf.save (input, "jpeg", "quality", "100");
        } catch (Error err) {
            warning (err.message);
        }
    }

    private Gdk.Pixbuf pix_scale (string input, int size) {
        Gdk.Pixbuf pixbuf = null;
        if (!FileUtils.test (input, FileTest.EXISTS)) {
            return pixbuf;
        }
        try {
            pixbuf = new Gdk.Pixbuf.from_file_at_scale (input, size, size, true);
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return pixbuf;
    }

    private Gdk.Pixbuf pix_file (string input) {
        Gdk.Pixbuf pixbuf = null;
        if (!FileUtils.test (input, FileTest.EXISTS)) {
            return pixbuf;
        }
        try {
            pixbuf = new Gdk.Pixbuf.from_file (input);
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return pixbuf;
    }

    private Gdk.Pixbuf? align_and_scale_pixbuf (Gdk.Pixbuf input_pixbuf, int sizew, int sizeh = 0) {
        return input_pixbuf.scale_simple (sizew, sizeh == 0? sizew : sizeh, Gdk.InterpType.BILINEAR);
    }

    private Gdk.Pixbuf? get_pixbuf_from_buffer (Gst.Buffer buffer) {
        Gst.MapInfo map_info;
        if (!buffer.map (out map_info, Gst.MapFlags.READ)) {
            return null;
        }
        Gdk.Pixbuf pixbuf_loader = null;
        try {
            var loader = new Gdk.PixbufLoader ();
            if (loader.write (map_info.data) && loader.close ()) {
                pixbuf_loader = loader.get_pixbuf ();
            }
        } catch (Error err) {
            warning ("%s", err.message);
        }
        buffer.unmap (map_info);
        return pixbuf_loader;
    }

    private Gdk.Pixbuf get_pixbuf_device_info (GUPnP.DeviceInfo info) {
        string udn = info.get_udn ();
        string icon_url = info.get_icon_url (null, 32, 25, 25, true, null, null, null, null);
        return get_pixbuf_from_url (icon_url, udn);
    }

    private Gdk.Pixbuf? get_pixbuf_from_url (string url, string filename) {
        Gdk.Pixbuf? return_value = null;
        var session = new Soup.Session.with_options ("user_agent", "Niki/0.9.0");
        var msg = new Soup.Message ("GET", url);
        session.send_message (msg);
        if (msg.status_code == 200) {
            string tmp_file = cache_image (filename);
            var file_stream = FileStream.open (tmp_file, "w");
            file_stream.write (msg.response_body.data, (size_t)msg.response_body.length);
            return_value = pix_scale (tmp_file, 48);
            File deleteunuse = File.new_for_path (tmp_file);
            deleteunuse.delete_async.begin ();
            Gdk.Pixbuf pixbuf = align_and_scale_pixbuf (return_value, return_value.get_width (), return_value.get_height ());
            pix_to_file (pixbuf, tmp_file);
        }
        return return_value;
    }

    private Gdk.Pixbuf icon_from_type (string icon_type, int size) {
        Gdk.Pixbuf pixbuf = null;
        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
        try {
            if (icon_type == "object.item.videoItem") {
                pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("video-x-generic", 128, 0), size);
            } else if (icon_type == "object.item.audioItem.musicTrack") {
                pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("audio-x-generic", 128, 0), size);
            } else if (icon_type == "object.item.imageItem.photo") {
                pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("image-x-generic", 128, 0), size);
            } else {
                pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("folder-remote", 128, 0), size);
            }
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return pixbuf;
    }

    private Gdk.Pixbuf icon_from_mediatype (int icon_type) {
        Gdk.Pixbuf pixbuf = null;
        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
        try {
            switch (icon_type) {
                case PlayerMode.VIDEO :
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("video-x-generic", 128, 0), 48);
                    break;
                case PlayerMode.AUDIO :
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("audio-x-generic", 128, 0), 48);
                    break;
                case PlayerMode.STREAMAUD :
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("audio-x-generic", 128, 0), 48);
                    break;
                case PlayerMode.STREAMVID :
                    pixbuf = align_and_scale_pixbuf (icon_theme.load_icon ("video-x-generic", 128, 0), 48);
                    break;
            }
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return pixbuf;
    }

    private Gdk.Pixbuf from_theme_icon (string gicon_name, int resolution, int size) {
        Gdk.Pixbuf pixbuf = null;
        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
        try {
            pixbuf = align_and_scale_pixbuf (icon_theme.load_icon (gicon_name, resolution, 0), size);
        } catch (Error e) {
            GLib.warning (e.message);
        }
        return pixbuf;
    }

    private Gdk.Pixbuf circle_pix (Gdk.Pixbuf pixbuf) {
        if (pixbuf == null) {
            return (Gdk.Pixbuf) null;
        }
        int min_size = int.min (pixbuf.width, pixbuf.height);
        int max_size = int.max (pixbuf.width, pixbuf.height);
        Gdk.Pixbuf new_pix = new Gdk.Pixbuf.subpixbuf (pixbuf, min_size == pixbuf.width? 0 : (int) (max_size / 2) - (min_size / 2), pixbuf.get_height () == min_size? 0 : (int) (max_size / 2) - (min_size / 2), min_size, min_size);
        var draw_surface = new BufferSurface ((int)min_size, (int)min_size);
        Gdk.cairo_set_source_pixbuf (draw_surface.context, new_pix, 0, 0);
        draw_surface.context.paint ();
        Cairo.ImageSurface surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, min_size, min_size);
        Cairo.Context context = new Cairo.Context (surface);
        context.arc (min_size / 2, min_size / 2, min_size / 2, 0, 2 * Math.PI);
        context.clip ();
        context.new_path ();
        int w = new_pix.width;
        int h = new_pix.height;
        context.scale (min_size / w, min_size / h);
        context.set_source_surface (draw_surface.surface, 0, 0);
        context.paint ();
        return Gdk.pixbuf_get_from_surface (surface, 0, 0, min_size, min_size);
    }

    private Gdk.Pixbuf circle_vid (Gdk.Pixbuf pixbuf) {
        int min_size = int.min (pixbuf.width, pixbuf.height);
        int max_size = int.max (pixbuf.width, pixbuf.height);
        Gdk.Pixbuf new_pix = new Gdk.Pixbuf.subpixbuf (pixbuf, min_size == pixbuf.width? 0 : (int) (max_size / 2) - (min_size / 2), pixbuf.get_height () == min_size? 0 : (int) (max_size / 2) - (min_size / 2), min_size, min_size);
        var draw_surface = new BufferSurface ((int)min_size, (int)min_size);
        Gdk.cairo_set_source_pixbuf (draw_surface.context, new_pix, 0, 0);
        draw_surface.context.paint ();
        Cairo.ImageSurface surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, min_size, min_size);
        Cairo.Context context = new Cairo.Context (surface);
        context.set_source_surface (draw_surface.surface, 0, 0);
        context.paint ();
        return align_and_scale_pixbuf (Gdk.pixbuf_get_from_surface (surface, 0, 0, min_size, min_size), 48);
    }

    private Lyric file_lyric (string lyric_file) {
        return new LyricEngine ().parse (File.new_for_uri (lyric_file));
    }

    private void notify_app (string message, string msg_bd) {
        var notification = new GLib.Notification ("");
        notification.set_title (message);
        notification.set_body (msg_bd);
        NikiApp.window.application.send_notification ("notify.app", notification);
    }

    private void move_widget (Gtk.Widget widget) {
        bool mouse_primary_down = false;
        widget.motion_notify_event.connect ((event) => {
            if (mouse_primary_down) {
                mouse_primary_down = false;
                ((Gtk.Window) widget.get_toplevel ()).begin_move_drag (Gdk.BUTTON_PRIMARY, (int)event.x_root, (int)event.y_root, event.time);
            }
            return false;
        });
        widget.button_press_event.connect ((event) => {
            if (event.button == Gdk.BUTTON_PRIMARY) {
                mouse_primary_down = true;
            }
            return Gdk.EVENT_PROPAGATE;
        });
        widget.button_release_event.connect ((event) => {
            if (event.button == Gdk.BUTTON_PRIMARY) {
                mouse_primary_down = false;
            }
            return false;
        });
    }

    private Gst.PbUtils.DiscovererInfo get_discoverer_info (string uri_video) {
        Gst.PbUtils.DiscovererInfo discoverer_info = null;
        try {
            Gst.PbUtils.Discoverer discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
            discoverer_info = discoverer.discover_uri (uri_video);
        } catch (Error e) {
            warning (e.message);
        }
        return discoverer_info;
    }

    private string get_string_tag (string tags, Gst.TagList tag_list) {
        string string_tags;
        if (tag_list.get_string (tags, out string_tags)) {
            return string_tags;
        } else {
            return "";
        }
    }

    private int get_date_tag (Gst.TagList tag_list) {
        GLib.Date? d;
        Gst.DateTime? dt;
        if (tag_list.get_date_time (Gst.Tags.DATE_TIME, out dt)) {
            if (dt != null) {
                return dt.get_year ();
            } else if (tag_list.get_date (Gst.Tags.DATE, out d)) {
                if (d != null) {
                    return dt.get_year ();
                }
            }
        }
        return 0;
    }

    private void permanent_delete (File file) {
        try {
            if (file.query_exists ()) {
                file.delete ();
            }
        } catch (Error e) {
            warning ("Error: %s\n", e.message);
        }
    }

    private void delete_trash (File file) {
        try {
            if (file.query_exists ()) {
                file.trash ();
            }
        } catch (Error e) {
            warning ("Error: %s\n", e.message);
        }
    }

    private File run_open_folder (Gtk.Widget widget) {
        var folder_location = new Gtk.FileChooserNative (_("Open"), ((Gtk.Window) widget.get_toplevel ()), Gtk.FileChooserAction.SELECT_FOLDER, _("Open"), _("Cancel"));

        var filter_folder = new Gtk.FileFilter ();
        filter_folder.add_mime_type ("inode/directory");
        folder_location.set_filter (filter_folder);
        File files = null;
        if (folder_location.run () == Gtk.ResponseType.ACCEPT) {
            files = folder_location.get_file ();
        }
        folder_location.destroy ();
        return files;
    }

    public File[] run_open_file (Gtk.Widget widget, bool multi, int count) {
        var file = new Gtk.FileChooserNative (_("Open"), ((Gtk.Window) widget.get_toplevel ()), Gtk.FileChooserAction.OPEN, _("Open"), _("Cancel"));
        file.select_multiple = multi;

        var preview_area = new Gtk.Image () {
            pixel_size = 256,
            margin_end = 12
        };

        var all_files_filter = new Gtk.FileFilter ();
        all_files_filter.set_filter_name (_("All Files"));
        all_files_filter.add_pattern ("*");

        var video_filter = new Gtk.FileFilter ();
        video_filter.set_filter_name (_("Audio Video"));
        video_filter.add_mime_type ("video/*");
        video_filter.add_mime_type ("audio/*");

        var image_filter = new Gtk.FileFilter ();
        image_filter.set_filter_name (_("Image"));
        image_filter.add_mime_type ("image/*");

        var text_filter = new Gtk.FileFilter ();
        text_filter.set_filter_name (_("Text"));
        text_filter.add_mime_type ("text/*");

        var label = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 20,
            margin_end = 10
        };
        label.get_style_context ().add_class ("h3");

        var label_bitrate = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 20,
            margin_end = 10
        };
        label_bitrate.get_style_context ().add_class ("h3");

        var label_sample = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 20,
            margin_end = 10
        };
        label_sample.get_style_context ().add_class ("h3");

        var label_chanel = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 20,
            margin_end = 10
        };
        label_chanel.get_style_context ().add_class ("h3");

        var label_duration = new Gtk.Label (null) {
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 20,
            margin_end = 10
        };
        label_duration.get_style_context ().add_class ("h3");

        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            valign = Gtk.Align.CENTER
        };
        grid.add (preview_area);
        grid.add (label);
        grid.add (label_bitrate);
        grid.add (label_sample);
        grid.add (label_chanel);
        grid.add (label_duration);
        grid.show_all ();
        switch (count) {
            case 1:
                file.add_filter (video_filter);
                break;
            case 2:
                file.add_filter (image_filter);
                break;
            case 3:
                file.add_filter (text_filter);
                break;
        }

        file.add_filter (all_files_filter);
        file.set_preview_widget (grid);
        file.set_preview_widget_active (false);
        file.set_use_preview_label (false);
        file.update_preview.connect (() => {
            string uri = file.get_preview_uri ();
            if (uri != null && uri.has_prefix ("file://")) {
                var file_pre = File.new_for_uri (uri);
                Gdk.Pixbuf pixbuf = null;
                if (get_mime_type (file_pre).has_prefix ("video/")) {
                    if (!FileUtils.test (large_thumb (file_pre), FileTest.EXISTS)) {
                        var dbus_thum = new DbusThumbnailer ().instance;
                        dbus_thum.instand_thumbler (file_pre, "large");
                        dbus_thum.load_finished.connect (()=>{
                            preview_area.set_from_pixbuf (pix_scale (large_thumb (file_pre), 256));
                            label.label = file_pre.get_basename ();
                            preview_area.show ();
                            file.set_preview_widget_active (true);
                        });
                    } else {
                        pixbuf = pix_scale (large_thumb (file_pre), 256);
                    }
                    var info = get_discoverer_info (file_pre.get_uri ());
                    var stream_info = info.get_stream_info ();
                    Gst.Caps caps = stream_info.get_caps ();
                    label_bitrate.tooltip_text = label_bitrate.label ="%s: %s".printf (stream_info.get_stream_type_nick (), caps.is_fixed () == true? Gst.PbUtils.get_codec_description (caps) : caps.to_string ());
                    ((Gst.PbUtils.DiscovererContainerInfo) stream_info).get_streams ().foreach ((list)=> {
                        if (list.get_stream_type_nick () == "audio") {
                            Gst.Caps acaps = list.get_caps ();
                            label_sample.tooltip_text = label_sample.label ="%s: %s".printf (list.get_stream_type_nick (), acaps.is_fixed () == true? Gst.PbUtils.get_codec_description (acaps) : acaps.to_string ());
                        }
                        if (list.get_stream_type_nick () == "video") {
                            Gst.Caps vcaps = list.get_caps ();
                            label_chanel.tooltip_text = label_chanel.label ="%s: %s".printf (list.get_stream_type_nick (), vcaps.is_fixed () == true? Gst.PbUtils.get_codec_description (vcaps) : vcaps.to_string ());
                        }
                    });
                    label_duration.tooltip_text = label_duration.label = seconds_to_time ((int)(info.get_duration () / 1000000000));
                } else if (get_mime_type (file_pre).has_prefix ("audio/")) {
                    pixbuf = align_and_scale_pixbuf (pix_from_tag (get_discoverer_info (file_pre.get_uri ()).get_toc ().get_tags (), Gst.Tag.ImageType.FRONT_COVER), 256);
                    if (!file_pre.get_uri ().down ().has_suffix ("aac") || !file_pre.get_uri ().down ().has_suffix ("ac3")) {
                        var tagfile = new InyTag.File (file_pre.get_path ());
                        label_bitrate.tooltip_text = label_bitrate.label = tagfile.audioproperties.bitrate.to_string () + _(" kHz");
                        label_sample.tooltip_text = label_sample.label = tagfile.audioproperties.samplerate.to_string () + _(" bps");
                        label_chanel.tooltip_text = label_chanel.label = tagfile.audioproperties.channels == 2? _("Stereo") : _("Mono");
                        label_duration.tooltip_text = label_duration.label = seconds_to_time (tagfile.audioproperties.length);
                    }
                } else if (get_mime_type (file_pre).has_prefix ("image/")) {
                    pixbuf = pix_scale (file_pre.get_path (), 256);
                }
                if (get_mime_type (file_pre).has_prefix ("video/") || get_mime_type (file_pre).has_prefix ("audio/")) {
                    label_bitrate.show ();
                    label_sample.show ();
                    label_chanel.show ();
                    label_duration.show ();
                } else {
                    label_bitrate.hide ();
                    label_sample.hide ();
                    label_chanel.hide ();
                    label_duration.hide ();
                }
                if (pixbuf != null) {
                    label.tooltip_text = label.label = file_pre.get_basename ();
                    preview_area.set_from_pixbuf (pixbuf);
                    preview_area.show ();
                    file.set_preview_widget_active (true);
                } else {
                    preview_area.hide ();
                    file.set_preview_widget_active (false);
                }
            } else {
                preview_area.hide ();
                file.set_preview_widget_active (false);
            }
        });
        File[] files = null;
        if (file.run () == Gtk.ResponseType.ACCEPT) {
            foreach (File item in file.get_files ()) {
                files += item;
            }
        }
        file.destroy ();
        return files;
    }

    public bool is_privacy_mode_enabled () {
        var zeitgeist_manager = new ZeitgeistManager ();
        var privacy_settings = new GLib.Settings ("org.gnome.desktop.privacy");
        bool privacy_mode = privacy_settings.get_boolean ("remember-recent-files") || privacy_settings.get_boolean ("remember-app-usage");
        if (privacy_mode) {
            return true;
        }
        return zeitgeist_manager.app_into_blacklist (NikiApp.instance.application_id);
    }

    private Gdk.Pixbuf? unknown_cover () {
        Cairo.ImageSurface surface = new Cairo.ImageSurface (Cairo.Format.RGB30, 256, 256);
        Cairo.Context context = new Cairo.Context (surface);
        Cairo.Pattern bacground = new Cairo.Pattern.linear (0.0, 0.0, 0.0, 256.0);
        bacground.add_color_stop_rgba (1, 0, 0, 0, 1);
        context.rectangle (0, 0, 256, 256);
        context.set_source (bacground);
        context.fill ();
        Cairo.Pattern arc0 = new Cairo.Pattern.radial (115.2, 102.4, 25.6, 102.4, 102.4, 128.0);
        arc0.add_color_stop_rgba (0.241, 0.115, 0.20, 1, 1);
        context.set_source (arc0);
        context.arc (128.0, 128.0, 110.8, 0, 2 * Math.PI);
        context.fill ();
        Cairo.Pattern arc1 = new Cairo.Pattern.radial (130.2, 110.4, 0, 112.4, 120.4, 140.0);
        arc1.add_color_stop_rgba (0, 1, 1, 1, 1);
        arc1.add_color_stop_rgba (1, 0, 0, 0, 1);
        context.set_source (arc1);
        context.arc (128.0, 128.0, 100.8, 0, 2 * Math.PI);
        context.fill ();
        Cairo.Pattern arc2 = new Cairo.Pattern.radial (115.2, 102.4, 25.6, 102.4, 102.4, 128.0);
        arc2.add_color_stop_rgba (1, 1, 1, 1, 1);
        context.set_source (arc2);
        context.arc (128.0, 128.0, 40.8, 0, 2 * Math.PI);
        context.fill ();
        Cairo.Pattern arc3 = new Cairo.Pattern.radial (115.2, 102.4, 25.6, 102.4, 102.4, 128.0);
        arc3.add_color_stop_rgba (1, 0, 0, 0, 1);
        context.set_source (arc3);
        context.arc (128.0, 128.0, 20.8, 0, 2 * Math.PI);
        context.fill ();
        Cairo.Pattern arc4 = new Cairo.Pattern.radial (115.2, 102.4, 25.6, 102.4, 102.4, 128.0);
        arc4.add_color_stop_rgba (1, 1, 1, 1, 1);
        context.set_source (arc4);
        context.arc (128.0, 128.0, 10.8, 0, 2 * Math.PI);
        context.fill ();
        return Gdk.pixbuf_get_from_surface (surface, 0, 0, 256, 256);
    }

    private string? niki_mime_type () {
        var builder = new StringBuilder ();
        builder.append ("MimeType=");
        builder.append ("audio/aac;");
        builder.append ("audio/x-aiff;");
        builder.append ("audio/aiff;");
        builder.append ("audio/m4a;");
        builder.append ("audio/x-m4a;");
        builder.append ("audio/mp1;");
        builder.append ("audio/x-mp1;");
        builder.append ("audio/mp2;");
        builder.append ("audio/x-mp2;");
        builder.append ("audio/mp2;");
        builder.append ("audio/x-mp3;");
        builder.append ("audio/mpeg;");
        builder.append ("audio/rn-mpeg;");
        builder.append ("audio/mpeg2;");
        builder.append ("audio/mpeg3;");
        builder.append ("audio/mpegurl;");
        builder.append ("audio/x-mpegurl;");
        builder.append ("audio/x-mpg;");
        builder.append ("audio/x-wav;");
        builder.append ("audio/musepack;");
        builder.append ("audio/x-musepack;");
        builder.append ("audio/ogg;");
        builder.append ("audio/scpls;");
        builder.append ("audio/vnd.rn-realaudio;");
        builder.append ("audio/wav;");
        builder.append ("audio/x-pn-wav;");
        builder.append ("audio/x-pn-windows-pcm;");
        builder.append ("audio/x-realaudio;");
        builder.append ("audio/x-pn-realaudio;");
        builder.append ("audio/x-ms-wma;");
        builder.append ("audio/x-pls;");
        builder.append ("audio/mp4;");
        builder.append ("audio/webm;");
        builder.append ("audio/vorbis;");
        builder.append ("audio/x-vorbis;");
        builder.append ("audio/x-vorbis+ogg;");
        builder.append ("audio/x-shorten;");
        builder.append ("audio/x-ape;");
        builder.append ("audio/x-wavpack;");
        builder.append ("audio/x-ape;");
        builder.append ("audio/x-tta;");
        builder.append ("audio/AMR;");
        builder.append ("audio/m3u;");
        builder.append ("audio/ac3;");
        builder.append ("audio/ts.hd;");
        builder.append ("audio/eac3;");
        builder.append ("audio/x-adpcm;");
        builder.append ("audio/amr-wb;");
        builder.append ("audio/flac;");
        builder.append ("audio/x-pn-au;");
        builder.append ("audio/dv;");
        builder.append ("audio/x-adpcm;");
        builder.append ("audio/vnd.dts;");
        builder.append ("video/mpeg;");
        builder.append ("video/x-mpeg2;");
        builder.append ("video/x-mpeg3;");
        builder.append ("video/mp4v-es;");
        builder.append ("video/mp4;");
        builder.append ("video/divx;");
        builder.append ("video/vnd.divx;");
        builder.append ("video/msvideo;");
        builder.append ("video/ogg;");
        builder.append ("video/quicktime;");
        builder.append ("video/vnd.rn-realvideo;");
        builder.append ("video/x-ms-afs;");
        builder.append ("video/x-ms-asf;");
        builder.append ("video/x-ms-asf;");
        builder.append ("video/x-ms-wmv;");
        builder.append ("video/x-ms-wmx;");
        builder.append ("video/x-ms-wvxvideo;");
        builder.append ("video/x-avi;");
        builder.append ("video/avi;");
        builder.append ("video/x-flic;");
        builder.append ("video/x-flc;");
        builder.append ("video/x-flv;");
        builder.append ("video/x-fli;");
        builder.append ("video/flv;");
        builder.append ("video/x-theora;");
        builder.append ("video/x-theora+ogg;");
        builder.append ("video/x-matroska;");
        builder.append ("video/mkv;");
        builder.append ("video/webm;");
        builder.append ("video/x-ogm;");
        builder.append ("video/x-ogm+ogg;");
        builder.append ("video/3gpp;");
        builder.append ("video/3gpp2;");
        builder.append ("video/3gp;");
        builder.append ("video/dv;");
        builder.append ("video/opus;");
        builder.append ("video/mp2t;");
        builder.append ("video/vnd.mpegurl;");
        builder.append ("application/vnd.smaf;");
        return builder.str;
    }

    private string protocol_info () {
        var builder = new StringBuilder ();
        builder.append ("http-get:*:video/mp4:DLNA.ORG_PN=AVC_MP4_BL_CIF15_AAC_520,");
        builder.append ("http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_HD_NA_ISO,");
        builder.append ("http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_NA_ISO,");
        builder.append ("http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_EU_ISO,");
        builder.append ("http-get:*:audio/x-ms-wma:DLNA.ORG_PN=WMAPRO,");
        builder.append ("http-get:*:audio/x-ms-wma:DLNA.ORG_PN=WMAFULL,");
        builder.append ("http-get:*:audio/x-ms-wma:DLNA.ORG_PN=WMABASE,");
        builder.append ("http-get:*:audio/l16;rate=44100;channels=1:DLNA.ORG_PN=LPCM,");
        builder.append ("http-get:*:audio/l16;rate=44100;channels=2:DLNA.ORG_PN=LPCM,");
        builder.append ("http-get:*:audio/3gpp:DLNA.ORG_PN=AAC_ISO_320,");
        builder.append ("http-get:*:audio/mp4:DLNA.ORG_PN=AAC_ISO_320,");
        builder.append ("http-get:*:audio/vnd.dlna.adts:DLNA.ORG_PN=AAC_ADTS_320,");
        builder.append ("http-get:*:audio/mpeg:DLNA.ORG_PN=MP3X,");
        builder.append ("http-get:*:audio/mpeg:DLNA.ORG_PN=MP3,");
        builder.append ("http-get:*:image/png:DLNA.ORG_PN=PNG_LRG,");
        builder.append ("http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_LRG,");
        builder.append ("http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_MED,");
        builder.append ("http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_SM,");
        builder.append ("http-get:*:text/xml:DLNA.ORG_PN=DIDL_S,");
        builder.append ("rtsp:*:video/mp4:DLNA.ORG_PN=AVC_MP4_BL_CIF15_AAC_520,");
        builder.append ("rtsp:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_HD_NA_ISO,");
        builder.append ("rtsp:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_NA_ISO,");
        builder.append ("rtsp:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_EU_ISO,");
        builder.append ("rtsp:*:audio/x-ms-wma:DLNA.ORG_PN=WMAPRO,");
        builder.append ("rtsp:*:audio/x-ms-wma:DLNA.ORG_PN=WMAFULL,");
        builder.append ("rtsp:*:audio/x-ms-wma:DLNA.ORG_PN=WMABASE,");
        builder.append ("rtsp:*:audio/l16;rate=44100;channels=1:DLNA.ORG_PN=LPCM,");
        builder.append ("rtsp:*:audio/l16;rate=44100;channels=2:DLNA.ORG_PN=LPCM,");
        builder.append ("rtsp:*:audio/3gpp:DLNA.ORG_PN=AAC_ISO_320,");
        builder.append ("rtsp:*:audio/mp4:DLNA.ORG_PN=AAC_ISO_320,");
        builder.append ("rtsp:*:audio/vnd.dlna.adts:DLNA.ORG_PN=AAC_ADTS_320,");
        builder.append ("rtsp:*:audio/mpeg:DLNA.ORG_PN=MP3X,");
        builder.append ("rtsp:*:audio/mpeg:DLNA.ORG_PN=MP3,");
        builder.append ("rtsp:*:image/png:DLNA.ORG_PN=PNG_LRG,");
        builder.append ("rtsp:*:image/jpeg:DLNA.ORG_PN=JPEG_LRG,");
        builder.append ("rtsp:*:image/jpeg:DLNA.ORG_PN=JPEG_MED,");
        builder.append ("rtsp:*:image/jpeg:DLNA.ORG_PN=JPEG_SM,");
        builder.append ("rtsp:*:text/xml:DLNA.ORG_PN=DIDL_S,");
        builder.append ("http-get:*:audio/mpeg:*,");
        builder.append ("http-get:*:application/ogg:*,");
        builder.append ("http-get:*:audio/x-vorbis:*,");
        builder.append ("http-get:*:audio/x-vorbis+ogg:*,");
        builder.append ("http-get:*:audio/ogg:*,");
        builder.append ("http-get:*:audio/x-ms-wma:*,");
        builder.append ("http-get:*:audio/x-ms-asf:*,");
        builder.append ("http-get:*:audio/x-flac:*,");
        builder.append ("http-get:*:audio/x-flac+ogg:*,");
        builder.append ("http-get:*:audio/flac:*,");
        builder.append ("http-get:*:audio/mp4:*,");
        builder.append ("http-get:*:audio/3gpp:*,");
        builder.append ("http-get:*:audio/vnd.dlna.adts:*,");
        builder.append ("http-get:*:audio/x-mod:*,");
        builder.append ("http-get:*:audio/x-wav:*,");
        builder.append ("http-get:*:audio/wav:*,");
        builder.append ("http-get:*:audio/x-ac3:*,");
        builder.append ("http-get:*:audio/x-m4a:*,");
        builder.append ("http-get:*:audio/l16;rate=44100;channels=2:*,");
        builder.append ("http-get:*:audio/l16;rate=44100;channels=1:*,");
        builder.append ("http-get:*:audio/l16;channels=2;rate=44100:*,");
        builder.append ("http-get:*:audio/l16;channels=1;rate=44100:*,");
        builder.append ("http-get:*:audio/l16;rate=44100:*,");
        builder.append ("http-get:*:image/jpeg:*,");
        builder.append ("http-get:*:image/png:*,");
        builder.append ("http-get:*:video/x-theora:*,");
        builder.append ("http-get:*:video/x-theora+ogg:*,");
        builder.append ("http-get:*:video/x-oggm:*,");
        builder.append ("http-get:*:video/ogg:*,");
        builder.append ("http-get:*:video/x-dirac:*,");
        builder.append ("http-get:*:video/x-wmv:*,");
        builder.append ("http-get:*:video/x-wma:*,");
        builder.append ("http-get:*:video/x-msvideo:*,");
        builder.append ("http-get:*:video/x-3ivx:*,");
        builder.append ("http-get:*:video/x-3ivx:*,");
        builder.append ("http-get:*:video/x-matroska:*,");
        builder.append ("http-get:*:video/x-mkv:*,");
        builder.append ("http-get:*:video/mpeg:*,");
        builder.append ("http-get:*:video/mp4:*,");
        builder.append ("http-get:*:application/x-shockwave-flash:*,");
        builder.append ("http-get:*:video/x-ms-asf:*,");
        builder.append ("http-get:*:video/x-xvid:*,");
        builder.append ("http-get:*:video/x-ms-wmv:*,");
        builder.append ("http-get:*:audio/mpegurl:*,");
        builder.append ("http-get:*:audio/x-mpegurl:*,");
        builder.append ("http-get:*:video/mpegurl:*,");
        builder.append ("http-get:*:video/x-mpegurl:*,");
        builder.append ("rtsp:*:audio/mpeg:*,");
        builder.append ("rtsp:*:application/ogg:*,");
        builder.append ("rtsp:*:audio/x-vorbis:*,");
        builder.append ("rtsp:*:audio/x-vorbis+ogg:*,");
        builder.append ("rtsp:*:audio/ogg:*,");
        builder.append ("rtsp:*:audio/x-ms-wma:*,");
        builder.append ("rtsp:*:audio/x-ms-asf:*,");
        builder.append ("rtsp:*:audio/x-flac:*,");
        builder.append ("rtsp:*:audio/x-flac+ogg:*,");
        builder.append ("rtsp:*:audio/flac:*,");
        builder.append ("rtsp:*:audio/mp4:*,");
        builder.append ("rtsp:*:audio/3gpp:*,");
        builder.append ("rtsp:*:audio/vnd.dlna.adts:*,");
        builder.append ("rtsp:*:audio/x-mod:*,");
        builder.append ("rtsp:*:audio/x-wav:*,");
        builder.append ("rtsp:*:audio/wav:*,");
        builder.append ("rtsp:*:audio/x-ac3:*,");
        builder.append ("rtsp:*:audio/x-m4a:*,");
        builder.append ("rtsp:*:audio/l16;rate=44100;channels=2:*,");
        builder.append ("rtsp:*:audio/l16;rate=44100;channels=1:*,");
        builder.append ("rtsp:*:audio/l16;channels=2;rate=44100:*,");
        builder.append ("rtsp:*:audio/l16;channels=1;rate=44100:*,");
        builder.append ("rtsp:*:audio/l16;rate=44100:*,");
        builder.append ("rtsp:*:image/jpeg:*,");
        builder.append ("rtsp:*:image/png:*,");
        builder.append ("rtsp:*:video/x-theora:*,");
        builder.append ("rtsp:*:video/x-theora+ogg:*,");
        builder.append ("rtsp:*:video/x-oggm:*,");
        builder.append ("rtsp:*:video/ogg:*,");
        builder.append ("rtsp:*:video/x-dirac:*,");
        builder.append ("rtsp:*:video/x-wmv:*,");
        builder.append ("rtsp:*:video/x-wma:*,");
        builder.append ("rtsp:*:video/x-msvideo:*,");
        builder.append ("rtsp:*:video/x-3ivx:*,");
        builder.append ("rtsp:*:video/x-3ivx:*,");
        builder.append ("rtsp:*:video/x-matroska:*,");
        builder.append ("rtsp:*:video/x-mkv:*,");
        builder.append ("rtsp:*:video/mpeg:*,");
        builder.append ("rtsp:*:video/mp4:*,");
        builder.append ("rtsp:*:application/x-shockwave-flash:*,");
        builder.append ("rtsp:*:video/x-ms-asf:*,");
        builder.append ("rtsp:*:video/x-xvid:*,");
        builder.append ("rtsp:*:video/x-ms-wmv:*,");
        builder.append ("rtsp:*:audio/mpegurl:*,");
        builder.append ("rtsp:*:audio/x-mpegurl:*,");
        builder.append ("rtsp:*:video/mpegurl:*,");
        builder.append ("rtsp:*:video/x-mpegurl:*");
        return builder.str;
    }

    private int open_database (out Sqlite.Database db) {
        int opendb = 0;
        if (!File.new_for_path (folder_db ()).query_exists ()) {
            opendb = creat_no_exist (out db);
        } else {
            opendb = Sqlite.Database.open (folder_db (), out db);
        }
        return opendb;
    }

    private int creat_no_exist (out Sqlite.Database db) {
        int opendb = Sqlite.Database.open (folder_db (), out db);
        if (opendb != Sqlite.OK) {
            warning ("Can't open database: %s\n", db.errmsg ());
        }
        opendb = db.exec ("CREATE TABLE IF NOT EXISTS musics (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            uri            TEXT    NOT NULL,
            title          TEXT    NOT NULL,
            artist         TEXT    NOT NULL,
            album          TEXT    NOT NULL,
            genre          TEXT    NOT NULL,
            year           INT     NOT NULL,
            duration       TEXT    NOT NULL,
            lastplay       DOUBLE  NOT NULL,
            CONSTRAINT unique_music UNIQUE (uri),
            FOREIGN KEY (album) REFERENCES albums (id) ON DELETE CASCADE)", null, null);
        opendb = db.exec ("CREATE TABLE IF NOT EXISTS videos (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            uri            TEXT    NOT NULL,
            progress       TEXT    NOT NULL,
            duration       TEXT    NOT NULL,
            lastplay       DOUBLE  NOT NULL,
            CONSTRAINT unique_video UNIQUE (uri),
            FOREIGN KEY (uri) REFERENCES uris (id) ON DELETE CASCADE)", null, null);
        return opendb;
    }

    private bool music_file_exists (string uri) {
        bool exist = false;
        Sqlite.Statement stmt;
        int res = NikiApp.db.prepare_v2 ("SELECT COUNT (*) FROM musics WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            exist = stmt.column_int (0) > 0;
        }
        return exist;
    }

    private bool videos_file_exists (string uri) {
        bool exist = false;
        Sqlite.Statement stmt;
        int res = NikiApp.db.prepare_v2 ("SELECT COUNT (*) FROM videos WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            exist = stmt.column_int (0) > 0;
        }
        return exist;
    }

    private void insert_music (File path) {
        Sqlite.Statement stmt;
        string sql = "INSERT OR IGNORE INTO musics (uri, title, artist, album, genre, year, duration, lastplay) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        var info = get_discoverer_info (path.get_uri ());
        var tags = info.get_toc ().get_tags ();
        int res = NikiApp.db.prepare_v2 (sql, -1, out stmt);
        res = stmt.bind_text (1, path.get_uri ());
        res = stmt.bind_text (2, get_song_info (path));
        res = stmt.bind_text (3, get_string_tag (Gst.Tags.ARTIST, tags));
        res = stmt.bind_text (4, get_string_tag (Gst.Tags.ALBUM, tags));
        res = stmt.bind_text (5, get_string_tag (Gst.Tags.GENRE, tags));
        res = stmt.bind_int (6, get_date_tag (tags));
        res = stmt.bind_text (7, seconds_to_time ((int)(info.get_duration () / 1000000000)));
        res = stmt.bind_double (8, 0.0);
        if ((res = stmt.step ()) != Sqlite.DONE) {
            warning ("Error: %d: %s", NikiApp.db.errcode (), NikiApp.db.errmsg ());
        }
        stmt.reset ();
    }

    private void insert_video (string uri, string progress, string duration, double lastplay) {
        Sqlite.Statement stmt;
        string sql = "INSERT OR IGNORE INTO videos (uri, progress, duration, lastplay) VALUES (?, ?, ?, ?);";
        int res = NikiApp.db.prepare_v2 (sql, -1, out stmt);
        res = stmt.bind_text (1, uri);
        res = stmt.bind_text (2, progress);
        res = stmt.bind_text (3, duration);
        res = stmt.bind_double (4, lastplay);
        if ((res = stmt.step ()) != Sqlite.DONE) {
            warning ("Error: %d: %s", NikiApp.db.errcode (), NikiApp.db.errmsg ());
        }
        stmt.reset ();
    }

    private void insert_last_video (string uri, string progress, double lastplay) {
        Sqlite.Statement stmt;
        string sql = @" UPDATE videos SET progress = \"$(progress)\", lastplay = $(lastplay)  WHERE uri = ?";
        int res = NikiApp.db.prepare_v2 (sql, -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) != Sqlite.DONE) {
            warning ("Error: %d: %s", NikiApp.db.errcode (), NikiApp.db.errmsg ());
        }
        stmt.reset ();
    }

    private double lastplay_video (string uri) {
        Sqlite.Statement stmt;
        double last = 0.0;
        int res = NikiApp.db.prepare_v2 ("SELECT * FROM videos WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            last = stmt.column_double (4);
        }
        return last;
    }

    private double duration_video (string uri) {
        Sqlite.Statement stmt;
        string last = "";
        int res = NikiApp.db.prepare_v2 ("SELECT * FROM videos WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            last = stmt.column_text (3);
        }
        return seconds_from_time (last);
    }

    private void insert_last_music (string uri, double lastplay) {
        Sqlite.Statement stmt;
        string sql = @" UPDATE musics SET lastplay = $(lastplay) WHERE uri = ?";
        int res = NikiApp.db.prepare_v2 (sql, -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) != Sqlite.DONE) {
            warning ("Error: %d: %s", NikiApp.db.errcode (), NikiApp.db.errmsg ());
        }
        stmt.reset ();
    }

    private double lastplay_music (string uri) {
        Sqlite.Statement stmt;
        double last = 0.0;
        int res = NikiApp.db.prepare_v2 ("SELECT * FROM musics WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            last = stmt.column_double (8);
        }
        return last;
    }

    private double duration_music (string uri) {
        Sqlite.Statement stmt;
        string last = "";
        int res = NikiApp.db.prepare_v2 ("SELECT * FROM musics WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            last = stmt.column_text (7);
        }
        return seconds_from_time (last);
    }

    private void get_video (string uri, out string progress, out string duration, out double lastplay) {
        progress = "";
        duration = "";
        lastplay = 0.0;
        Sqlite.Statement stmt;
        int res = NikiApp.db.prepare_v2 ("SELECT * FROM videos WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            progress = stmt.column_text (2);
            duration = stmt.column_text (3);
            lastplay = stmt.column_double (4);
        }
    }
    private void get_music (string uri, out string title, out string artist, out string album, out string genre, out int years, out string duration, out double lastplay) {
        title = "";
        artist = "";
        album = "";
        genre = "";
        duration = "";
        years = 0;
        lastplay = 0.0;
        Sqlite.Statement stmt;
        int res = NikiApp.db.prepare_v2 ("SELECT * FROM musics WHERE uri = ?", -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) == Sqlite.ROW) {
            title = stmt.column_text (2);
            artist = stmt.column_text (3);
            album = stmt.column_text (4);
            genre = stmt.column_text (5);
            years = stmt.column_int (6);
            duration = stmt.column_text (7);
            lastplay = stmt.column_double (8);
        }
    }
    private void update_music_db (string uri) {
        Sqlite.Statement stmt;
        var path = File.new_for_uri (uri);
        string sql = "";
        var tags = get_discoverer_info (path.get_uri ()).get_toc ().get_tags ();
        sql = @" UPDATE musics SET title = \"$(get_song_info (path))\", artist = \"$(get_string_tag (Gst.Tags.ARTIST, tags))\", album = \"$(get_string_tag (Gst.Tags.ALBUM, tags))\", genre = \"$(get_string_tag (Gst.Tags.GENRE, tags))\", year = $(get_date_tag (tags)) WHERE uri = ?";
        int res = NikiApp.db.prepare_v2 (sql, -1, out stmt);
        res = stmt.bind_text (1, uri);
        if ((res = stmt.step ()) != Sqlite.DONE) {
            warning ("Error: %d: %s", NikiApp.db.errcode (), NikiApp.db.errmsg ());
        }
        stmt.reset ();
    }
}
