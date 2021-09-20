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
	[CCode (cheader_filename = "inytag.h", cname = "InyTag_File", free_function = "inytag_file_free")]
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
		public unowned AudioProperties audioproperties {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_mpeg_file_audioproperties")]
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
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_add_text_frame")]
		public void add_text_frame (Frame_ID frameid, string text);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_get_text_frame")]
		public string get_text_frame (Frame_ID frameid);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_get_picture_frame")]
		public ID3v2_Attached_Picture_Frame get_picture_frame (Img_Type type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_add_comment_frame")]
		public void add_comment_frame (Attached_Comment_Frame frame);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_is_frame_empty")]
		public bool is_frame_empty (Frame_ID frameid);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_remove_frame")]
		public void remove_frame (Frame_ID frameid);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_tag_remove_all")]
		public void remove_all ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_id3v2_attached_comment_frame_free", cname = "InyTag_ID3v2_Attached_Comment_Frame")]
	[Compact]
	public class Attached_Comment_Frame {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_comment_frame_new")]
		public Attached_Comment_Frame ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_comment_frame_set_encording")]
		public void set_encording (String_Type type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_comment_frame_set_text")]
		public void set_text (string text);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_comment_frame_set_language")]
		public void set_language (string lang);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_comment_frame_set_description")]
		public void set_description (string desc);
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_id3v2_attached_picture_frame_free", cname = "InyTag_ID3v2_Attached_Picture_Frame")]
	[Compact]
	public class ID3v2_Attached_Picture_Frame {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_new")]
		public ID3v2_Attached_Picture_Frame ();
		public unowned Img_Type type {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_get_type")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_type")]
			set;
		}
		public unowned string mime_type {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_get_mime_type")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_mime_type")]
			set;
		}
		public unowned string description {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_get_description")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_description")]
			set;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_picture")]
		public void set_picture (string path);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_get_picture")]
		public ByteVector get_picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_id3v2_attached_picture_frame_set_picture_form_bytevector")]
		public void set_picture_form_bytevector (ByteVector bytevector);
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_bytevector_free", cname = "InyTag_ByteVector")]
	[Compact]
	public class ByteVector {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_bytevector_new")]
		public ByteVector ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_bytevector_get_data")]
		public unowned char get_data ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_bytevector_get_size")]
		public unowned int get_size ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_bytevector_get_pixbuf")]
		public unowned Gdk.Pixbuf get_pixbuf ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_bytevector_set_pixbuf")]
		public void set_pixbuf (Gdk.Pixbuf pixbuf);
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
		public unowned AudioProperties audioproperties {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_audioproperties")]
			get;
		}
		public unowned Tag_MP4 tag_mp4 {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4")]
			get;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_remove_picture")]
		public void remove_picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_file_save")]
		public bool save ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "InyTag_Tag_MP4")]
	[Compact]
	public class Tag_MP4 {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4_remove_item")]
		public void remove_item (string contains);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4_add_item")]
		public void add_item (string contains);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4_set_item_string")]
		public void set_item_string (string contains, string item);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4_get_item_string")]
		public string get_item_string (string contains);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4_set_item_picture")]
		public void set_item_picture (Mp4_Picture picture);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_tag_mp4_get_item_picture")]
		public Mp4_Picture get_item_picture ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_mp4_picture_free")]
	[Compact]
	public class Mp4_Picture {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_picture_new")]
		public Mp4_Picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_picture_set_file")]
		public void set_file (Format_Type type, string filename);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_mp4_picture_get_picture")]
		public ByteVector get_picture (Format_Type type);
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
		public unowned ID3v2_Tag flac_id3v2_tag {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_file_flac_id3v2_tag")]
			get;
		}
		public unowned AudioProperties audioproperties {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_audioproperties")]
			get;
		}
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_remove_all_picture")]
		public void remove_all_picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_remove_picture")]
		public void remove_picture (Img_Type type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_add_picture")]
		public void add_picture(Flac_Picture picture);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_get_picture")]
		public Flac_Picture get_picture (Img_Type type);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_file_save")]
		public bool save ();
	}

	[CCode (cheader_filename = "inytag.h", free_function = "inytag_flac_picture_free")]
	[Compact]
	public class Flac_Picture {
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_new")]
		public Flac_Picture ();
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_picture")]
		public void set_picture (string imgpath);
		[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_picture")]
		public ByteVector get_picture ();
		public string mime_type {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_mime_type")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_mime_type")]
			set;
		}
		public string description {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_description")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_description")]
			set;
		}
		public Img_Type type {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_type")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_type")]
			set;
		}
		public int width {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_width")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_width")]
			set;
		}
		public int height {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_height")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_height")]
			set;
		}
		public int num_colors {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_get_num_colors")]
			get;
			[CCode (cheader_filename = "inytag.h", cname = "inytag_flac_picture_set_num_colors")]
			set;
		}
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
		public int length_seconds {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_audioproperties_length_seconds")]
			get;
		}
		public int length_miliseconds {
			[CCode (cheader_filename = "inytag.h", cname = "inytag_audioproperties_length_miliseconds")]
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

	[CCode (cheader_filename = "inytag.h", cname = "InyTag_String_Type")]
	public enum String_Type {
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_String_LATIN")]
		LATIN,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_String_UTF16")]
		UTF16,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_String_UTF16BE")]
		UTF16BE,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_String_UTF8")]
		UTF8,
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_String_UTF16LE")]
		UTF16LE
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
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_COMMENT")]
		COMMENT,	 	  //Comments
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_COMMERCIAL")]
		COMMERCIAL,	  //Commercial frame
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_CRYPTOREG")]
		CRYPTOREG,	  //Encryption method registration
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_EQUALIZATION")]
		EQUALIZATION, 	  //Equalization
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_EVENTTIMING")]
		EVENTTIMING, 	  //Event timing codes
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_GENERALOBJECT")]
		GENERALOBJECT,	  //General encapsulated object 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_GROUPINGREG")]
		GROUPINGREG,      //Group identification registration 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_INVOLVEDPEOPLE")]
		INVOLVEDPEOPLE,   //Involved people list 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_LINKEDINFO")]
		LINKEDINFO,       //Linked information 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_CDID")]
		CDID,             //Music CD identifier 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_MPEGLOOKUP")]
		MPEGLOOKUP,       //MPEG location lookup table 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_OWNERSHIP")]
		OWNERSHIP,        //Ownership frame 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_PRIVATE")]
		PRIVATE,          //Private frame 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_PLAYCOUNTER")]
		PLAYCOUNTER,      //Play counter 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_POPULARIMETER")]
		POPULARIMETER,    //Popularimeter 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_POSITIONSYNC")]
		POSITIONSYNC,     //Position synchronisation frame 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_BUFFERSIZE")]
		BUFFERSIZE,       //Recommended buffer size 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_VOLUMEADJ")]
		VOLUMEADJ,        //Relative volume adjustment 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_REVERB")]
		REVERB,           //Reverb 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_SYNCEDLYRICS")]
		SYNCEDLYRICS,     //Synchronized lyric/text 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_SYNCEDTEMPO")]
		SYNCEDTEMPO,      //Synchronized tempo codes 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ALBUM")]
		ALBUM,            //Album/Movie/Show title 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_BPM")]
		BPM,              //BPM (beats per minute) 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_COMPOSER")]
		COMPOSER,         //Composer 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_CONTENTTYPE")]
		CONTENTTYPE,      //Content type 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_COPYRIGHT")]
		COPYRIGHT,        //Copyright message 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_DATE")]
		DATE,             //Date 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_PLAYLISTDELAY")]
		PLAYLISTDELAY,    //Playlist delay 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ENCODEDBY")]
		ENCODEDBY,        //Encoded by 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_LYRICIST")]
		LYRICIST,         //Lyricist/Text writer 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_FILETYPE")]
		FILETYPE,         //File type 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_TIME")]
		TIME,             //Time 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_CONTENTGROUP")]
		CONTENTGROUP,     //Content group description 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_TITLE")]
		TITLE,            //Title/songname/content description 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_SUBTITLE")]
		SUBTITLE,         //Subtitle/Description refinement 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_INITIALKEY")]
		INITIALKEY,       //Initial key 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_LANGUAGE")]
		LANGUAGE,         //Language(s) 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_SONGLEN")]
		SONGLEN,          //Length 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_MEDIATYPE")]
		MEDIATYPE,        //Media type 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ORIGALBUM")]
		ORIGALBUM,        //Original album/movie/show title 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ORIGFILENAME")]
		ORIGFILENAME,     //Original filename 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ORIGLYRICIST")]
		ORIGLYRICIST,     //Original lyricist(s)/text writer(s) 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ORIGARTIST")]
		ORIGARTIST,       //Original artist(s)/performer(s) 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ORIGYEAR")]
		ORIGYEAR,         //Original release year 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_FILEOWNER")]
		FILEOWNER,        //File owner/licensee 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_LEADARTIST")]
		LEADARTIST,       //Lead performer(s)/Soloist(s) 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_BAND")]
		BAND,             //Band/orchestra/accompaniment 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_CONDUCTOR")]
		CONDUCTOR,        //Conductor/performer refinement 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_MIXARTIST")]
		MIXARTIST,        //Interpreted, remixed, or otherwise modified by 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_PARTINSET")]
		PARTINSET,        //Part of a set 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_PUBLISHER")]
		PUBLISHER,        //Publisher 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_TRACKNUM")]
		TRACKNUM,         //Track number/Position in set 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_RECORDINGDATES")]
		RECORDINGDATES,   //Recording dates  
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_NETRADIOSTATION")]
		NETRADIOSTATION,  //Internet radio station name 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_NETRADIOOWNER")]
		NETRADIOOWNER,    //Internet radio station owner 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_SIZE")]
		SIZE,             //Size 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ISRC")]
		ISRC,             //ISRC (international standard recording code) 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_ENCODERSETTINGS")]
		ENCODERSETTINGS,  //Software/Hardware and settings used for encoding 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_USERTEXT")]
		USERTEXT,         //User defined text information 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_YEAR")]
		YEAR,             //Year 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_YEARV2")]
		YEARV2,             //Year TDRC
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_UNIQUEFILEID")]
		UNIQUEFILEID,     //Unique file identifier 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_TERMSOFUSE")]
		TERMSOFUSE,       //Terms of use 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_UNSYNCEDLYRICS")]
		UNSYNCEDLYRICS,   //Unsynchronized lyric/text transcription 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWCOMMERCIALINFO")]
		WWWCOMMERCIALINFO,//Commercial information 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWCOPYRIGHT")]
		WWWCOPYRIGHT,     //Copyright/Legal infromation 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWAUDIOFILE")]
		WWWAUDIOFILE,     //Official audio file webpage 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWARTIST")]
		WWWARTIST,        //Official artist/performer webpage 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWAUDIOSOURCE")]
		WWWAUDIOSOURCE,   //Official audio source webpage 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWRADIOPAGE")]
		WWWRADIOPAGE,     //Official internet radio station homepage 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWPAYMENT")]
		WWWPAYMENT,       //Payment 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWPUBLISHER")]
		WWWPUBLISHER,     //Official publisher webpage 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_WWWUSER")]
		WWWUSER,          //User defined URL link 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_METACRYPTO")]
		METACRYPTO,       //Encrypted meta frame 
		[CCode (cheader_filename = "inytag.h", cname = "InyTag_Frame_NOFRAME")]
		NOFRAME           //Error
	}
}