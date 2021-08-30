/*
* Copyright (c) {2020} torikulhabib (https://github.com/torikulhabib)
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
    public class ListView : Gtk.Grid {
        public Gtk.Stack stack;
        public musiclist musiclist;
        public BottomList bottomlist;

        public ListView (PlayerPage playerpage) {
            var artist_music = new Granite.Widgets.SourceList.Item ("Artist");
            artist_music.icon = new GLib.ThemedIcon ("avatar-default");

            var album_music = new Granite.Widgets.SourceList.Item ("Album");
            album_music.icon = new GLib.ThemedIcon ("media-optical");

            var music_item = new Granite.Widgets.SourceList.ExpandableItem ("Music");
            music_item.icon = new GLib.ThemedIcon ("library-music");
            music_item.expand_all ();
            music_item.add (artist_music);
            music_item.add (album_music);

            var video_item = new Granite.Widgets.SourceList.Item ("Video");
            video_item.badge = "1";
            video_item.icon = new GLib.ThemedIcon ("folder-videos");

            var library_category = new Granite.Widgets.SourceList.ExpandableItem ("Libraries");
            library_category.expand_all ();
            library_category.add (music_item);
            library_category.add (video_item);

            var quee_music = new Granite.Widgets.SourceList.Item ("Quee");
            quee_music.icon = new GLib.ThemedIcon ("playlist-queue");

            var play_item = new Granite.Widgets.SourceList.ExpandableItem ("Playlist");
            play_item.expand_all ();
            play_item.add (quee_music);

            var source_list = new Granite.Widgets.SourceList ();
            source_list.root.add (library_category);
            source_list.root.add (play_item);

            musiclist = new musiclist ();
            bottomlist = new BottomList (playerpage);

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            stack.homogeneous = false;
            stack.transition_duration = 500;
            stack.add_named (musiclist, "musiclist");

            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.position = 130;
            paned.pack1 (source_list, false, false);
            paned.add2 (stack);
            orientation = Gtk.Orientation.VERTICAL;
            width_request = 750;
            height_request = 500;
            add (paned);
            add (bottomlist);

            source_list.item_selected.connect ((item) => {
                if (item == null) {
                    return;
                }

                if (item.badge != "" && item.badge != null) {
                    item.badge = "";
                }
                stack.visible_child_name = item.parent.name == "Libraries" && item.name == "Music"? "musiclist" : "sdf";
            });
        }
    }
}
