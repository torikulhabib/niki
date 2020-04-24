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


[CCode (cprefix = "InyTag_", lower_case_cprefix = "inytag_", cheader_filename = "inytag.h")]
namespace InyTag {
	public static void set_strings_unicode (bool unicode);
	[CCode (free_function = "inytag_file_free")]
	[Compact]
	public class File {
		public File (string filename);
		public unowned Tag tag {
			[CCode (cname = "inytag_file_tag")]
			get;
		}
		public unowned AudioProperties audioproperties {
			[CCode (cname = "inytag_file_audioproperties")]
			get;
		}
		public bool save ();
	}

	[CCode (free_function = "inytag_id3v2_attached_picture_frame_free")]
	[Compact]
	public class ID3v2_Attached_Picture_Frame {
		public ID3v2_Attached_Picture_Frame ();
		public void set_type (Img_Type type);
		public void set_mime_type (string type);
		public void set_picture (string path);
		public void set_description (string desc);
	}

	[CCode (free_function = "inytag_mpeg_file_free")]
	[Compact]
	public class Mpeg_File {
		public Mpeg_File (string filename);
		public unowned Tag mpeg_tag {
			[CCode (cname = "inytag_file_mpeg_tag")]
			get;
		}
		public unowned ID3v2_Tag id3v2_tag {
			[CCode (cname = "inytag_id3v2_tag")]
			get;
		}
		public bool save ();
	}
	[CCode (free_function = "")]
	[Compact]
	public class ID3v2_Tag {
		public void add_picture_frame (ID3v2_Attached_Picture_Frame frame);
		public bool is_frame_empty (Frame_ID frameid);
		public void remove_frame (Frame_ID frameid);
	}
	[CCode (free_function = "inytag_mp4_file_free")]
	[Compact]
	public class Mp4_File {
		public Mp4_File (string filename);
		public unowned Tag mp4_tag {
			[CCode (cname = "inytag_file_mp4_tag")]
			get;
		}
		public void remove_picture ();
		public void set_picture (Format_Type type, string imgpath);
		public bool save ();
	}

	[CCode (free_function = "inytag_flac_picture_free")]
	[Compact]
	public class Flac_Picture {
		public Flac_Picture ();
		public void set_picture (string imgpath);
		public void set_mime_type (string mimetype);
		public void set_description (string description);
		public void set_type (Img_Type type);
		public void set_width (int width);
		public void set_height (int height);
		public void set_num_colors (int numcolors);
	}

	[CCode (free_function = "inytag_flac_file_free")]
	[Compact]
	public class Flac_File {
		public Flac_File (string filename);
		public unowned Tag flac_tag {
			[CCode (cname = "inytag_file_flac_tag")]
			get;
		}
		public void remove_picture();
		public void add_picture(Flac_Picture picture);
		public bool save ();
	}

	[CCode (free_function = "")]
	[Compact]
	public class Tag {
		public unowned string title {
			[CCode (cname = "inytag_tag_title")]
			get;
			set;
		}
		public unowned string artist {
			[CCode (cname = "inytag_tag_artist")]
			get;
			set;
		}
		public unowned string album {
			[CCode (cname = "inytag_tag_album")]
			get;
			set;
		}
		public unowned string comment {
			[CCode (cname = "inytag_tag_comment")]
			get;
			set;
		}
		public unowned string genre {
			[CCode (cname = "inytag_tag_genre")]
			get;
			set;
		}
		public uint year {
			[CCode (cname = "inytag_tag_year")]
			get;
			set;
		}
		public uint track {
			[CCode (cname = "inytag_tag_track")]
			get;
			set;
		}
	}

	[CCode (free_function = "", cname = "InyTag_AudioProperties")]
	[Compact]
	[Immutable]
	public class AudioProperties {
		public int length {
			[CCode (cname = "inytag_audioproperties_length")]
			get;
		}
		public int bitrate {
			[CCode (cname = "inytag_audioproperties_bitrate")]
			get;
		}
		public int samplerate {
			[CCode (cname = "inytag_audioproperties_samplerate")]
			get;
		}
		public int channels {
			[CCode (cname = "inytag_audioproperties_channels")]
			get;
		}
	}

	[CCode (cname = "InyTag_Format_Type", cprefix = "InyTag_Format_", has_type_id = false)]
	public enum Format_Type {
  		JPEG,
  		PNG,
	  	BMP,
	  	GIF,
	    UNKNOWN
	}

	[CCode (cname = "InyTag_Img_Type", cprefix = "InyTag_Img_", has_type_id = false)]
	public enum Img_Type {
  		Other,
  		FileIcon,
	  	OtherFileIcon,
	  	FrontCover,
	    BackCover,
	    LeafletPage,
	    Media,
	    LeadArtist,
	    Artist,
	    Conductor,
	    Band,
	    Composer,
	    Lyricist,
	    RecordingLocation,
	    DuringRecording,
	    DuringPerformance,
	    MovieScreenCapture,
	    ColouredFish,
	    Illustration,
	    BandLogo,
	    PublisherLogo
	}

	[CCode (cname = "InyTag_Frame_ID", cprefix = "InyTag_Frame_", has_type_id = false)]
	public enum Frame_ID {
		AUDIOCRYPTO,  	  //Audio encryption
		PICTURE,	 	  //Attached picture
		COMMENT,	 	  //Comments
		COMMERCIAL,	   	  //Commercial frame
		CRYPTOREG,	 	  //Encryption method registration
		EQUALIZATION, 	  //Equalization
		EVENTTIMING, 	  //Event timing codes
		GENERALOBJECT,	  //General encapsulated object 
		GROUPINGREG,      //Group identification registration 
		INVOLVEDPEOPLE,   //Involved people list 
		LINKEDINFO,       //Linked information 
		CDID,             //Music CD identifier 
		MPEGLOOKUP,       //MPEG location lookup table 
		OWNERSHIP,        //Ownership frame 
		PRIVATE,          //Private frame 
		PLAYCOUNTER,      //Play counter 
		POPULARIMETER,    //Popularimeter 
		POSITIONSYNC,     //Position synchronisation frame 
		BUFFERSIZE,       //Recommended buffer size 
		VOLUMEADJ,        //Relative volume adjustment 
		REVERB,           //Reverb 
		SYNCEDLYRICS,     //Synchronized lyric/text 
		SYNCEDTEMPO,      //Synchronized tempo codes 
		ALBUM,            //Album/Movie/Show title 
		BPM,              //BPM (beats per minute) 
		COMPOSER,         //Composer 
		CONTENTTYPE,      //Content type 
		COPYRIGHT,        //Copyright message 
		DATE,             //Date 
		PLAYLISTDELAY,    //Playlist delay 
		ENCODEDBY,        //Encoded by 
		LYRICIST,         //Lyricist/Text writer 
		FILETYPE,         //File type 
		TIME,             //Time 
		CONTENTGROUP,     //Content group description 
		TITLE,            //Title/songname/content description 
		SUBTITLE,         //Subtitle/Description refinement 
		INITIALKEY,       //Initial key 
		LANGUAGE,         //Language(s) 
		SONGLEN,          //Length 
		MEDIATYPE,        //Media type 
		ORIGALBUM,        //Original album/movie/show title 
		ORIGFILENAME,     //Original filename 
		ORIGLYRICIST,     //Original lyricist(s)/text writer(s) 
		ORIGARTIST,       //Original artist(s)/performer(s) 
		ORIGYEAR,         //Original release year 
		FILEOWNER,        //File owner/licensee 
		LEADARTIST,       //Lead performer(s)/Soloist(s) 
		BAND,             //Band/orchestra/accompaniment 
		CONDUCTOR,        //Conductor/performer refinement 
		MIXARTIST,        //Interpreted, remixed, or otherwise modified by 
		PARTINSET,        //Part of a set 
		PUBLISHER,        //Publisher 
		TRACKNUM,         //Track number/Position in set 
		RECORDINGDATES,   //Recording dates  
		NETRADIOSTATION,  //Internet radio station name 
		NETRADIOOWNER,    //Internet radio station owner 
		SIZE,             //Size 
		ISRC,             //ISRC (international standard recording code) 
		ENCODERSETTINGS,  //Software/Hardware and settings used for encoding 
		USERTEXT,         //User defined text information 
		YEAR,             //Year 
		UNIQUEFILEID,     //Unique file identifier 
		TERMSOFUSE,       //Terms of use 
		UNSYNCEDLYRICS,   //Unsynchronized lyric/text transcription 
		WWWCOMMERCIALINFO,//Commercial information 
		WWWCOPYRIGHT,     //Copyright/Legal infromation 
		WWWAUDIOFILE,     //Official audio file webpage 
		WWWARTIST,        //Official artist/performer webpage 
		WWWAUDIOSOURCE,   //Official audio source webpage 
		WWWRADIOPAGE,     //Official internet radio station homepage 
		WWWPAYMENT,       //Payment 
		WWWPUBLISHER,     //Official publisher webpage 
		WWWUSER,          //User defined URL link 
		METACRYPTO,       //Encrypted meta frame 
		NOFRAME           //Error
	}
}

