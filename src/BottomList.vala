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
    public class BottomList : Gtk.Grid {
        public SettingsPopover? menu_popover;
        public SeekTimeMusic? seektimemusic;
        public VolumeListMode? volumelistmode;
        private Gtk.Button play_but_cen;
        private Gtk.Button next_button_center;
        private Gtk.Button shuffle_button;
        private Gtk.Button previous_button_center;
        private RepeatButton? repeat_button;

        private bool _playing = false;
        public bool playing {
            get {
                return _playing;
            }
            set {
                _playing = value;
                ((Gtk.Image) play_but_cen.image).icon_name = value? "com.github.torikulhabib.niki.pause-symbolic" : "com.github.torikulhabib.niki.play-symbolic";
                play_but_cen.tooltip_text = value? _("Pause") : _("Play");
            }
        }

        public BottomList (PlayerPage playerpage) {
            events |= Gdk.EventMask.POINTER_MOTION_MASK;
            events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            play_but_cen = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.play-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            play_but_cen.focus_on_click = false;
            play_but_cen.clicked.connect (() => {
                playing = !playing;
            });
            repeat_button = new RepeatButton ();

            shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.BUTTON);
            shuffle_button.focus_on_click = false;
            shuffle_button.clicked.connect (() => {
                NikiApp.settings.set_boolean ("shuffle-button", !NikiApp.settings.get_boolean ("shuffle-button"));
                shuffle_icon ();
            });

            next_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.next-symbolic", Gtk.IconSize.BUTTON);
            next_button_center.focus_on_click = false;
            next_button_center.tooltip_text = _("Next");
            next_button_center.clicked.connect (() => {
                playerpage.next ();
            });

            previous_button_center = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.previous-symbolic", Gtk.IconSize.BUTTON);
            previous_button_center.focus_on_click = false;
            previous_button_center.tooltip_text = _("Previous");
            previous_button_center.clicked.connect (() => {
                playerpage.previous ();
            });

            NikiApp.settings.changed["next-status"].connect (signal_playlist);
            NikiApp.settings.changed["previous-status"].connect (signal_playlist);

            seektimemusic = new SeekTimeMusic (playerpage.playback);
            seektimemusic.halign = Gtk.Align.CENTER;
            volumelistmode = new VolumeListMode ();
            volumelistmode.halign = Gtk.Align.CENTER;

            var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            action_box.spacing = 10;
            action_box.halign = Gtk.Align.CENTER;
            action_box.pack_start (shuffle_button, false, false, 0);
            action_box.pack_start (previous_button_center, false, false, 0);
            action_box.pack_start (play_but_cen, false, false, 0);
            action_box.pack_start (next_button_center, false, false, 0);
            action_box.pack_start (repeat_button, false, false, 0);

            var grid_seek = new Gtk.Grid ();
            grid_seek.orientation = Gtk.Orientation.VERTICAL;
            grid_seek.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            grid_seek.hexpand = true;
            grid_seek.add (seektimemusic);
            grid_seek.add (action_box);
            grid_seek.add (volumelistmode);

            var main_actionbar = new Gtk.ActionBar ();
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.hexpand = true;
            main_actionbar.margin_bottom = 5;
            main_actionbar.set_center_widget (grid_seek);
            add (main_actionbar);
            playerpage.playback.notify["playing"].connect (signal_playlist);
            signal_playlist ();
            shuffle_icon ();
        }
        private void shuffle_icon () {
            ((Gtk.Image) shuffle_button.image).icon_name = NikiApp.settings.get_boolean ("shuffle-button")? "media-playlist-shuffle-symbolic" : "media-playlist-no-shuffle-symbolic";
        }

        private void signal_playlist () {
            previous_button_center.sensitive = NikiApp.settings.get_boolean ("previous-status")? true : false;
            next_button_center.sensitive = NikiApp.settings.get_boolean ("next-status")? true : false;
        }
    }
}
