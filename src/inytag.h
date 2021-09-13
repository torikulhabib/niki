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

#ifndef INYTAG_TAG_C
#define INYTAG_TAG_C

#ifndef DO_NOT_DOCUMENT

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__GNUC__) && (__GNUC__ > 4 || __GNUC__ == 4 && __GNUC_MINOR__ >= 1)
#define INYTAG_C_EXPORT __attribute__ ((visibility("default")))
#else
#define INYTAG_C_EXPORT
#endif

#ifndef BOOL
#define BOOL int
#endif

typedef struct { int dummy; } InyTag_File;
typedef struct { int dummy; } InyTag_Tag;
typedef struct { int dummy; } InyTag_AudioProperties;
typedef struct { int dummy; } InyTag_Mpeg_File;
typedef struct { int dummy; } InyTag_Mp4_File;
typedef struct { int dummy; } InyTag_Flac_File;
typedef struct { int dummy; } InyTag_Flac_Picture;
typedef struct { int dummy; } InyTag_ID3v2_Tag;
typedef struct { int dummy; } InyTag_ID3v2_Attached_Picture_Frame;

INYTAG_C_EXPORT void inytag_set_strings_unicode(BOOL unicode);
INYTAG_C_EXPORT void inytag_free(void* pointer);

typedef enum {
    InyTag_Img_Other,
    InyTag_Img_FileIcon,
    InyTag_Img_OtherFileIcon,
    InyTag_Img_FrontCover,
    InyTag_Img_BackCover,
    InyTag_Img_LeafletPage,
    InyTag_Img_Media,
    InyTag_Img_LeadArtist,
    InyTag_Img_Artist,
    InyTag_Img_Conductor,
    InyTag_Img_Band,
    InyTag_Img_Composer,
    InyTag_Img_Lyricist,
    InyTag_Img_RecordingLocation,
    InyTag_Img_DuringRecording,
    InyTag_Img_DuringPerformance,
    InyTag_Img_MovieScreenCapture,
    InyTag_Img_ColouredFish,
    InyTag_Img_Illustration,
    InyTag_Img_BandLogo,
    InyTag_Img_PublisherLogo
} InyTag_Img_Type;

typedef enum {
    InyTag_Format_JPEG,
    InyTag_Format_PNG,
    InyTag_Format_BMP,
    InyTag_Format_GIF,
    InyTag_Format_UNKNOWN
} InyTag_Format_Type;

typedef enum {
    InyTag_Frame_AUDIOCRYPTO,  	//Audio encryption
    InyTag_Frame_PICTURE,	 	//Attached picture
    InyTag_Frame_COMMENT,	 	//Comments
    InyTag_Frame_COMMERCIAL,	     //Commercial frame
    InyTag_Frame_CRYPTOREG,	 	//Encryption method registration
    InyTag_Frame_EQUALIZATION, 	//Equalization
    InyTag_Frame_EVENTTIMING, 	//Event timing codes
    InyTag_Frame_GENERALOBJECT,	//General encapsulated object 
    InyTag_Frame_GROUPINGREG,      //Group identification registration 
    InyTag_Frame_INVOLVEDPEOPLE,   //Involved people list 
    InyTag_Frame_LINKEDINFO,       //Linked information 
    InyTag_Frame_CDID,             //Music CD identifier 
    InyTag_Frame_MPEGLOOKUP,       //MPEG location lookup table 
    InyTag_Frame_OWNERSHIP,        //Ownership frame 
    InyTag_Frame_PRIVATE,          //Private frame 
    InyTag_Frame_PLAYCOUNTER,      //Play counter 
    InyTag_Frame_POPULARIMETER,    //Popularimeter 
    InyTag_Frame_POSITIONSYNC,     //Position synchronisation frame 
    InyTag_Frame_BUFFERSIZE,       //Recommended buffer size 
    InyTag_Frame_VOLUMEADJ,        //Relative volume adjustment 
    InyTag_Frame_REVERB,           //Reverb 
    InyTag_Frame_SYNCEDLYRICS,     //Synchronized lyric/text 
    InyTag_Frame_SYNCEDTEMPO,      //Synchronized tempo codes 
    InyTag_Frame_ALBUM,            //Album/Movie/Show title 
    InyTag_Frame_BPM,              //BPM (beats per minute) 
    InyTag_Frame_COMPOSER,         //Composer 
    InyTag_Frame_CONTENTTYPE,      //Content type 
    InyTag_Frame_COPYRIGHT,        //Copyright message 
    InyTag_Frame_DATE,             //Date 
    InyTag_Frame_PLAYLISTDELAY,    //Playlist delay 
    InyTag_Frame_ENCODEDBY,        //Encoded by 
    InyTag_Frame_LYRICIST,         //Lyricist/Text writer 
    InyTag_Frame_FILETYPE,         //File type 
    InyTag_Frame_TIME,             //Time 
    InyTag_Frame_CONTENTGROUP,     //Content group description 
    InyTag_Frame_TITLE,            //Title/songnamInyTag_Frame_IDe/content description 
    InyTag_Frame_SUBTITLE,         //Subtitle/Description refinement 
    InyTag_Frame_INITIALKEY,       //Initial key 
    InyTag_Frame_LANGUAGE,         //Language(s) 
    InyTag_Frame_SONGLEN,          //Length 
    InyTag_Frame_MEDIATYPE,        //Media type 
    InyTag_Frame_ORIGALBUM,        //Original album/movie/show title 
    InyTag_Frame_ORIGFILENAME,     //Original filename 
    InyTag_Frame_ORIGLYRICIST,     //Original lyricist(s)/text writer(s) 
    InyTag_Frame_ORIGARTIST,       //Original artist(s)/performer(s) 
    InyTag_Frame_ORIGYEAR,         //Original release year 
    InyTag_Frame_FILEOWNER,        //File owner/licensee 
    InyTag_Frame_LEADARTIST,       //Lead performer(s)/Soloist(s) 
    InyTag_Frame_BAND,             //Band/orchestra/accompaniment 
    InyTag_Frame_CONDUCTOR,        //Conductor/performer refinement 
    InyTag_Frame_MIXARTIST,        //Interpreted, remixed, or otherwise modified by 
    InyTag_Frame_PARTINSET,        //Part of a set 
    InyTag_Frame_PUBLISHER,        //Publisher 
    InyTag_Frame_TRACKNUM,         //Track number/Position in set 
    InyTag_Frame_RECORDINGDATES,   //Recording dates  
    InyTag_Frame_NETRADIOSTATION,  //Internet radio station name 
    InyTag_Frame_NETRADIOOWNER,    //Internet radio station owner 
    InyTag_Frame_SIZE,             //Size 
    InyTag_Frame_ISRC,             //ISRC (international standard recording code) 
    InyTag_Frame_ENCODERSETTINGS,  //Software/Hardware and settings used for encoding 
    InyTag_Frame_USERTEXT,         //User defined text information 
    InyTag_Frame_YEAR,             //Year 
    InyTag_Frame_UNIQUEFILEID,     //Unique file identifier 
    InyTag_Frame_TERMSOFUSE,       //Terms of use 
    InyTag_Frame_UNSYNCEDLYRICS,   //Unsynchronized lyric/text transcription 
    InyTag_Frame_WWWCOMMERCIALINFO,//Commercial information 
    InyTag_Frame_WWWCOPYRIGHT,     //Copyright/Legal infromation 
    InyTag_Frame_WWWAUDIOFILE,     //Official audio file webpage 
    InyTag_Frame_WWWARTIST,        //Official artist/performer webpage 
    InyTag_Frame_WWWAUDIOSOURCE,   //Official audio source webpage 
    InyTag_Frame_WWWRADIOPAGE,     //Official internet radio station homepage 
    InyTag_Frame_WWWPAYMENT,       //Payment 
    InyTag_Frame_WWWPUBLISHER,     //Official publisher webpage 
    InyTag_Frame_WWWUSER,          //User defined URL link 
    InyTag_Frame_METACRYPTO,       //Encrypted meta frame 
    InyTag_Frame_NOFRAME           //Error
} InyTag_Frame_ID;

INYTAG_C_EXPORT InyTag_Mpeg_File *inytag_mpeg_file_new(const char *filename);
INYTAG_C_EXPORT void inytag_mpeg_file_free(InyTag_Mpeg_File *file);
INYTAG_C_EXPORT InyTag_Tag *inytag_file_mpeg_tag(const InyTag_Mpeg_File *file);
INYTAG_C_EXPORT BOOL inytag_mpeg_file_save(InyTag_Mpeg_File *file);
INYTAG_C_EXPORT InyTag_Mp4_File *inytag_mp4_file_new(const char *filename);
INYTAG_C_EXPORT void inytag_mp4_file_free(InyTag_Mp4_File *file);
INYTAG_C_EXPORT InyTag_Tag *inytag_file_mp4_tag(const InyTag_Mp4_File *file);
INYTAG_C_EXPORT void inytag_mp4_file_remove_picture(InyTag_Mp4_File *file);
INYTAG_C_EXPORT void inytag_mp4_file_set_picture(InyTag_Mp4_File *file, InyTag_Format_Type type, const char *imgpath);
INYTAG_C_EXPORT BOOL inytag_mp4_file_save(InyTag_Mp4_File *file);
INYTAG_C_EXPORT InyTag_Flac_File *inytag_flac_file_new(const char *filename);
INYTAG_C_EXPORT void inytag_flac_file_free(InyTag_Flac_File *file);
INYTAG_C_EXPORT InyTag_Tag *inytag_file_flac_tag(const InyTag_Flac_File *file);
INYTAG_C_EXPORT void inytag_flac_file_remove_picture(InyTag_Flac_File *file);
INYTAG_C_EXPORT void inytag_flac_file_add_picture(InyTag_Flac_File *file, InyTag_Flac_Picture *picture);
INYTAG_C_EXPORT BOOL inytag_flac_file_save(InyTag_Flac_File *file);
INYTAG_C_EXPORT InyTag_Flac_Picture *inytag_flac_picture_new();
INYTAG_C_EXPORT void inytag_flac_picture_free(InyTag_Flac_Picture *picture);
INYTAG_C_EXPORT void inytag_flac_picture_set_picture(InyTag_Flac_Picture *picture, const char *imgpath);
INYTAG_C_EXPORT void inytag_flac_picture_set_mime_type(InyTag_Flac_Picture *picture, const char *mimetype);
INYTAG_C_EXPORT void inytag_flac_picture_set_description(InyTag_Flac_Picture *picture, const char *description);
INYTAG_C_EXPORT void inytag_flac_picture_set_type(InyTag_Flac_Picture *picture, InyTag_Img_Type type);
INYTAG_C_EXPORT void inytag_flac_picture_set_width(InyTag_Flac_Picture *picture, int width);
INYTAG_C_EXPORT void inytag_flac_picture_set_height(InyTag_Flac_Picture *picture, int height);
INYTAG_C_EXPORT void inytag_flac_picture_set_num_colors(InyTag_Flac_Picture *picture, int numcolors);
INYTAG_C_EXPORT InyTag_ID3v2_Tag *inytag_id3v2_tag(InyTag_Mpeg_File *file);
INYTAG_C_EXPORT void inytag_id3v2_tag_add_picture_frame(InyTag_ID3v2_Tag *tag, InyTag_ID3v2_Attached_Picture_Frame *frame);
INYTAG_C_EXPORT BOOL inytag_id3v2_tag_is_frame_empty(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid);
INYTAG_C_EXPORT void inytag_id3v2_tag_remove_frame(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid);
INYTAG_C_EXPORT InyTag_ID3v2_Attached_Picture_Frame *inytag_id3v2_attached_picture_frame_new();
INYTAG_C_EXPORT void inytag_id3v2_attached_picture_frame_free(InyTag_ID3v2_Attached_Picture_Frame *picture_frame);
INYTAG_C_EXPORT void inytag_id3v2_attached_picture_frame_set_mime_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *type);
INYTAG_C_EXPORT void inytag_id3v2_attached_picture_frame_set_picture(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *path);
INYTAG_C_EXPORT void inytag_id3v2_attached_picture_frame_set_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, InyTag_Img_Type type);
INYTAG_C_EXPORT void inytag_id3v2_attached_picture_frame_set_description(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, InyTag_Img_Type desc);
INYTAG_C_EXPORT InyTag_File *inytag_file_new(const char *filename);
INYTAG_C_EXPORT void inytag_file_free(InyTag_File *file);
INYTAG_C_EXPORT InyTag_Tag *inytag_file_tag(const InyTag_File *file);
INYTAG_C_EXPORT const InyTag_AudioProperties *inytag_file_audioproperties(const InyTag_File *file);
INYTAG_C_EXPORT BOOL inytag_file_save(InyTag_File *file);
INYTAG_C_EXPORT char *inytag_tag_title(const InyTag_Tag *tag);
INYTAG_C_EXPORT char *inytag_tag_artist(const InyTag_Tag *tag);
INYTAG_C_EXPORT char *inytag_tag_album(const InyTag_Tag *tag);
INYTAG_C_EXPORT char *inytag_tag_comment(const InyTag_Tag *tag);
INYTAG_C_EXPORT char *inytag_tag_genre(const InyTag_Tag *tag);
INYTAG_C_EXPORT unsigned int inytag_tag_year(const InyTag_Tag *tag);
INYTAG_C_EXPORT unsigned int inytag_tag_track(const InyTag_Tag *tag);
INYTAG_C_EXPORT void inytag_tag_set_title(InyTag_Tag *tag, const char *title);
INYTAG_C_EXPORT void inytag_tag_set_artist(InyTag_Tag *tag, const char *artist);
INYTAG_C_EXPORT void inytag_tag_set_album(InyTag_Tag *tag, const char *album);
INYTAG_C_EXPORT void inytag_tag_set_comment(InyTag_Tag *tag, const char *comment);
INYTAG_C_EXPORT void inytag_tag_set_genre(InyTag_Tag *tag, const char *genre);
INYTAG_C_EXPORT void inytag_tag_set_year(InyTag_Tag *tag, unsigned int year);
INYTAG_C_EXPORT void inytag_tag_set_track(InyTag_Tag *tag, unsigned int track);
INYTAG_C_EXPORT int inytag_audioproperties_length(const InyTag_AudioProperties *audioProperties);
INYTAG_C_EXPORT int inytag_audioproperties_bitrate(const InyTag_AudioProperties *audioProperties);
INYTAG_C_EXPORT int inytag_audioproperties_samplerate(const InyTag_AudioProperties *audioProperties);
INYTAG_C_EXPORT int inytag_audioproperties_channels(const InyTag_AudioProperties *audioProperties);

#ifdef __cplusplus
}
#endif
#endif
#endif
