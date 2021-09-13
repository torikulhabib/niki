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
	[CCode (cheader_filename = "inytag.h", free_function = "inytag_set_strings_unicode")]
	public static void set_strings_unicode (bool unicode);
	[CCode (cheader_filename = "inytag.h", free_function = "inytag_file_free")]
	[Compact]
	public class File {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_file_new")]
		public File (string filename);
		public unowned Tag tag {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_file_tag")]
			get;
		}
		public unowned AudioProperties audioproperties {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_file_audioproperties")]
			get;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_file_save")]
		public bool save ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_id3v2_attached_picture_frame_free", cname = "InyTag_ID3v2_Attached_Picture_Frame")]
	[Compact]
	public class ID3v2_Attached_Picture_Frame {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_new")]
		public ID3v2_Attached_Picture_Frame ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_type")]
		public void set_type (Img_Type type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_mime_type")]
		public void set_mime_type (string type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_picture")]
		public void set_picture (string path);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_description")]
		public void set_description (string desc);
	}

	[CCode (cheader_filename = "inytag.h", cname = "InyTag_Mpeg_File", free_function = "inytag_mpeg_file_free")]
	[Compact]
	public class Mpeg_File {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mpeg_file_new")]
		public Mpeg_File (string filename);
		public unowned Tag mpeg_tag {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_file_mpeg_tag")]
			get;
		}
		public unowned ID3v2_Tag id3v2_tag {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag")]
			get;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mpeg_file_save")]
		public bool save ();
	}

	[CCode (cheader_filename = "inytag.h", cname = "InyTag_ID3v2_Tag")]
	[Compact]
	public class ID3v2_Tag {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_add_picture_frame")]
		public void add_picture_frame (ID3v2_Attached_Picture_Frame frame);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_is_frame_empty")]
		public bool is_frame_empty (Frame_ID frameid);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_remove_frame")]
		public void remove_frame (Frame_ID frameid);
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_mp4_file_free", cname = "InyTag_Mp4_File")]
	[Compact]
	public class Mp4_File {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_new")]
		public Mp4_File (string filename);
		public unowned Tag mp4_tag {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_file_mp4_tag")]
			get;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_remove_picture")]
		public void remove_picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_set_picture")]
		public void set_picture (Format_Type type, string imgpath);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_save")]
		public bool save ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_flac_picture_free")]
	[Compact]
	public class Flac_Picture {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_new")]
		public Flac_Picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_picture")]
		public void set_picture (string imgpath);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_mime_type")]
		public void set_mime_type (string mimetype);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_description")]
		public void set_description (string description);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_type")]
		public void set_type (Img_Type type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_width")]
		public void set_width (int width);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_height")]
		public void set_height (int height);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_num_colors")]
		public void set_num_colors (int numcolors);
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_flac_file_free")]
	[Compact]
	public class Flac_File {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_new")]
		public Flac_File (string filename);
		public unowned Tag flac_tag {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_file_flac_tag")]
			get;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_remove_picture")]
		public void remove_picture();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_add_picture")]
		public void add_picture(Flac_Picture picture);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_save")]
		public bool save ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "", cname = "InyTag_Tag")]
	[Compact]
	[Immutable]
	public class Tag {
		public unowned string title {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_title")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_title")]
			set;
		}
		public unowned string artist {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_artist")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_artist")]
			set;
		}
		public unowned string album {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_album")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_album")]
			set;
		}
		public unowned string comment {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_comment")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_comment")]
			set;
		}
		public unowned string genre {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_genre")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_genre")]
			set;
		}
		public int year {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_year")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_year")]
			set;
		}
		public int track {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_track")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_set_track")]
			set;
		}
	}

	[CCode (cheader_filename = "inytag.h", free_function = "", cname = "InyTag_AudioProperties")]
	[Compact]
	[Immutable]
	public class AudioProperties {
		public int length {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_audioproperties_length")]
			get;
		}
		public int bitrate {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_audioproperties_bitrate")]
			get;
		}
		public int samplerate {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_audioproperties_samplerate")]
			get;
		}
		public int channels {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_audioproperties_channels")]
			get;
		}
	}

	[CCode (cheader_filename = "inytag.h", cname = "InyTag_Format_Type")]
	public enum Format_Type {
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Format_JPEG")]
  		JPEG,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Format_PNG")]
  		PNG,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Format_BMP")]
	  	BMP,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Format_GIF")]
	  	GIF,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Format_UNKNOWN")]
		UNKNOWN
	}

	[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Type")]
	public enum Img_Type {
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Other")]
		Other,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_FileIcon")]
		FileIcon,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_OtherFileIcon")]
		OtherFileIcon,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_FrontCover")]
		FrontCover,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_BackCover")]
		BackCover,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_LeafletPage")]
		LeafletPage,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Media")]
		Media,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_LeadArtist")]
		LeadArtist,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Artist")]
		Artist,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Conductor")]
		Conductor,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Band")]
		Band,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Composer")]
		Composer,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Lyricist")]
		Lyricist,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_RecordingLocation")]
		RecordingLocation,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_DuringRecording")]
		DuringRecording,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_DuringPerformance")]
		DuringPerformance,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_MovieScreenCapture")]
		MovieScreenCapture,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_ColouredFish")]
		ColouredFish,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_Illustration")]
		Illustration,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_BandLogo")]
		BandLogo,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Img_PublisherLogo")]
		PublisherLogo
	}

	[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ID")]
	public enum Frame_ID {
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_AUDIOCRYPTO")]
		AUDIOCRYPTO,  	  //Audio encryption
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_PICTURE")]
		PICTURE,	 	  //Attached picture
		COMMENT,	 	  //Comments
		COMMERCIAL,	  //Commercial frame
		CRYPTOREG,	  //Encryption method registration
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