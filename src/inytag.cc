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

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <textidentificationframe.h>
#include <commentsframe.h>
#include <id3v2tag.h>
#include <fileref.h>
#include <mpegfile.h>
#include <flacfile.h>
#include <mp4file.h>
#include <id3v2framefactory.h>
#include <id3v2frame.h>
#include <attachedpictureframe.h>
#include <mp4tag.h>
#include <mp4coverart.h>
#include <glib.h>
#include <tpropertymap.h>
#include <tfilestream.h>
#include <gdk-pixbuf/gdk-pixbuf.h>
#include "inytag.h"

using namespace TagLib;
using namespace std;

bool unicodeStrings = true;
char *stringToCharArray(const String &s) {
    const string str = s.to8Bit(unicodeStrings);
    #ifdef HAVE_ISO_STRDUP
    return ::_strdup(str.c_str());
    #else
    return ::strdup(str.c_str());
    #endif
}

String charArrayToString(const char *s) {
    return String(s, unicodeStrings ? String::UTF8 : String::Latin1);
}

String::Type GetStrType (InyTag_String_Type type) {
    switch (type) {
    case InyTag_String_UTF16:
        return String::UTF16;
    case InyTag_String_UTF16BE:
        return String::UTF16BE;
    case InyTag_String_UTF8:
        return String::UTF8;
    case InyTag_String_UTF16LE:
        return String::UTF16LE;
    default:
        return String::Latin1;
    }
}

MP4::CoverArt::Format GetMP4Format (InyTag_Format_Type format) {
    switch (format) {
        case InyTag_Format_PNG:
            return MP4::CoverArt::Format::PNG;
        case InyTag_Format_BMP:
            return MP4::CoverArt::Format::BMP;
        case InyTag_Format_GIF:
            return MP4::CoverArt::Format::GIF;
        case InyTag_Format_UNKNOWN:
            return MP4::CoverArt::Format::Unknown;
        default:
            return MP4::CoverArt::Format::JPEG;
    }
}

InyTag_Img_Type GetFlacTypePic (FLAC::Picture::Type type) {
    switch (type) {
        case FLAC::Picture::FileIcon:
            return InyTag_Img_FileIcon;
        case FLAC::Picture::OtherFileIcon:
            return InyTag_Img_OtherFileIcon;
        case FLAC::Picture::FrontCover:
            return InyTag_Img_FrontCover;
        case FLAC::Picture::BackCover:
            return InyTag_Img_BackCover;
        case FLAC::Picture::LeafletPage:
            return InyTag_Img_LeafletPage;
        case FLAC::Picture::Media:
            return InyTag_Img_Media;
        case FLAC::Picture::LeadArtist:
            return InyTag_Img_LeadArtist;
        case FLAC::Picture::Artist:
            return InyTag_Img_Artist;
        case FLAC::Picture::Conductor:
            return InyTag_Img_Conductor;
        case FLAC::Picture::Band:
            return InyTag_Img_Band;
        case FLAC::Picture::Composer:
            return InyTag_Img_Composer;
        case FLAC::Picture::Lyricist:
            return InyTag_Img_Lyricist;
        case FLAC::Picture::RecordingLocation:
            return InyTag_Img_RecordingLocation;
        case FLAC::Picture::DuringRecording:
            return InyTag_Img_DuringRecording;
        case FLAC::Picture::DuringPerformance:
            return InyTag_Img_DuringPerformance;
        case FLAC::Picture::MovieScreenCapture:
            return InyTag_Img_MovieScreenCapture;
        case FLAC::Picture::ColouredFish:
            return InyTag_Img_ColouredFish;
        case FLAC::Picture::Illustration:
            return InyTag_Img_Illustration;
        case FLAC::Picture::BandLogo:
            return InyTag_Img_BandLogo;
        case FLAC::Picture::PublisherLogo:
            return InyTag_Img_PublisherLogo;
        default:
            return InyTag_Img_Other;
    }
}

FLAC::Picture::Type GetFlacPicType (InyTag_Img_Type type) {
    switch (type) {
        case InyTag_Img_FileIcon:
            return(FLAC::Picture::FileIcon);
        case InyTag_Img_OtherFileIcon:
            return(FLAC::Picture::OtherFileIcon);
        case InyTag_Img_FrontCover:
            return(FLAC::Picture::FrontCover);
        case InyTag_Img_BackCover:
            return(FLAC::Picture::BackCover);
        case InyTag_Img_LeafletPage:
            return(FLAC::Picture::LeafletPage);
        case InyTag_Img_Media:
            return(FLAC::Picture::Media);
        case InyTag_Img_LeadArtist:
            return(FLAC::Picture::LeadArtist);
        case InyTag_Img_Artist:
            return(FLAC::Picture::Artist);
        case InyTag_Img_Conductor:
            return(FLAC::Picture::Conductor);
        case InyTag_Img_Band:
            return(FLAC::Picture::Band);
        case InyTag_Img_Composer:
            return(FLAC::Picture::Composer);
        case InyTag_Img_Lyricist:
            return(FLAC::Picture::Lyricist);
        case InyTag_Img_RecordingLocation:
            return(FLAC::Picture::RecordingLocation);
        case InyTag_Img_DuringRecording:
            return(FLAC::Picture::DuringRecording);
        case InyTag_Img_DuringPerformance:
            return(FLAC::Picture::DuringPerformance);
        case InyTag_Img_MovieScreenCapture:
            return(FLAC::Picture::MovieScreenCapture);
        case InyTag_Img_ColouredFish:
            return(FLAC::Picture::ColouredFish);
        case InyTag_Img_Illustration:
            return(FLAC::Picture::Illustration);
        case InyTag_Img_BandLogo:
            return(FLAC::Picture::BandLogo);
        case InyTag_Img_PublisherLogo:
            return(FLAC::Picture::PublisherLogo);
        default:
            return(FLAC::Picture::Other);
    }
}

ID3v2::AttachedPictureFrame::Type GetID3v2PicType (InyTag_Img_Type type) {
    switch (type) {
        case InyTag_Img_FileIcon:
            return(ID3v2::AttachedPictureFrame::FileIcon);
        case InyTag_Img_OtherFileIcon:
            return(ID3v2::AttachedPictureFrame::OtherFileIcon);
        case InyTag_Img_FrontCover:
            return(ID3v2::AttachedPictureFrame::FrontCover);
        case InyTag_Img_BackCover:
            return(ID3v2::AttachedPictureFrame::BackCover);
        case InyTag_Img_LeafletPage:
            return(ID3v2::AttachedPictureFrame::LeafletPage);
        case InyTag_Img_Media:
            return(ID3v2::AttachedPictureFrame::Media);
        case InyTag_Img_LeadArtist:
            return(ID3v2::AttachedPictureFrame::LeadArtist);
        case InyTag_Img_Artist:
            return(ID3v2::AttachedPictureFrame::Artist);
        case InyTag_Img_Conductor:
            return(ID3v2::AttachedPictureFrame::Conductor);
        case InyTag_Img_Band:
            return(ID3v2::AttachedPictureFrame::Band);
        case InyTag_Img_Composer:
            return(ID3v2::AttachedPictureFrame::Composer);
        case InyTag_Img_Lyricist:
            return(ID3v2::AttachedPictureFrame::Lyricist);
        case InyTag_Img_RecordingLocation:
            return(ID3v2::AttachedPictureFrame::RecordingLocation);
        case InyTag_Img_DuringRecording:
            return(ID3v2::AttachedPictureFrame::DuringRecording);
        case InyTag_Img_DuringPerformance:
            return(ID3v2::AttachedPictureFrame::DuringPerformance);
        case InyTag_Img_MovieScreenCapture:
            return(ID3v2::AttachedPictureFrame::MovieScreenCapture);
        case InyTag_Img_ColouredFish:
            return(ID3v2::AttachedPictureFrame::ColouredFish);
        case InyTag_Img_Illustration:
            return(ID3v2::AttachedPictureFrame::Illustration);
        case InyTag_Img_BandLogo:
            return(ID3v2::AttachedPictureFrame::BandLogo);
        case InyTag_Img_PublisherLogo:
            return(ID3v2::AttachedPictureFrame::PublisherLogo);
        default:
            return(ID3v2::AttachedPictureFrame::Other);
    }
}

InyTag_Img_Type GetID3v2TypePic (ID3v2::AttachedPictureFrame::Type type) {
    switch (type) {
        case ID3v2::AttachedPictureFrame::FileIcon:
            return InyTag_Img_FileIcon;
        case ID3v2::AttachedPictureFrame::OtherFileIcon:
            return InyTag_Img_OtherFileIcon;
        case ID3v2::AttachedPictureFrame::FrontCover:
            return InyTag_Img_FrontCover;
        case ID3v2::AttachedPictureFrame::BackCover:
            return InyTag_Img_BackCover;
        case ID3v2::AttachedPictureFrame::LeafletPage:
            return InyTag_Img_LeafletPage;
        case ID3v2::AttachedPictureFrame::Media:
            return InyTag_Img_Media;
        case ID3v2::AttachedPictureFrame::LeadArtist:
            return InyTag_Img_LeadArtist;
        case ID3v2::AttachedPictureFrame::Artist:
            return InyTag_Img_Artist;
        case ID3v2::AttachedPictureFrame::Conductor:
            return InyTag_Img_Conductor;
        case ID3v2::AttachedPictureFrame::Band:
            return InyTag_Img_Band;
        case ID3v2::AttachedPictureFrame::Composer:
            return InyTag_Img_Composer;
        case ID3v2::AttachedPictureFrame::Lyricist:
            return InyTag_Img_Lyricist;
        case ID3v2::AttachedPictureFrame::RecordingLocation:
            return InyTag_Img_RecordingLocation;
        case ID3v2::AttachedPictureFrame::DuringRecording:
            return InyTag_Img_DuringRecording;
        case ID3v2::AttachedPictureFrame::DuringPerformance:
            return InyTag_Img_DuringPerformance;
        case ID3v2::AttachedPictureFrame::MovieScreenCapture:
            return InyTag_Img_MovieScreenCapture;
        case ID3v2::AttachedPictureFrame::ColouredFish:
            return InyTag_Img_ColouredFish;
        case ID3v2::AttachedPictureFrame::Illustration:
            return InyTag_Img_Illustration;
        case ID3v2::AttachedPictureFrame::BandLogo:
            return InyTag_Img_BandLogo;
        case ID3v2::AttachedPictureFrame::PublisherLogo:
            return InyTag_Img_PublisherLogo;
        default:
            return InyTag_Img_Other;
    }
}

const char *GetFrameID (InyTag_Frame_ID frameid) {
	switch(frameid) {
 		case InyTag_Frame_PICTURE:
	  		return "APIC";
 		case InyTag_Frame_COMMENT:
	  		return "COMM";
 		case InyTag_Frame_COMMERCIAL:
	  		return "COMR";
 		case InyTag_Frame_CRYPTOREG:
	  		return "ENCR";
		case InyTag_Frame_EQUALIZATION:
	  		return "EQUA";
	  	case InyTag_Frame_EVENTTIMING:
			return "ETCO";
		case InyTag_Frame_GENERALOBJECT:
			return "GEOB";
		case InyTag_Frame_GROUPINGREG:
			return "GRID";
		case InyTag_Frame_INVOLVEDPEOPLE:
			return "IPLS";
 		case InyTag_Frame_LINKEDINFO:
			return "LINK";
 		case InyTag_Frame_CDID:
			return "MCDI";
		case InyTag_Frame_MPEGLOOKUP:
			return "MLLT";
		case InyTag_Frame_OWNERSHIP:
			return "OWNE";
		case InyTag_Frame_PRIVATE:
			return "PRIV"; 
		case InyTag_Frame_PLAYCOUNTER:
			return "PCNT"; 
		case InyTag_Frame_POPULARIMETER:
			return "POPM"; 
		case InyTag_Frame_POSITIONSYNC:
			return "POSS";
		case InyTag_Frame_BUFFERSIZE:
			return "RBUF";
		case InyTag_Frame_VOLUMEADJ:
			return "RVAD";
		case InyTag_Frame_REVERB:
			return "RVRB";
		case InyTag_Frame_SYNCEDLYRICS:
			return "SYLT";
		case InyTag_Frame_SYNCEDTEMPO:
			return "SYTC";
		case InyTag_Frame_ALBUM:
			return "TALB";
		case InyTag_Frame_BPM:
			return "TBPM";
		case InyTag_Frame_COMPOSER:
			return "TCOM";
		case InyTag_Frame_CONTENTTYPE:
			return "TCON";
		case InyTag_Frame_COPYRIGHT:
			return "TCOP";
		case InyTag_Frame_DATE:
			return "TDAT";
		case InyTag_Frame_PLAYLISTDELAY:
			return "TDLY";
		case InyTag_Frame_ENCODEDBY:
			return "TENC";
		case InyTag_Frame_LYRICIST:
			return "TEXT";
		case InyTag_Frame_FILETYPE:
			return "TFLT";
		case InyTag_Frame_TIME:
			return "TIME";
		case InyTag_Frame_CONTENTGROUP:
			return "TIT1";
		case InyTag_Frame_TITLE:
			return "TIT2";
		case InyTag_Frame_SUBTITLE:
			return "TIT3";
		case InyTag_Frame_INITIALKEY:
			return "TKEY";
		case InyTag_Frame_LANGUAGE:
			return "TLAN";
		case InyTag_Frame_SONGLEN:
			return "TLEN";
		case InyTag_Frame_MEDIATYPE:
			return "TMED";
		case InyTag_Frame_ORIGALBUM:
			return "TOAL";
		case InyTag_Frame_ORIGFILENAME:
			return "TOFN";
		case InyTag_Frame_ORIGLYRICIST:
			return "TOLY";
		case InyTag_Frame_ORIGARTIST:
			return "TOPE";
		case InyTag_Frame_ORIGYEAR:
			return "TORY";
		case InyTag_Frame_FILEOWNER:
			return "TOWN";
		case InyTag_Frame_LEADARTIST:
			return "TPE1";
		case InyTag_Frame_BAND:
			return "TPE2";
		case InyTag_Frame_CONDUCTOR:
			return "TPE3";
		case InyTag_Frame_MIXARTIST:
			return "TPE4";
		case InyTag_Frame_PARTINSET:
			return "TPOS";
		case InyTag_Frame_PUBLISHER:
			return "TPUB";
		case InyTag_Frame_TRACKNUM:
			return "TRCK";
		case InyTag_Frame_RECORDINGDATES:
			return "TRDA";
		case InyTag_Frame_NETRADIOSTATION: 
			return "TRSN";
 		case InyTag_Frame_NETRADIOOWNER:
			return "TRSO";
		case InyTag_Frame_SIZE:
			return "TSIZ";
		case InyTag_Frame_ISRC:
			return "TSRC";
		case InyTag_Frame_ENCODERSETTINGS:
			return "TSSE";
		case InyTag_Frame_USERTEXT:
	  		return "TXXX";
	  	case InyTag_Frame_YEAR:
	  		return "TYER";
	  	case InyTag_Frame_YEARV2:
	  		return "TDRC";
	  	case InyTag_Frame_UNIQUEFILEID:
	  		return "UFID";
	  	case InyTag_Frame_TERMSOFUSE:
	  		return "USER";
	  	case InyTag_Frame_UNSYNCEDLYRICS:
	  		return "USLT";
	  	case InyTag_Frame_WWWCOMMERCIALINFO:
	  		return "WCOM";
	  	case InyTag_Frame_WWWCOPYRIGHT:
	  		return "WCOP";
	  	case InyTag_Frame_WWWAUDIOFILE:
	  		return "WOAF";
	  	case InyTag_Frame_WWWARTIST:
	  		return "WOAR";
	  	case InyTag_Frame_WWWAUDIOSOURCE:
	  		return "WOAS";
	  	case InyTag_Frame_WWWRADIOPAGE:
	  		return "WORS";
	  	case InyTag_Frame_WWWPAYMENT:
	  		return "WPAY";
	  	case InyTag_Frame_WWWPUBLISHER:
	  		return "WPUB";
	  	case InyTag_Frame_WWWUSER:
	  		return "WXXX";
	  	case InyTag_Frame_METACRYPTO:
	  		return "    ";
	  	case InyTag_Frame_NOFRAME:
	  		return "????";
		default:
  			return "AENC";
	  	}
}

void inytag_set_strings_unicode(BOOL unicode) {
    unicodeStrings = (unicode != 0);
}

InyTag_Mpeg_File *inytag_mpeg_file_new(const char *filename) {
    return reinterpret_cast<InyTag_Mpeg_File *>(new MPEG::File(filename));
}

void inytag_mpeg_file_free(InyTag_Mpeg_File *file) {
    MPEG::File *f = reinterpret_cast<MPEG::File *>(file);
    free(f);
    file = NULL;
}

const InyTag_AudioProperties *inytag_mpeg_file_audioproperties(const InyTag_Mpeg_File *file) {
    const File *f = reinterpret_cast<const File *>(file);
    return reinterpret_cast<const InyTag_AudioProperties *>(f->audioProperties());
}

InyTag_Tag *inytag_file_mpeg_tag(const InyTag_Mpeg_File *file) {
  const File *f = reinterpret_cast<const File *>(file);
  return reinterpret_cast<InyTag_Tag *>(f->tag());
}

BOOL inytag_mpeg_file_save(InyTag_Mpeg_File *file) {
    MPEG::File *song_file = reinterpret_cast<MPEG::File *>(file);
    return song_file->save();
}

InyTag_Mp4_File *inytag_mp4_file_new(const char *filename) {
    return reinterpret_cast<InyTag_Mp4_File *>(new MP4::File(filename));
}

void inytag_mp4_file_free(InyTag_Mp4_File *file) {
    MP4::File *f = reinterpret_cast<MP4::File *>(file);
    free(f);
    file = NULL;
}

const InyTag_AudioProperties *inytag_mp4_file_audioproperties(const InyTag_Mp4_File *file) {
    const MP4::File *f = reinterpret_cast<const MP4::File *>(file);
    return reinterpret_cast<const InyTag_AudioProperties *>(f->audioProperties());
}

InyTag_Tag *inytag_file_mp4_tag(const InyTag_Mp4_File *file) {
  const File *f = reinterpret_cast<const File *>(file);
  return reinterpret_cast<InyTag_Tag *>(f->tag());
}

InyTag_Tag_MP4 *inytag_tag_mp4(InyTag_Mp4_File *file) {
    MP4::File *f = reinterpret_cast<MP4::File *>(file);
    return reinterpret_cast<InyTag_Tag_MP4 *>(f->tag());
}

void inytag_mp4_file_remove_picture(InyTag_Mp4_File *file) {
    MP4::File *f = reinterpret_cast<MP4::File *>(file);
    MP4::Tag *tag = f->tag();
    if (tag->contains ("covr")) {
        tag->removeItem ("covr");
    }
    file = reinterpret_cast<InyTag_Mp4_File *>(f);
}

BOOL inytag_mp4_file_save(InyTag_Mp4_File *file) {
    MP4::File *song_file = reinterpret_cast<MP4::File *>(file);
    return song_file->save();
}

void inytag_tag_mp4_remove_item(InyTag_Tag_MP4 *tags, const char *contains) {
    MP4::Tag *tag = reinterpret_cast<MP4::Tag *>(tags);
    if (tag->contains (contains)) {
        tag->removeItem (contains);
    }
    tags = reinterpret_cast<InyTag_Tag_MP4 *>(tag);
}

void inytag_tag_mp4_add_item(InyTag_Tag_MP4 *tags, const char *contains) {
    MP4::Tag *tag = reinterpret_cast<MP4::Tag *>(tags);
    if (tag->contains (contains)) {
        tag->removeItem (contains);
    }
    tag->item (contains);
    tags = reinterpret_cast<InyTag_Tag_MP4 *>(tag);
}

void inytag_tag_mp4_set_item_string(InyTag_Tag_MP4 *tags, const char *contains, const char *item) {
    MP4::Tag *tag = reinterpret_cast<MP4::Tag *>(tags);
    if (tag->contains (contains)) {
        tag->removeItem (contains);
    }
    tag->setItem(contains, StringList(item));
    tags = reinterpret_cast<InyTag_Tag_MP4 *>(tag);
}

char *inytag_tag_mp4_get_item_string(InyTag_Tag_MP4 *tags, const char *contains) {
    MP4::Tag *tag = reinterpret_cast<MP4::Tag *>(tags);
    if (!tag->contains (contains)) {
        return NULL;
    }
    return stringToCharArray (tag->properties().toString ());
}

void inytag_tag_mp4_set_item_picture(InyTag_Tag_MP4 *tags, InyTag_Mp4_Picture *picture) {
    MP4::Tag *tag = reinterpret_cast<MP4::Tag *>(tags);
    if (tag->contains ("covr")) {
        tag->removeItem ("covr");
    }
    MP4::CoverArtList *pic = reinterpret_cast<MP4::CoverArtList *>(picture);
    MP4::CoverArt coverArt (pic->back ().format (), pic->back ().data ());
    MP4::CoverArtList coverArtList;
    coverArtList.append(coverArt);
    MP4::Item coverItem(coverArtList);
    tag->setItem("covr", coverItem);
    tags = reinterpret_cast<InyTag_Tag_MP4 *>(tag);
}

InyTag_Mp4_Picture *inytag_tag_mp4_get_item_picture(InyTag_Tag_MP4 *tags) {
    MP4::Tag *tag = reinterpret_cast<MP4::Tag *>(tags);
    if (tag->contains("covr")) {
        MP4::CoverArtList list = tag->item("covr").toCoverArtList ();
        MP4::CoverArt cover(list.back ().format (), list.back ().data ());
        MP4::CoverArtList *coverArtList = new MP4::CoverArtList ();
        coverArtList->append(cover);
        return reinterpret_cast<InyTag_Mp4_Picture *>(coverArtList);
    } else {
        return NULL;
    }
}

InyTag_Mp4_Picture *inytag_mp4_picture_new() {
    return reinterpret_cast<InyTag_Mp4_Picture *>(new MP4::CoverArtList);
}

void inytag_mp4_picture_free(InyTag_Mp4_Picture *pict) {
    MP4::CoverArtList *f = reinterpret_cast<MP4::CoverArtList *>(pict);
    delete f;
    pict = NULL;
}

void inytag_mp4_picture_set_file(InyTag_Mp4_Picture *pict, InyTag_Format_Type type, const char *filename) {
    if (filename == NULL) {
        return;
    }
    MP4::CoverArtList *picture = reinterpret_cast<MP4::CoverArtList *>(pict);
    FileStream myfile(filename);
    long lengh = myfile.length ();
    MP4::CoverArt coverArt(GetMP4Format (type), myfile.readBlock(lengh));
    picture->append(coverArt);
    pict = reinterpret_cast<InyTag_Mp4_Picture *>(picture);
}

InyTag_ByteVector *inytag_mp4_picture_get_picture(InyTag_Mp4_Picture *pict, InyTag_Format_Type type) {
    if (pict == NULL) {
        return NULL;
    }
    MP4::CoverArtList *pic = reinterpret_cast<MP4::CoverArtList *>(pict);
    ByteVector *bvector = new ByteVector ();
    bvector->append (pic->back ().data ());
    return reinterpret_cast<InyTag_ByteVector *>(bvector);
}

InyTag_Flac_File *inytag_flac_file_new(const char *filename) {
    return reinterpret_cast<InyTag_Flac_File *>(new FLAC::File(filename));
}

void inytag_flac_file_free(InyTag_Flac_File *file) {
    FLAC::File *f = reinterpret_cast<FLAC::File *>(file);
    free (f);
    file = NULL;
}

const InyTag_AudioProperties *inytag_flac_file_audioproperties(const InyTag_Flac_File *file) {
    const File *f = reinterpret_cast<const File *>(file);
    return reinterpret_cast<const InyTag_AudioProperties *>(f->audioProperties());
}

InyTag_Tag *inytag_file_flac_tag(const InyTag_Flac_File *file) {
  const File *f = reinterpret_cast<const File *>(file);
  return reinterpret_cast<InyTag_Tag *>(f->tag());
}

InyTag_ID3v2_Tag *inytag_id3v2_flac_tag(InyTag_Flac_File *file) {
    MPEG::File *song_file = reinterpret_cast<MPEG::File *>(file);
    return reinterpret_cast<InyTag_ID3v2_Tag *>(song_file->ID3v2Tag());
}

void inytag_flac_file_remove_all_picture(InyTag_Flac_File *file) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    song_file->removePictures();
    file = reinterpret_cast<InyTag_Flac_File *>(song_file);
}

void inytag_flac_file_remove_picture(InyTag_Flac_File *file, InyTag_Img_Type type) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    TagLib::List<TagLib::FLAC::Picture*> list_pic = song_file->pictureList ();
    for (TagLib::List<TagLib::FLAC::Picture*>::Iterator it = list_pic.begin(); it != list_pic.end(); ++it) {
        if (GetFlacTypePic ((*it)->type ()) == type) {
            song_file->removePicture((*it));
            it = list_pic.begin(); 
        }
    }
    file = reinterpret_cast<InyTag_Flac_File *>(song_file);
}

InyTag_Flac_Picture *inytag_flac_file_get_picture(InyTag_Flac_File *file, InyTag_Img_Type type) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    FLAC::Picture *cover = NULL;
    TagLib::List<TagLib::FLAC::Picture*> list_pic = song_file->pictureList ();
    for (TagLib::List<TagLib::FLAC::Picture*>::Iterator it = list_pic.begin(); it != list_pic.end(); ++it) {
        if (GetFlacTypePic ((*it)->type ()) == type) {
            cover = (*it);
        }
    }
    return reinterpret_cast<InyTag_Flac_Picture *>(cover);
}

void inytag_flac_file_add_picture(InyTag_Flac_File *file, InyTag_Flac_Picture *picture) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    FLAC::Picture *cover = new FLAC::Picture ();
    FLAC::Picture *pf = reinterpret_cast<FLAC::Picture *>(picture);
    cover->parse (pf->render());
    inytag_flac_file_remove_picture (file, GetFlacTypePic (pf->type ()));
    song_file->addPicture(cover);
    file = reinterpret_cast<InyTag_Flac_File *>(song_file);
}

BOOL inytag_flac_file_save(InyTag_Flac_File *file) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    return song_file->save();
}

InyTag_Flac_Picture *inytag_flac_picture_new() {
    return reinterpret_cast<InyTag_Flac_Picture *>(new FLAC::Picture);
}

void inytag_flac_picture_free(InyTag_Flac_Picture *picture) {
    FLAC::Picture *pf = reinterpret_cast<FLAC::Picture *>(picture);
    delete pf;
    pf = NULL;
    picture = NULL;
}

InyTag_ByteVector *inytag_flac_picture_get_picture(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return NULL;
    }
    FLAC::Picture *pf = reinterpret_cast<FLAC::Picture *>(picture);
    ByteVector *bvector = new ByteVector ();
    bvector->append (pf->data ());
    return reinterpret_cast<InyTag_ByteVector *>(bvector);
}

void inytag_flac_picture_set_picture(InyTag_Flac_Picture *picture, const char *imgpath) {
    if (imgpath == NULL) {
        return;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    FileStream myfile(imgpath);
    long lengh = myfile.length ();
    fp->setData(myfile.readBlock(lengh));
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

char *inytag_flac_picture_get_mime_type(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return NULL;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    return reinterpret_cast<char *> (stringToCharArray (fp->mimeType()));
}

void inytag_flac_picture_set_mime_type(InyTag_Flac_Picture *picture, const char *mimetype) {
    if (mimetype == NULL) {
        return;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setMimeType(mimetype);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

char *inytag_flac_picture_get_description(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return NULL;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    return reinterpret_cast<char *> (stringToCharArray (fp->description()));
}

void inytag_flac_picture_set_description(InyTag_Flac_Picture *picture, const char *description) {
    if (description == NULL) {
        return;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setDescription(charArrayToString (description));
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

InyTag_Img_Type *inytag_flac_picture_get_type(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return 0;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    return reinterpret_cast<InyTag_Img_Type *> (GetFlacTypePic (fp->type()));
}

void inytag_flac_picture_set_type(InyTag_Flac_Picture *picture, InyTag_Img_Type type) {
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setType(GetFlacPicType (type));
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

int *inytag_flac_picture_get_width(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return 0;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    return reinterpret_cast<int *> (fp->width());
}

void inytag_flac_picture_set_width(InyTag_Flac_Picture *picture, int width) {
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setWidth(width);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

int *inytag_flac_picture_get_height(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return 0;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    return reinterpret_cast<int *> (fp->height());
}

void inytag_flac_picture_set_height(InyTag_Flac_Picture *picture, int height) {
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setHeight(height);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

void inytag_flac_picture_set_num_colors(InyTag_Flac_Picture *picture, int numcolors) {
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setNumColors(numcolors);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

int *inytag_flac_picture_get_num_colors(InyTag_Flac_Picture *picture) {
    if (picture == NULL) {
        return 0;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    return reinterpret_cast<int *> (fp->numColors());
}

InyTag_ID3v2_Tag *inytag_id3v2_tag(InyTag_Mpeg_File *file) {
    MPEG::File *song_file = reinterpret_cast<MPEG::File *>(file);
    return reinterpret_cast<InyTag_ID3v2_Tag *>(song_file->ID3v2Tag());
}

void inytag_id3v2_tag_add_text_frame(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid, const char *text) {
    if (!inytag_id3v2_tag_is_frame_empty (tag, frameid)) {
        inytag_id3v2_tag_remove_frame (tag, frameid);
    }
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::TextIdentificationFrame *f = new ID3v2::TextIdentificationFrame(ByteVector(GetFrameID (frameid)), String::UTF8);
    f->setText(charArrayToString (text));
    t->addFrame (f);
    tag = reinterpret_cast<InyTag_ID3v2_Tag *>(t);
}

char *inytag_id3v2_tag_get_text_frame(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    String result;
    for (ID3v2::FrameList::ConstIterator it = t->frameList().begin(); it != t->frameList().end(); ++it) {
        ByteVector frame_id = (*it)->frameID();
        string frame_name(frame_id.data(), frame_id.size());
        if (frame_name.compare(GetFrameID (frameid)) == 0) {
            result = (*it)->toString ();
        }
    }
    char *s = stringToCharArray (result);
    return s;  
}

InyTag_ID3v2_Attached_Picture_Frame *inytag_id3v2_tag_get_picture_frame(InyTag_ID3v2_Tag *tag, InyTag_Img_Type imgtype) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::AttachedPictureFrame *picture = NULL;
    for (ID3v2::FrameList::ConstIterator it = t->frameList().begin(); it != t->frameList().end(); ++it) {
        ByteVector frame_id = (*it)->frameID();
        string frame_name(frame_id.data(), frame_id.size());
        if (frame_name.compare(GetFrameID (InyTag_Frame_PICTURE)) == 0) {
            ID3v2::AttachedPictureFrame *in_picture = new ID3v2::AttachedPictureFrame ((*it)->render ());
            if (GetID3v2PicType (imgtype) == in_picture->type ()) {
                picture = in_picture;
            }
        }
    }
    return reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(picture);
}

void inytag_id3v2_tag_add_comment_frame(InyTag_ID3v2_Tag *tag, InyTag_ID3v2_Attached_Comment_Frame *frame) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::CommentsFrame *cf = reinterpret_cast<ID3v2::CommentsFrame *>(frame);
    if (!inytag_id3v2_tag_is_frame_empty (tag, InyTag_Frame_COMMENT)) {
        inytag_id3v2_tag_remove_frame (tag, InyTag_Frame_COMMENT);
    } else if (cf->text () != stringToCharArray ("")) {
        t->addFrame(cf);
    }
    tag = reinterpret_cast<InyTag_ID3v2_Tag *>(t);
}

void inytag_id3v2_tag_add_picture_frame(InyTag_ID3v2_Tag *tag, InyTag_ID3v2_Attached_Picture_Frame *frame) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::AttachedPictureFrame *f = reinterpret_cast<ID3v2::AttachedPictureFrame *>(frame);
    inytag_id3v2_tag_picture_frame_type_is_emty (tag, GetID3v2TypePic (f->type ()));
    t->addFrame(f);
    tag = reinterpret_cast<InyTag_ID3v2_Tag *>(t);
}

BOOL inytag_id3v2_tag_is_frame_empty(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::FrameList f = t->frameListMap()[GetFrameID (frameid)];
    return f.isEmpty();
}

void inytag_id3v2_tag_picture_frame_type_is_emty(InyTag_ID3v2_Tag *tag, InyTag_Img_Type imgtype) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    for (ID3v2::FrameList::ConstIterator it = t->frameList().begin(); it != t->frameList().end(); ++it) {
        ByteVector frame_id = (*it)->frameID();
        string frame_name(frame_id.data(), frame_id.size());
        if (frame_name.compare(GetFrameID (InyTag_Frame_PICTURE)) == 0) {
            ID3v2::AttachedPictureFrame *in_picture = new ID3v2::AttachedPictureFrame ((*it)->render ());
            if (GetID3v2PicType (imgtype) == in_picture->type ()) {
                t->removeFrame((*it));
                it = t->frameList().begin();
            }
        }
    }
}

void inytag_id3v2_tag_remove_frame(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    for (ID3v2::FrameList::ConstIterator it = t->frameList().begin(); it != t->frameList().end(); ++it) {
        ByteVector frame_id = (*it)->frameID();
        string frame_name(frame_id.data(), frame_id.size());
        if (frame_name.compare(GetFrameID (frameid)) == 0) {
            t->removeFrame((*it));
            it = t->frameList().begin();
        }
    }
    tag = reinterpret_cast<InyTag_ID3v2_Tag *>(t);
}

void inytag_id3v2_tag_remove_all(InyTag_ID3v2_Tag *tag) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    for (ID3v2::FrameList::ConstIterator it = t->frameList().begin(); it != t->frameList().end(); ++it) {
        ID3v2::FrameList f = t->frameListMap()[(*it)->frameID()];
        if (!f.isEmpty()) {
            t->removeFrame((*it));
            it = t->frameList().begin();
        }
    }
}

InyTag_ID3v2_Attached_Comment_Frame *inytag_id3v2_attached_comment_frame_new() {
    return reinterpret_cast<InyTag_ID3v2_Attached_Comment_Frame *>(new ID3v2::CommentsFrame (ByteVector(GetFrameID (InyTag_Frame_COMMENT))));
}

void inytag_id3v2_attached_comment_frame_free(InyTag_ID3v2_Attached_Comment_Frame *picture_frame) {
    ID3v2::CommentsFrame *cf = reinterpret_cast<ID3v2::CommentsFrame *>(picture_frame);
    delete cf;
    cf = NULL;
    picture_frame = NULL;
}

void inytag_id3v2_attached_comment_frame_set_encording(InyTag_ID3v2_Attached_Comment_Frame *frame, InyTag_String_Type type) {
    ID3v2::CommentsFrame *cf = reinterpret_cast<ID3v2::CommentsFrame *>(frame);
    cf->setTextEncoding (GetStrType (type));
    frame = reinterpret_cast<InyTag_ID3v2_Attached_Comment_Frame *>(cf);
}

void inytag_id3v2_attached_comment_frame_set_text(InyTag_ID3v2_Attached_Comment_Frame *frame, const char *text) {
    if (text == NULL) {
        return;
    }
    ID3v2::CommentsFrame *cf = reinterpret_cast<ID3v2::CommentsFrame *>(frame);
    cf->setText(charArrayToString (text));
    frame = reinterpret_cast<InyTag_ID3v2_Attached_Comment_Frame *>(cf);
}

void inytag_id3v2_attached_comment_frame_set_language(InyTag_ID3v2_Attached_Comment_Frame *frame, const char *lang) {
    if (lang == NULL) {
        return;
    }
    ID3v2::CommentsFrame *cf = reinterpret_cast<ID3v2::CommentsFrame *>(frame);
    cf->setLanguage(ByteVector (lang));
    frame = reinterpret_cast<InyTag_ID3v2_Attached_Comment_Frame *>(cf);
}

void inytag_id3v2_attached_comment_frame_set_description(InyTag_ID3v2_Attached_Comment_Frame *frame, const char *desc) {
    if (desc == NULL) {
        return;
    }
    ID3v2::CommentsFrame *cf = reinterpret_cast<ID3v2::CommentsFrame *>(frame);
    cf->setDescription(charArrayToString (desc));
    frame = reinterpret_cast<InyTag_ID3v2_Attached_Comment_Frame *>(cf);
}

InyTag_ID3v2_Attached_Picture_Frame *inytag_id3v2_attached_picture_frame_new() {
    return reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(new ID3v2::AttachedPictureFrame);
}

void inytag_id3v2_attached_picture_frame_free(InyTag_ID3v2_Attached_Picture_Frame *picture_frame) {
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    delete pf;
    pf = NULL;
    picture_frame = NULL;
}

void inytag_id3v2_attached_picture_frame_set_mime_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *mimee) {
    if (mimee == NULL) {
        return;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setMimeType(mimee);
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

char *inytag_id3v2_attached_picture_frame_get_mime_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame) {
    if (picture_frame == NULL) {
        return stringToCharArray ("");
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    char *mime = stringToCharArray(pf->mimeType ());
    return mime;
}

void inytag_id3v2_attached_picture_frame_set_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, InyTag_Img_Type type) {
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setType(GetID3v2PicType (type));
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

InyTag_Img_Type inytag_id3v2_attached_picture_frame_get_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame) {
    if (picture_frame == NULL) {
        return InyTag_Img_Other;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    return GetID3v2TypePic (pf->type());
}

void inytag_id3v2_attached_picture_frame_set_picture(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *path) {
    if (path == NULL) {
        return;
    }
    FileStream myfile(path);
    long lengh = myfile.length ();
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setPicture(myfile.readBlock(lengh));
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

void inytag_id3v2_attached_picture_frame_set_picture_form_bytevector(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, InyTag_ByteVector *bytevector) {
    if (bytevector == NULL) {
        return;
    }
    ByteVector *vector = reinterpret_cast<ByteVector *> (bytevector);
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setPicture(reinterpret_cast<char *> (vector->data ()));
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

InyTag_ByteVector *inytag_id3v2_attached_picture_frame_get_picture(InyTag_ID3v2_Attached_Picture_Frame *picture_frame) {
    if (picture_frame == NULL) {
        return NULL;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    InyTag_ByteVector *bytevector = inytag_bytevector_new ();
    ByteVector *vector = reinterpret_cast<ByteVector *> (bytevector);
    vector->setData (pf->picture().data (), pf->picture().size ());
    return reinterpret_cast<InyTag_ByteVector *>(vector);
}

void inytag_id3v2_attached_picture_frame_set_description(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *desc) {
    if (desc == NULL) {
        return;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setDescription(charArrayToString (desc));
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

char *inytag_id3v2_attached_picture_frame_get_description(InyTag_ID3v2_Attached_Picture_Frame *picture_frame) {
    if (picture_frame == NULL) {
        return stringToCharArray ("");
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    char *desc = stringToCharArray(pf->description ());
    return desc;
}

InyTag_File *inytag_file_new(const char *filename) {
    return reinterpret_cast<InyTag_File *>(FileRef::create(filename));
}

void inytag_file_free(InyTag_File *file) {
    delete reinterpret_cast<File *>(file);
}

InyTag_Tag *inytag_file_tag(const InyTag_File *file) {
    const File *f = reinterpret_cast<const File *>(file);
    return reinterpret_cast<InyTag_Tag *>(f->tag());
}

const InyTag_AudioProperties *inytag_file_audioproperties(const InyTag_File *file) {
    const File *f = reinterpret_cast<const File *>(file);
    return reinterpret_cast<const InyTag_AudioProperties *>(f->audioProperties());
}

BOOL inytag_file_save(InyTag_File *file) {
    return reinterpret_cast<File *>(file)->save();
}

char *inytag_tag_title(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    char *s = stringToCharArray(t->title());
    return s;
}

char *inytag_tag_artist(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    char *s = stringToCharArray(t->artist());
    return s;
}

char *inytag_tag_album(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    char *s = stringToCharArray(t->album());
    return s;
}

char *inytag_tag_comment(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    char *s = stringToCharArray(t->comment());
    return s;
}

char *inytag_tag_genre(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    char *s = stringToCharArray(t->genre());
    return s;
}

unsigned int inytag_tag_year(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    return t->year();
}

unsigned int inytag_tag_track(const InyTag_Tag *tag) {
    const Tag *t = reinterpret_cast<const Tag *>(tag);
    return t->track();
}

void inytag_tag_set_title(InyTag_Tag *tag, const char *title) {
    Tag *t = reinterpret_cast<Tag *>(tag);
    t->setTitle(charArrayToString(title));
}

void inytag_tag_set_artist(InyTag_Tag *tag, const char *artist) {
    Tag *t = reinterpret_cast<Tag *>(tag);
    t->setArtist(charArrayToString(artist));
}

void inytag_tag_set_album(InyTag_Tag *tag, const char *album) {
  Tag *t = reinterpret_cast<Tag *>(tag);
  t->setAlbum(charArrayToString(album));
}

void inytag_tag_set_comment(InyTag_Tag *tag, const char *comment) {
    Tag *t = reinterpret_cast<Tag *>(tag);
    t->setComment(charArrayToString(comment));
}

void inytag_tag_set_genre(InyTag_Tag *tag, const char *genre) {
    Tag *t = reinterpret_cast<Tag *>(tag);
    t->setGenre(charArrayToString(genre));
}

void inytag_tag_set_year(InyTag_Tag *tag, unsigned int year) {
    Tag *t = reinterpret_cast<Tag *>(tag);
    t->setYear(year);
}

void inytag_tag_set_track(InyTag_Tag *tag, unsigned int track) {
    Tag *t = reinterpret_cast<Tag *>(tag);
    t->setTrack(track);
}
int inytag_audioproperties_length(const InyTag_AudioProperties *audioProperties) {
    const AudioProperties *p = reinterpret_cast<const AudioProperties *>(audioProperties);
    return p->length();
}

int inytag_audioproperties_bitrate(const InyTag_AudioProperties *audioProperties) {
    const AudioProperties *p = reinterpret_cast<const AudioProperties *>(audioProperties);
    return p->bitrate();
}

int inytag_audioproperties_samplerate(const InyTag_AudioProperties *audioProperties) {
    const AudioProperties *p = reinterpret_cast<const AudioProperties *>(audioProperties);
    return p->sampleRate();
}

int inytag_audioproperties_channels(const InyTag_AudioProperties *audioProperties) {
    const AudioProperties *p = reinterpret_cast<const AudioProperties *>(audioProperties);
    return p->channels();
}

int inytag_audioproperties_length_seconds(const InyTag_AudioProperties *audioProperties) {
    const AudioProperties *p = reinterpret_cast<const AudioProperties *>(audioProperties);
    return p->lengthInSeconds();
}

int inytag_audioproperties_length_miliseconds(const InyTag_AudioProperties *audioProperties) {
    const AudioProperties *p = reinterpret_cast<const AudioProperties *>(audioProperties);
    return p->lengthInMilliseconds();
}

InyTag_ByteVector *inytag_bytevector_new() {
    return reinterpret_cast<InyTag_ByteVector *>(new ByteVector);
}

void inytag_bytevector_free(InyTag_ByteVector *bytevector) {
    ByteVector *byt = reinterpret_cast<ByteVector *>(bytevector);
    delete byt;
    byt = NULL;
    bytevector = NULL;
}

const char *inytag_bytevector_get_data(InyTag_ByteVector *bytevector) {
    if (bytevector == NULL) {
        return 0;
    }
    ByteVector *byt = reinterpret_cast<ByteVector *>(bytevector);
    return byt->data ();
}

unsigned int *inytag_bytevector_get_size(InyTag_ByteVector *bytevector) {
    if (bytevector == NULL) {
        return 0;
    }
    ByteVector *byt = reinterpret_cast<ByteVector *>(bytevector);
    return reinterpret_cast<unsigned int *>(byt->size ());
}

GdkPixbuf *inytag_bytevector_get_pixbuf(InyTag_ByteVector *bytevector) {
    if (bytevector == NULL) {
        return NULL;
    }
    ByteVector *byt = reinterpret_cast<ByteVector *>(bytevector);
    GdkPixbufLoader *loader;
    GdkPixbuf *pixbuf = NULL;
    loader = gdk_pixbuf_loader_new ();
	GError* error = NULL;
	bool loading = gdk_pixbuf_loader_write (loader, reinterpret_cast<const guchar *>(byt->data ()), (gsize) byt->size (), &error);
    if (loading == TRUE) {
        pixbuf = gdk_pixbuf_loader_get_pixbuf (loader);
    }
    return pixbuf;
}

void inytag_bytevector_set_pixbuf(InyTag_ByteVector *bytevector, GdkPixbuf *pixbuf) {
    if (pixbuf == NULL) {
        return;
    }
    char *buffer;
    gsize size;
	GError* error = NULL;
    ByteVector *ivector = reinterpret_cast<ByteVector *> (bytevector);
    if (gdk_pixbuf_save_to_buffer (pixbuf, &buffer, &size, "jpeg", &error, NULL)) {
        ivector->setData (buffer, size);
    }
    bytevector = reinterpret_cast<InyTag_ByteVector *>(ivector);
}