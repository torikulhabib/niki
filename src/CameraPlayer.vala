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
    public class CameraPlayer : GLib.Object {
        public dynamic Gst.Element videosink;
        private dynamic Gst.Element camera_source;
        private dynamic Gst.Element queue;
        private dynamic Gst.Element gamma;
        private dynamic Gst.Element videobalance;
        public dynamic Gst.Element camerabin;
        private dynamic Gst.Element valve;
        private dynamic Gst.Element videoconvert;
        private dynamic Gst.Element flip_filter;
        private dynamic Gst.Element gaussianblur;
        private dynamic Gst.Element coloreffects;
        private dynamic Gst.Element filter;
        private Gst.Element videosrc;
        private CameraPage? camerapage;
        public signal bool was_capture ();

        private Gst.PbUtils.EncodingProfile create_ogg_profile () {
            Gst.Caps caps = new Gst.Caps.empty_simple ("application/ogg");
            Gst.PbUtils.EncodingContainerProfile container = new Gst.PbUtils.EncodingContainerProfile ("Ogg audio/video", "Standard Ogg/Theora/Vorbis", caps, null);
            caps = new Gst.Caps.empty_simple ("video/x-theora");
            var video_profile = new Gst.PbUtils.EncodingVideoProfile (caps, null, null, 0);
            video_profile.set_variableframerate (true);
            container.add_profile ((Gst.PbUtils.EncodingProfile) video_profile);
            caps = new Gst.Caps.empty_simple ("audio/x-vorbis");
            container.add_profile ((Gst.PbUtils.EncodingProfile) new Gst.PbUtils.EncodingAudioProfile (caps, null, null, 0));
            return (Gst.PbUtils.EncodingProfile) container;
        }

        private Gst.PbUtils.EncodingProfile create_webm_profile () {
            Gst.Caps caps = new Gst.Caps.empty_simple ("video/webm");
            Gst.PbUtils.EncodingContainerProfile container = new Gst.PbUtils.EncodingContainerProfile ("webm", null, caps, null);
            caps = new Gst.Caps.empty_simple ("video/x-vp8");
            var video_profile = new Gst.PbUtils.EncodingVideoProfile (caps, null, null, 0);
            video_profile.set_variableframerate (true);
            container.add_profile ((Gst.PbUtils.EncodingProfile) video_profile);
            caps = new Gst.Caps.empty_simple ("audio/x-vorbis");
            container.add_profile ((Gst.PbUtils.EncodingProfile) new Gst.PbUtils.EncodingAudioProfile (caps, null, null, 0));
            return (Gst.PbUtils.EncodingProfile) container;
        }

        private Gst.PbUtils.EncodingProfile create_mkv_profile () {
            Gst.Caps caps = new Gst.Caps.empty_simple ("video/x-matroska");
            Gst.PbUtils.EncodingContainerProfile container = new Gst.PbUtils.EncodingContainerProfile ("mkv", null, caps, null);
            caps = new Gst.Caps.empty_simple ("video/x-h264");
            var video_profile = new Gst.PbUtils.EncodingVideoProfile (caps, null, null, 1);
            video_profile.set_variableframerate (true);
            container.add_profile ((Gst.PbUtils.EncodingProfile) video_profile);
            caps = new Gst.Caps.empty_simple ("audio/x-opus");
            container.add_profile ((Gst.PbUtils.EncodingProfile) new Gst.PbUtils.EncodingAudioProfile (caps, null, null, 1));
            return (Gst.PbUtils.EncodingProfile) container;
        }

        private Gst.PbUtils.EncodingProfile create_mp4_profile () {
            Gst.Caps caps = new Gst.Caps.simple ("video/quicktime", "variant", Type.STRING, "iso");
            Gst.PbUtils.EncodingContainerProfile container = new Gst.PbUtils.EncodingContainerProfile ("mp4", null, caps, null);
            caps = new Gst.Caps.empty_simple ("video/x-h264");
            container.add_profile ((Gst.PbUtils.EncodingProfile) new Gst.PbUtils.EncodingVideoProfile (caps, null, null, 1));
            caps = new Gst.Caps.simple ("audio/mpeg", "version", Type.INT, 4);
            container.add_profile ((Gst.PbUtils.EncodingProfile) new Gst.PbUtils.EncodingAudioProfile (caps, null, null, 1));
            return (Gst.PbUtils.EncodingProfile) container;
        }

        public CameraPlayer (CameraPage camerapage) {
            this.camerapage = camerapage;
            camerabin = Gst.ElementFactory.make ("camerabin", "camerabin");
            camerabin.set_state (Gst.State.NULL);
            videosink = ClutterGst.create_video_sink ();
            camerabin["viewfinder-sink"] = videosink;
            camera_source = Gst.ElementFactory.make ("wrappercamerabinsrc", "wrappercamerabinsrc");
            camerabin["camera-source"] = camera_source;
            camera_source.get ("video-source", out videosrc);
            camera_source["video-source-filter"] = setup_video_filter_bin ();
            Gst.Bus bus = camerabin.get_bus ();
            bus.add_signal_watch ();
            bus.message.connect (bus_message_cb);
        }
        public void video_source (string device_name) {
            if (videosrc != null && device_name != null && ((ObjectClass)videosrc).find_property ("device") != null) {
                videosrc["device"] = device_name;
            }
        }

        private Gst.Element setup_video_filter_bin () {
            queue = Gst.ElementFactory.make ("queue", "queue");
            queue["flush-on-eos"] = true;
            valve = Gst.ElementFactory.make ("valve", "valve");
            gamma = Gst.ElementFactory.make ("gamma", "gamma");
            videobalance = Gst.ElementFactory.make ("videobalance", "videobalance");
            videoconvert = Gst.ElementFactory.make ("videoconvert", "videoconvert");
            flip_filter = Gst.ElementFactory.make ("videoflip", "videoflip");
            gaussianblur = Gst.ElementFactory.make("gaussianblur","gaussianblur");
            coloreffects = Gst.ElementFactory.make ("coloreffects","coloreffects");
            filter = Gst.ElementFactory.make ("capsfilter", "capsfilter");
            Gst.Element bin = new Gst.Bin ("video_filter");
            ((Gst.Bin) bin).add_many (queue, filter, coloreffects, flip_filter, gamma,  videobalance, gaussianblur, videoconvert);
            bin.add_pad (new Gst.GhostPad ("sink", queue.get_static_pad ("sink")));
            bin.add_pad (new Gst.GhostPad ("src", videoconvert.get_static_pad ("src")));
            queue.link_many (filter, coloreffects, flip_filter, gamma,  videobalance, gaussianblur, videoconvert);
            return bin;
        }
        public void size_camera (int width, int height) {
            Gst.Util.set_object_arg ((GLib.Object) filter, "caps", @"video/x-raw, width=(int)$(width), height=(int)$(height), format={ RGBA, RGB, I420, YV12, YUY2, UYVY, AYUV, Y41B, Y42B, YVYU, Y444, v210, v216, NV12, NV21, UYVP, A420, YUV9, YVU9, IYU1 }");
        }
        private void coloreffect () {
            coloreffects["preset"] = NikiApp.settings.get_int ("coloreffect-mode");
        }
        public void init_open () {
            flip_mode ();
            profile_change ();
            coloreffect ();
            NikiApp.settings.changed["camera-profile"].connect (profile_change);
            NikiApp.settings.changed["mode-flip"].connect (flip_mode);
            NikiApp.settings.changed["coloreffect-mode"].connect (coloreffect);
        }
        private void video_camera () {
            if (!NikiApp.settings.get_boolean ("camera-video")) {
                camerabin["mode"] = 1;
                play_sound ("camera-shutter");
                if (!NikiApp.settings.get_boolean ("flash-camera")) {
                    var cameraflash = new CameraFlash ();
                    cameraflash.flash_now ();
                    cameraflash.capture_now.connect (()=> {
                        GLib.Signal.emit_by_name (camerabin, "start-capture");
                        return Source.REMOVE;
                    });
                } else {
                    GLib.Signal.emit_by_name (camerabin, "start-capture");
                }
            } else {
                play_sound ("bell");
                camerabin["mode"] = 2;
                GLib.Signal.emit_by_name (camerabin, "start-capture");
            }
        }
        private void flip_mode () {
            flip_filter["method"] = NikiApp.settings.get_boolean ("mode-flip")? 0 : 4;
        }
        private void profile_change () {
            Gst.State state = Gst.State.NULL;
            camerabin.get_state (out state, null, 0);
            if (state == Gst.State.PLAYING) {
                camerabin.set_state (Gst.State.PAUSED);
            }
            switch (NikiApp.settings.get_enum ("camera-profile")) {
                case CameraProfile.OGG:
                    camerabin["video-profile"] = create_ogg_profile ();
                    camerabin.set_state (Gst.State.NULL);
                    break;
                case CameraProfile.WEBM:
                    camerabin["video-profile"] = create_webm_profile ();
                    camerabin.set_state (Gst.State.NULL);
                    break;
                case CameraProfile.MKV:
                    camerabin["video-profile"] = create_mkv_profile ();
                    camerabin.set_state (Gst.State.NULL);
                    break;
                case CameraProfile.MP4:
                    camerabin["video-profile"] = create_mp4_profile ();
                    camerabin.set_state (Gst.State.NULL);
                    break;
            }
            camerabin.set_state (Gst.State.PLAYING);
        }

        private bool ready_capture () {
            bool ready_for_capture;
            camera_source.get ("ready-for-capture", out ready_for_capture);
            return ready_for_capture;
        }
        public void set_null () {
            camerabin.set_state (Gst.State.NULL);
        }

        public void input_zoom (double input) {
            camerabin["zoom"] = input;
        }
        public void capture_video_photo () {
            if (!ready_capture ()) {
                return;
            }
            camerabin["location"] = set_filename_media ();
            video_camera ();
        }
        public void player_stop_recording () {
            play_sound ("complete");
            GLib.Signal.emit_by_name (camerabin, "stop-capture");
        }

        private void bus_message_cb (Gst.Message message) {
            switch (message.type) {
                case Gst.MessageType.ELEMENT:
                    if (message.src.name == "camerabin") {
                        unowned Gst.Structure structure = message.get_structure ();
                        if (structure.get_name () == "image-done") {
                            camerapage.string_notify (StringPot.Photo_Saved);
                            was_capture ();
                        } else if (structure.get_name () == "video-done") {
                            camerapage.string_notify (StringPot.Video_Saved);
                            was_capture ();
                        }
                    }
                    break;
            }
        }
        public void setvalue (int index, int valuescale) {
            switch (index) {
                case 0 :
                    gamma["gamma"] = (double) ((101.1 + valuescale)/100.0);
                    break;
                case 1 :
                    videobalance["brightness"] = (double) valuescale / 100.0;
                    break;
                case 2 :
                    videobalance["contrast"] = (double) ((100.0 + valuescale)/100.0);
                    break;
                case 3 :
                    videobalance["saturation"] = (double) ((100.0 + valuescale)/100.0);
                    break;
                case 4 :
                    videobalance["hue"] = (double) valuescale / 100.0;
                    break;
                case 5 :
                    gaussianblur["sigma"] = (double) ((valuescale)/100.0);
                    break;
            }
        }

        public Gee.Collection<CameraPreset> get_presets () {
            var camera_preset = new Gee.TreeSet<CameraPreset> ();
            foreach (string preset in NikiApp.settingsCv.get_strv ("custom-presets")) {
                camera_preset.add (new CameraPreset.from_string (preset));
            }
            return camera_preset;
        }
        private static Gee.TreeSet<CameraPreset>? default_presets = null;
        public static Gee.Collection<CameraPreset> get_default_presets () {
            if (default_presets != null) {
                return default_presets;
            }
            default_presets = new Gee.TreeSet<CameraPreset> ();
            default_presets.add (new CameraPreset.with_value (StringPot.Normal, {0, 0, 0, 0, 0, 0}));
            default_presets.add (new CameraPreset.with_value (StringPot.Vivid, {15, 5, 5, 35, 0, 0}));
            default_presets.add (new CameraPreset.with_value (StringPot.Bright, {5, 10, 10, 10, 0, 0}));
            default_presets.add (new CameraPreset.with_value (StringPot.Full_Color, {0, -1, -1, 100, 0, 0}));
            default_presets.add (new CameraPreset.with_value (StringPot.No_Color, {0, 0, 10, -100, 0, 0}));
            default_presets.add (new CameraPreset.with_value (StringPot.Soft, {0, 0, -10, 0, 0, 0}));
            return default_presets;
        }
    }
}
