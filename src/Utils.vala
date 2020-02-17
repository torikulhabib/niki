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

    private const string [] SUBTITLE_EXTENSIONS = {
        "sub", "srt", "smi", "ssa", "ass", "asc"
    };


	private string get_song_info (File path) {
	    string output = null;
        switch (file_type (path)) {
            case 0 :
		        output = get_info_file (path);
                break;
            case 1 :
		        string name = path.get_path ();
		        var info =  new TagLib.File(name);
		        output = info.tag.title.char_count () < 1? get_info_file (path) : info.tag.title + "";
                break;
        }
		return output;
	}

    private string get_artist_music (string inputfile) {
        string inputstring = File.new_for_uri (inputfile).get_path ();
        string artist_music = null;
		var info =  new TagLib.File(inputstring);
		artist_music = info.tag.artist.char_count () < 1? StringPot.Unknow : info.tag.artist;
        return artist_music;
    }
    private string get_album_music (string inputfile) {
        string inputstring = File.new_for_uri (inputfile).get_path ();
        string album_music = null;
		var info =  new TagLib.File(inputstring);
		album_music = info.tag.album.char_count () < 1? StringPot.Unknow : info.tag.album;
        return album_music;
    }

    private string get_mime_type (File fileinput) {
        string mime_type = null;
	    try {
		    FileInfo infos = fileinput.query_info ("standard::*",0);
            mime_type = infos.get_content_type ();
	    } catch (Error e) {
            GLib.warning (e.message);
	    }
	    return mime_type;
    }

    private int file_type (File filein) {
        int type_file = 0;
        string mime_types = null;
        if (filein.get_uri ().has_prefix ("https://cf-media.sndcdn.com")) {
            return 2;
        }
        if (filein.get_uri ().contains ("googlevideo")) {
            return 3;
        }
        if (filein.get_uri ().char_count () > 1 && filein.query_exists ()) {
	        try {
		        FileInfo infos = filein.query_info ("standard::*",0);
                mime_types = infos.get_content_type ();
                if (mime_types.has_prefix ("video/")) {
                    return 0;
                }
                if (mime_types.has_prefix ("audio/")) {
                    return 1;
                }
	        } catch (Error e) {
                GLib.warning (e.message);
	        }
	    }
	    return type_file;
    }
    private static string get_info_file (File fileinput) {
        string file_info = null;
	    try {
		    FileInfo info = fileinput.query_info ("standard::*",0);
            file_info = info.get_display_name ();
	    } catch (Error e) {
            GLib.warning (e.message);
	    }
        return file_info;
    }
    private static string get_info_size (string fileinput) {
        string file_info = null;
        if (!File.new_for_uri (fileinput).query_exists ()) {
            return file_info;
        }
	    try {
		    FileInfo info = File.new_for_uri (fileinput).query_info ("standard::*",0);
		    file_info = int64_to_size (info.get_size ());
	    } catch (Error e) {
            GLib.warning (e.message);
	    }
        return file_info;
    }
    private static string int64_to_size (int64 size_file, bool need = true) {
        string file_info = null;
        string [] sizes = { " Byte", " KB", " MB", " GB", " TB" };
        double len = (double) size_file;
        int order = 0;
        while (len >= 1000 && order < sizes.length - 1) {
            order++;
            len = len/1000;
        }
        if(size_file < 0){
            len = 0;
            order = 0;
        }
        if (need) {
            file_info = " %s: %3.1f%s".printf (StringPot.Size, len, sizes[order]);
        } else {
            file_info = "%3.1f%s".printf (len, sizes[order]);
        }
        return file_info;
    }
    private string? get_subtitle_for_uri (string uri) {
        string without_ext;
        int last_dot = uri.last_index_of (".", 0);
        int last_slash = uri.last_index_of ("/", 0);

        if (last_dot < last_slash) {
            without_ext = uri;
        } else {
            without_ext = uri.slice (0, last_dot);
        }

        foreach (string ext in SUBTITLE_EXTENSIONS){
            string sub_uri = without_ext + "." + ext;
            if (File.new_for_uri (sub_uri).query_exists ()) {
                return sub_uri;
            }
        }
        return null;
    }

    private bool? is_subtitle (string uri) {
        bool find_sub = false;
        int last_dot = uri.last_index_of (".", 0);

        foreach (string ext in SUBTITLE_EXTENSIONS){
            if (uri.substring (last_dot + 1) == ext) {
                find_sub = true;
            }
        }
        return find_sub;
    }
    private string? get_playing_liric (string uri) {
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

    private static bool file_exists (string uri) {
        if (!NikiApp.settings.get_boolean ("stream-mode")) {
            return File.new_for_uri (uri).query_exists ();
        } else {
            return false;
        }
    }

    private bool cursor_hand_mode (int cursor_mode) {
        const Gdk.CursorType[] cursors = {
            Gdk.CursorType.HAND2,
            Gdk.CursorType.BLANK_CURSOR,
            Gdk.CursorType.ARROW,
            Gdk.CursorType.HAND1
        };
        var display = window.get_display ();
        var cursor = new Gdk.Cursor.for_display (display, cursors [cursor_mode]);
        window.get_window().set_cursor (cursor);
        return false;
    }

    private bool destroy_mode () {
        if (window.player_page.playback.playing && NikiApp.settings.get_boolean ("audio-video")) {
            return window.hide_on_delete ();
        } else {
            window.player_page.save_destroy ();
            window.player_page.playback.dispose ();
            window.destroy ();
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

        if (!need){
            return  ("%u:%02u:%02u".printf (hours, min, sec));
        } else {
            if (hours > 0) {
                return ("%d:%02d:%02d".printf (sign * hours, min, sec));
            } else {
                return ("%02d:%02d".printf (sign * min, sec));
            }
        }
    }
    private double seconds_from_time (string time_string) {
        string [] tokens = {};
        double seconds = -1.0;
        tokens = time_string.split (":", -1);
        if (tokens == null) {
            return -1.0;
        }
        if (tokens[0] == null || tokens[1] == null || tokens[2] == null) {
            return -1.0;
        }

        seconds = double.parse (tokens[2]);
        seconds += double.parse (tokens[1]) * 60;
        seconds += double.parse (tokens[0]) * 3600;
        return seconds;
    }
    private static string double_to_percent (double seconds) {
        string result = ((int)(seconds * 100)).to_string () + "%";
        return result;
    }

    private static string cache_image (string name) {
        string cache_icon = null;
        cache_icon = GLib.Path.build_filename (cache_folder (), name + ".jpg");
        return cache_icon;
    }
    private static string cache_folder () {
        var cache_dir = File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir (), Environment.get_application_name()));
        if (!cache_dir.query_exists ()) {
            try {
                cache_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
        return cache_dir.get_path ();
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
        return GLib.Path.build_path (Path.DIR_SEPARATOR_S, media_directory, "Niki");
    }

    private string profile_name () {
        const string[] filenames = {"mp4", "ogv", "webm", "mkv"};
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
    public Gdk.Pixbuf? align_and_scale_pixbuf (Gdk.Pixbuf input_pixbuf, int size) {
        Gdk.Pixbuf pixbuf_scale = input_pixbuf;
        pixbuf_scale = pixbuf_scale.scale_simple (size, size, Gdk.InterpType.BILINEAR);
        return pixbuf_scale;
    }

    private Gdk.Pixbuf? unknow_cover () {
        Gdk.Pixbuf pixbuf_unknow;
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
        pixbuf_unknow = Gdk.pixbuf_get_from_surface (surface, 0, 0, 256, 256);
        return pixbuf_unknow;
    }

    private string protocol_Info (){
        string join_string = string.join (",", "http-get:*:video/mp4:DLNA.ORG_PN=AVC_MP4_BL_CIF15_AAC_520", "http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_HD_NA_ISO", "http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_NA_ISO", "http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_EU_ISO", "http-get:*:audio/x-ms-wma:DLNA.ORG_PN=WMAPRO", "http-get:*:audio/x-ms-wma:DLNA.ORG_PN=WMAFULL", "http-get:*:audio/x-ms-wma:DLNA.ORG_PN=WMABASE", "http-get:*:audio/l16;rate=44100;channels=1:DLNA.ORG_PN=LPCM", "http-get:*:audio/l16;rate=44100;channels=2:DLNA.ORG_PN=LPCM", "http-get:*:audio/3gpp:DLNA.ORG_PN=AAC_ISO_320", "http-get:*:audio/mp4:DLNA.ORG_PN=AAC_ISO_320", "http-get:*:audio/vnd.dlna.adts:DLNA.ORG_PN=AAC_ADTS_320", "http-get:*:audio/mpeg:DLNA.ORG_PN=MP3X", "http-get:*:audio/mpeg:DLNA.ORG_PN=MP3", "http-get:*:image/png:DLNA.ORG_PN=PNG_LRG", "http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_LRG", "http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_MED", "http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_SM", "http-get:*:text/xml:DLNA.ORG_PN=DIDL_S", "rtsp:*:video/mp4:DLNA.ORG_PN=AVC_MP4_BL_CIF15_AAC_520", "rtsp:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_HD_NA_ISO", "rtsp:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_NA_ISO", "rtsp:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_EU_ISO", "rtsp:*:audio/x-ms-wma:DLNA.ORG_PN=WMAPRO", "rtsp:*:audio/x-ms-wma:DLNA.ORG_PN=WMAFULL", "rtsp:*:audio/x-ms-wma:DLNA.ORG_PN=WMABASE", "rtsp:*:audio/l16;rate=44100;channels=1:DLNA.ORG_PN=LPCM", "rtsp:*:audio/l16;rate=44100;channels=2:DLNA.ORG_PN=LPCM", "rtsp:*:audio/3gpp:DLNA.ORG_PN=AAC_ISO_320", "rtsp:*:audio/mp4:DLNA.ORG_PN=AAC_ISO_320", "rtsp:*:audio/vnd.dlna.adts:DLNA.ORG_PN=AAC_ADTS_320", "rtsp:*:audio/mpeg:DLNA.ORG_PN=MP3X", "rtsp:*:audio/mpeg:DLNA.ORG_PN=MP3", "rtsp:*:image/png:DLNA.ORG_PN=PNG_LRG", "rtsp:*:image/jpeg:DLNA.ORG_PN=JPEG_LRG", "rtsp:*:image/jpeg:DLNA.ORG_PN=JPEG_MED", "rtsp:*:image/jpeg:DLNA.ORG_PN=JPEG_SM", "rtsp:*:text/xml:DLNA.ORG_PN=DIDL_S", "http-get:*:audio/mpeg:*", "http-get:*:application/ogg:*", "http-get:*:audio/x-vorbis:*", "http-get:*:audio/x-vorbis+ogg:*", "http-get:*:audio/ogg:*", "http-get:*:audio/x-ms-wma:*", "http-get:*:audio/x-ms-asf:*", "http-get:*:audio/x-flac:*", "http-get:*:audio/x-flac+ogg:*", "http-get:*:audio/flac:*", "http-get:*:audio/mp4:*", "http-get:*:audio/3gpp:*", "http-get:*:audio/vnd.dlna.adts:*", "http-get:*:audio/x-mod:*", "http-get:*:audio/x-wav:*", "http-get:*:audio/wav:*", "http-get:*:audio/x-ac3:*", "http-get:*:audio/x-m4a:*", "http-get:*:audio/l16;rate=44100;channels=2:*", "http-get:*:audio/l16;rate=44100;channels=1:*", "http-get:*:audio/l16;channels=2;rate=44100:*", "http-get:*:audio/l16;channels=1;rate=44100:*", "http-get:*:audio/l16;rate=44100:*", "http-get:*:image/jpeg:*", "http-get:*:image/png:*", "http-get:*:video/x-theora:*", "http-get:*:video/x-theora+ogg:*", "http-get:*:video/x-oggm:*", "http-get:*:video/ogg:*", "http-get:*:video/x-dirac:*", "http-get:*:video/x-wmv:*", "http-get:*:video/x-wma:*", "http-get:*:video/x-msvideo:*", "http-get:*:video/x-3ivx:*", "http-get:*:video/x-3ivx:*", "http-get:*:video/x-matroska:*", "http-get:*:video/x-mkv:*", "http-get:*:video/mpeg:*", "http-get:*:video/mp4:*", "http-get:*:application/x-shockwave-flash:*", "http-get:*:video/x-ms-asf:*", "http-get:*:video/x-xvid:*", "http-get:*:video/x-ms-wmv:*", "http-get:*:audio/mpegurl:*", "http-get:*:audio/x-mpegurl:*", "http-get:*:video/mpegurl:*", "http-get:*:video/x-mpegurl:*", "rtsp:*:audio/mpeg:*", "rtsp:*:application/ogg:*", "rtsp:*:audio/x-vorbis:*", "rtsp:*:audio/x-vorbis+ogg:*", "rtsp:*:audio/ogg:*", "rtsp:*:audio/x-ms-wma:*", "rtsp:*:audio/x-ms-asf:*", "rtsp:*:audio/x-flac:*", "rtsp:*:audio/x-flac+ogg:*", "rtsp:*:audio/flac:*", "rtsp:*:audio/mp4:*", "rtsp:*:audio/3gpp:*", "rtsp:*:audio/vnd.dlna.adts:*", "rtsp:*:audio/x-mod:*", "rtsp:*:audio/x-wav:*", "rtsp:*:audio/wav:*", "rtsp:*:audio/x-ac3:*", "rtsp:*:audio/x-m4a:*", "rtsp:*:audio/l16;rate=44100;channels=2:*", "rtsp:*:audio/l16;rate=44100;channels=1:*", "rtsp:*:audio/l16;channels=2;rate=44100:*", "rtsp:*:audio/l16;channels=1;rate=44100:*", "rtsp:*:audio/l16;rate=44100:*", "rtsp:*:image/jpeg:*", "rtsp:*:image/png:*", "rtsp:*:video/x-theora:*", "rtsp:*:video/x-theora+ogg:*", "rtsp:*:video/x-oggm:*", "rtsp:*:video/ogg:*", "rtsp:*:video/x-dirac:*", "rtsp:*:video/x-wmv:*", "rtsp:*:video/x-wma:*", "rtsp:*:video/x-msvideo:*", "rtsp:*:video/x-3ivx:*", "rtsp:*:video/x-3ivx:*", "rtsp:*:video/x-matroska:*", "rtsp:*:video/x-mkv:*", "rtsp:*:video/mpeg:*", "rtsp:*:video/mp4:*", "rtsp:*:application/x-shockwave-flash:*", "rtsp:*:video/x-ms-asf:*", "rtsp:*:video/x-xvid:*", "rtsp:*:video/x-ms-wmv:*", "rtsp:*:audio/mpegurl:*", "rtsp:*:audio/x-mpegurl:*", "rtsp:*:video/mpegurl:*", "rtsp:*:video/x-mpegurl:*");
        return join_string;
    }
}
