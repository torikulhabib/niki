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

class Image : public File {
    public:
        Image(const char *filename): File(filename) {}
        ByteVector data() {
            return readBlock(length());
        }
        virtual Tag* tag() const {
            return 0;
        }
        virtual AudioProperties* audioProperties() const {
            return 0;
        }
        virtual bool save() {
            return 0;
        }
};

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

class FrameId3 : public ID3v2::Frame {
    public:
        virtual String toString() const {
            return "";
        }
        virtual void parseFields(const ByteVector &data) {
            return;
        }
        virtual ByteVector renderFields() const {
            return frameID();
        }
};

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

InyTag_Tag *inytag_file_mp4_tag(const InyTag_Mp4_File *file) {
  const File *f = reinterpret_cast<const File *>(file);
  return reinterpret_cast<InyTag_Tag *>(f->tag());
}

void inytag_mp4_file_remove_picture(InyTag_Mp4_File *file) {
    MP4::File *f = reinterpret_cast<MP4::File *>(file);
    MP4::Tag *tag = f->tag();
    if (tag->contains ("covr")) {
        tag->removeItem ("covr");
    }
    file = reinterpret_cast<InyTag_Mp4_File *>(f);
}

void inytag_mp4_file_set_picture(InyTag_Mp4_File *file, InyTag_Format_Type type, const char *imgpath) {
    if (imgpath == NULL) {
        return;
    }
    MP4::File *f = reinterpret_cast<MP4::File *>(file);
    MP4::Tag *tag = f->tag();
    if (!tag->contains ("covr")) {
        tag->item ("covr");
    }
    Image *image = reinterpret_cast<Image *>(new Image(imgpath));
    MP4::CoverArt::Format type_f;
    switch (type) {
        case InyTag_Format_PNG:
            type_f = MP4::CoverArt::Format::PNG;
            break;
        case InyTag_Format_BMP:
            type_f = MP4::CoverArt::Format::BMP;
            break;
        case InyTag_Format_GIF:
            type_f = MP4::CoverArt::Format::GIF;
            break;
        case InyTag_Format_UNKNOWN:
            type_f = MP4::CoverArt::Format::Unknown;
            break;
        default:
            type_f = MP4::CoverArt::Format::JPEG;
            break;
    }
    MP4::CoverArt coverArt(type_f, image->data());
    MP4::CoverArtList coverArtList;
    coverArtList.append(coverArt);
    MP4::Item coverItem(coverArtList);
    tag->setItem("covr", coverItem);
    file = reinterpret_cast<InyTag_Mp4_File *>(f);
}

BOOL inytag_mp4_file_save(InyTag_Mp4_File *file) {
    MP4::File *song_file = reinterpret_cast<MP4::File *>(file);
    return song_file->save();
}

InyTag_Flac_File *inytag_flac_file_new(const char *filename) {
    return reinterpret_cast<InyTag_Flac_File *>(new FLAC::File(filename));
}

void inytag_flac_file_free(InyTag_Flac_File *file) {
    FLAC::File *f = reinterpret_cast<FLAC::File *>(file);
    free(f);
    file = NULL;
}

InyTag_Tag *inytag_file_flac_tag(const InyTag_Flac_File *file) {
  const File *f = reinterpret_cast<const File *>(file);
  return reinterpret_cast<InyTag_Tag *>(f->tag());
}

void inytag_flac_file_remove_picture(InyTag_Flac_File *file) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    song_file->removePictures();
    file = reinterpret_cast<InyTag_Flac_File *>(song_file);
}

void inytag_flac_file_add_picture(InyTag_Flac_File *file, InyTag_Flac_Picture *picture) {
    FLAC::File *song_file = reinterpret_cast<FLAC::File *>(file);
    FLAC::Picture *cover = new FLAC::Picture ();
    FLAC::Picture *pf = reinterpret_cast<FLAC::Picture *>(picture);
    cover->setData (pf->data());
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

void inytag_flac_picture_set_picture(InyTag_Flac_Picture *picture, const char *imgpath) {
    if (imgpath == NULL) {
        return;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    Image *image = reinterpret_cast<Image *>(new Image(imgpath));
    fp->setData(image->data ());
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

void inytag_flac_picture_set_mime_type(InyTag_Flac_Picture *picture, const char *mimetype) {
    if (mimetype == NULL) {
        return;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setMimeType(mimetype);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

void inytag_flac_picture_set_description(InyTag_Flac_Picture *picture, const char *description) {
    if (description == NULL) {
        return;
    }
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setDescription(description);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

void inytag_flac_picture_set_type(InyTag_Flac_Picture *picture, InyTag_Img_Type type) {
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    switch (type) {
        case InyTag_Img_FileIcon:
            fp->setType(FLAC::Picture::FileIcon);
            break;
        case InyTag_Img_OtherFileIcon:
            fp->setType(FLAC::Picture::OtherFileIcon);
            break;
        case InyTag_Img_FrontCover:
            fp->setType(FLAC::Picture::FrontCover);
            break;
        case InyTag_Img_BackCover:
            fp->setType(FLAC::Picture::BackCover);
            break;
        case InyTag_Img_LeafletPage:
            fp->setType(FLAC::Picture::LeafletPage);
            break;
        case InyTag_Img_Media:
            fp->setType(FLAC::Picture::Media);
            break;
        case InyTag_Img_LeadArtist:
            fp->setType(FLAC::Picture::LeadArtist);
            break;
        case InyTag_Img_Artist:
            fp->setType(FLAC::Picture::Artist);
            break;
        case InyTag_Img_Conductor:
            fp->setType(FLAC::Picture::Conductor);
            break;
        case InyTag_Img_Band:
            fp->setType(FLAC::Picture::Band);
            break;
        case InyTag_Img_Composer:
            fp->setType(FLAC::Picture::Composer);
            break;
        case InyTag_Img_Lyricist:
            fp->setType(FLAC::Picture::Lyricist);
            break;
        case InyTag_Img_RecordingLocation:
            fp->setType(FLAC::Picture::RecordingLocation);
            break;
        case InyTag_Img_DuringRecording:
            fp->setType(FLAC::Picture::DuringRecording);
            break;
        case InyTag_Img_DuringPerformance:
            fp->setType(FLAC::Picture::DuringPerformance);
            break;
        case InyTag_Img_MovieScreenCapture:
            fp->setType(FLAC::Picture::MovieScreenCapture);
            break;
        case InyTag_Img_ColouredFish:
            fp->setType(FLAC::Picture::ColouredFish);
            break;
        case InyTag_Img_Illustration:
            fp->setType(FLAC::Picture::Illustration);
            break;
        case InyTag_Img_BandLogo:
            fp->setType(FLAC::Picture::BandLogo);
            break;
        case InyTag_Img_PublisherLogo:
            fp->setType(FLAC::Picture::PublisherLogo);
            break;
        default:
            fp->setType(FLAC::Picture::Other);
            break;
    }
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
}

void inytag_flac_picture_set_width(InyTag_Flac_Picture *picture, int width) {
    FLAC::Picture *fp = reinterpret_cast<FLAC::Picture *>(picture);
    fp->setWidth(width);
    picture = reinterpret_cast<InyTag_Flac_Picture *>(fp);
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

InyTag_ID3v2_Tag *inytag_id3v2_tag(InyTag_Mpeg_File *file) {
    MPEG::File *song_file = reinterpret_cast<MPEG::File *>(file);
    return reinterpret_cast<InyTag_ID3v2_Tag *>(song_file->ID3v2Tag());
}

void inytag_id3v2_tag_add_picture_frame(InyTag_ID3v2_Tag *tag, InyTag_ID3v2_Attached_Picture_Frame *frame) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::AttachedPictureFrame *f = reinterpret_cast<ID3v2::AttachedPictureFrame *>(frame);
    t->addFrame(f);
    tag = reinterpret_cast<InyTag_ID3v2_Tag *>(t);
}

BOOL inytag_id3v2_tag_is_frame_empty(InyTag_ID3v2_Tag *tag, InyTag_Frame_ID frameid) {
    ID3v2::Tag *t = reinterpret_cast<ID3v2::Tag *>(tag);
    ID3v2::FrameList f = t->frameListMap()[GetFrameID (frameid)];
    return f.isEmpty();
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

InyTag_ID3v2_Attached_Picture_Frame *inytag_id3v2_attached_picture_frame_new() {
    return reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(new ID3v2::AttachedPictureFrame);
}

void inytag_id3v2_attached_picture_frame_free(InyTag_ID3v2_Attached_Picture_Frame *picture_frame) {
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    delete pf;
    pf = NULL;
    picture_frame = NULL;
}

void inytag_id3v2_attached_picture_frame_set_mime_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *type) {
    if (type == NULL) {
        return;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setMimeType(type);
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

void inytag_id3v2_attached_picture_frame_set_type(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, InyTag_Img_Type type) {
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    switch (type) {
        case InyTag_Img_FileIcon:
            pf->setType(ID3v2::AttachedPictureFrame::FileIcon);
            break;
        case InyTag_Img_OtherFileIcon:
            pf->setType(ID3v2::AttachedPictureFrame::OtherFileIcon);
            break;
        case InyTag_Img_FrontCover:
            pf->setType(ID3v2::AttachedPictureFrame::FrontCover);
            break;
        case InyTag_Img_BackCover:
            pf->setType(ID3v2::AttachedPictureFrame::BackCover);
            break;
        case InyTag_Img_LeafletPage:
            pf->setType(ID3v2::AttachedPictureFrame::LeafletPage);
            break;
        case InyTag_Img_Media:
            pf->setType(ID3v2::AttachedPictureFrame::Media);
            break;
        case InyTag_Img_LeadArtist:
            pf->setType(ID3v2::AttachedPictureFrame::LeadArtist);
            break;
        case InyTag_Img_Artist:
            pf->setType(ID3v2::AttachedPictureFrame::Artist);
            break;
        case InyTag_Img_Conductor:
            pf->setType(ID3v2::AttachedPictureFrame::Conductor);
            break;
        case InyTag_Img_Band:
            pf->setType(ID3v2::AttachedPictureFrame::Band);
            break;
        case InyTag_Img_Composer:
            pf->setType(ID3v2::AttachedPictureFrame::Composer);
            break;
        case InyTag_Img_Lyricist:
            pf->setType(ID3v2::AttachedPictureFrame::Lyricist);
            break;
        case InyTag_Img_RecordingLocation:
            pf->setType(ID3v2::AttachedPictureFrame::RecordingLocation);
            break;
        case InyTag_Img_DuringRecording:
            pf->setType(ID3v2::AttachedPictureFrame::DuringRecording);
            break;
        case InyTag_Img_DuringPerformance:
            pf->setType(ID3v2::AttachedPictureFrame::DuringPerformance);
            break;
        case InyTag_Img_MovieScreenCapture:
            pf->setType(ID3v2::AttachedPictureFrame::MovieScreenCapture);
            break;
        case InyTag_Img_ColouredFish:
            pf->setType(ID3v2::AttachedPictureFrame::ColouredFish);
            break;
        case InyTag_Img_Illustration:
            pf->setType(ID3v2::AttachedPictureFrame::Illustration);
            break;
        case InyTag_Img_BandLogo:
            pf->setType(ID3v2::AttachedPictureFrame::BandLogo);
            break;
        case InyTag_Img_PublisherLogo:
            pf->setType(ID3v2::AttachedPictureFrame::PublisherLogo);
            break;
        default:
            pf->setType(ID3v2::AttachedPictureFrame::Other);
            break;
    }
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

void inytag_id3v2_attached_picture_frame_set_picture(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *path) {
    if (path == NULL) {
        return;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    Image *image = reinterpret_cast<Image *>(new Image(path));
    pf->setPicture(image->data());
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
}

void inytag_id3v2_attached_picture_frame_set_description(InyTag_ID3v2_Attached_Picture_Frame *picture_frame, const char *desc) {
    if (desc == NULL) {
        return;
    }
    ID3v2::AttachedPictureFrame *pf = reinterpret_cast<ID3v2::AttachedPictureFrame *>(picture_frame);
    pf->setDescription(desc);
    picture_frame = reinterpret_cast<InyTag_ID3v2_Attached_Picture_Frame *>(pf);
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
