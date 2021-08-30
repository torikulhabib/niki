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
    public class MakeLyric : Gtk.Grid {
        private Gtk.TreeView tree_view;
        private Gtk.ScrolledWindow lrc_text;
        private Gtk.ScrolledWindow lrc_scr;
        private Gtk.ListStore listmodel;
        public Gtk.Stack stack;
        public Gtk.TextView text_lrc;
        private Gtk.Button new_lrc_blk;
        private Gtk.Button load_but;
        private ButtonRevealer? get_fol_rev;
        private string uri_this;

        public MakeLyric (BottomBar bottombar, PlayerPage playerpage) {
            listmodel = new Gtk.ListStore (LyricColumns.N_COLUMNS, typeof (string), typeof (string));
            tree_view = new Gtk.TreeView () {
                model = listmodel,
                reorderable = true,
                headers_visible = true
            };
            tree_view.get_style_context ().add_class ("makerlyric");

            var text_render = new Gtk.CellRendererText () {
                editable = true
            };

            tree_view.set_search_column (LyricColumns.LYRIC);
            tree_view.insert_column_with_attributes (-1, _("Time"), new Gtk.CellRendererText (), "markup", LyricColumns.TIMEVIEW);
            tree_view.insert_column_with_attributes (-1, _("Lyric"), text_render, "text", LyricColumns.LYRIC);

            text_render.edited.connect ((path, new_text) => {
                listmodel.set (selected_iter (), LyricColumns.LYRIC, new_text);
            });
            var add_doc = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.lrc-file-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Open Text")
            };
            add_doc.get_style_context ().add_class ("button_action");
            add_doc.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            add_doc.clicked.connect (()=> {
                var file = run_open_file (this, false, 3);
                if (file != null) {
                    load_text (file[0]);
                }
            });
            var add_but = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Add List")
            };
            add_but.get_style_context ().add_class ("button_action");
            add_but.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            add_but.clicked.connect (() => {
                Gtk.TreeIter iter;
                listmodel.append (out iter);
                listmodel.set (iter, LyricColumns.TIMEVIEW, "00:00", LyricColumns.LYRIC, "Niki Lyric");
            });
            var insert_aft = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.insert-after-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Insert After")
            };
            insert_aft.get_style_context ().add_class ("button_action");
            insert_aft.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            insert_aft.clicked.connect (() => {
                Gtk.TreeIter iter_in = selected_iter ();
                if (!listmodel.iter_is_valid (iter_in)) {
                    return;
                }
                Gtk.TreeIter iter;
                listmodel.insert_after (out iter, iter_in);
                listmodel.set (iter, LyricColumns.TIMEVIEW, "00:00", LyricColumns.LYRIC, "Niki Lyric");
            });
            var insert_bef = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.insert-before-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Insert Before")
            };
            insert_bef.get_style_context ().add_class ("button_action");
            insert_bef.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            insert_bef.clicked.connect (() => {
                Gtk.TreeIter iter_in = selected_iter ();
                if (!listmodel.iter_is_valid (iter_in)) {
                    return;
                }
                Gtk.TreeIter iter;
                listmodel.insert_before (out iter, iter_in);
                listmodel.set (iter, LyricColumns.TIMEVIEW, "00:00", LyricColumns.LYRIC, "Niki Lyric");
            });
            var remove_but = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Remove List")
            };
            remove_but.get_style_context ().add_class ("button_action");
            remove_but.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            remove_but.clicked.connect (() => {
                Gtk.TreeIter iter = selected_iter ();
                if (!listmodel.iter_is_valid (iter)) {
                    return;
                }
                listmodel.remove (ref iter);
            });

            new_lrc_blk = new Gtk.Button.from_icon_name ("document-new-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false
            };
            new_lrc_blk.get_style_context ().add_class ("button_action");
            new_lrc_blk.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            load_but = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Edit Exist Lyric")
            };
            load_but.get_style_context ().add_class ("button_action");
            load_but.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            load_but.clicked.connect (() => {
                uri_this = NikiApp.settings.get_string ("uri-video");
                if (!NikiApp.settings.get_boolean ("lyric-available")) {
                    return;
                }

                clear_listmodel ();
                bottombar.seekbar_widget.lyric.foreach ((item) => {
                    Gtk.TreeIter iter;
                    listmodel.append (out iter);
                    listmodel.set (iter, LyricColumns.TIMEVIEW, seconds_to_time ((int)item.key / 1000000), LyricColumns.LYRIC, (item.value));
                    return true;
                });
            });

            var save_but = new Gtk.Button.from_icon_name ("com.github.torikulhabib.niki.file-save-symbolic", Gtk.IconSize.BUTTON) {
                focus_on_click = false,
                tooltip_text = _("Save Lyric")
            };
            save_but.get_style_context ().add_class ("button_action");
            save_but.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            save_but.clicked.connect (() => {
                int b =listmodel.iter_n_children (null);
                if (b < 2) {
                    return;
                }
                switch (NikiApp.settings.get_int ("location-save")) {
                    case 0 :
                        var lrc_file = Path.build_filename (get_path_noname (uri_this), @"$(get_name_noext (uri_this)).lrc");
                        save_to_file (lrc_file);
                        break;
                    case 1 :
                        var lrc_file = Path.build_filename (NikiApp.settings.get_string ("lyric-location"), get_name_noext (uri_this) + ".lrc");
                        save_to_file (lrc_file);
                        break;
                    case 2 :
                        var file = run_open_folder (this);
                        if (file != null) {
                            var lrc_file = Path.build_filename (file.get_path (), get_name_noext (uri_this) + ".lrc");
                            save_to_file (lrc_file);
                        }
                        break;
                }
            });

            get_fol_rev = new ButtonRevealer ("com.github.torikulhabib.niki.folder-symbolic") {
                transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
                transition_duration = 500
            };
            get_fol_rev.button.tooltip_text = _("Folder Location");
            get_fol_rev.button.get_style_context ().add_class ("button_action");
            get_fol_rev.button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            get_fol_rev.clicked.connect (() => {
                var file = run_open_folder (this);
                if (file != null) {
                    NikiApp.settings.set_string ("lyric-location", file.get_path ());
                }
            });
            var label_make = new Gtk.Label (_("Niki Lyric Maker")) {
                ellipsize = Pango.EllipsizeMode.END
            };
            label_make.get_style_context ().add_class ("button_action");
            label_make.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            var main_actionbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                hexpand = true,
                margin_start = 4,
                margin_end = 4
            };
            main_actionbar.get_style_context ().add_class ("transbgborder");
            main_actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            main_actionbar.pack_start (add_doc, false, false, 0);
            main_actionbar.pack_start (add_but, false, false, 0);
            main_actionbar.pack_start (insert_aft, false, false, 0);
            main_actionbar.pack_start (insert_bef, false, false, 0);
            main_actionbar.pack_start (remove_but, false, false, 0);
            main_actionbar.set_center_widget (label_make);
            main_actionbar.pack_end (save_but, false, false, 0);
            main_actionbar.pack_end (loc_save (), false, false, 0);
            main_actionbar.pack_end (get_fol_rev, false, false, 0);
            main_actionbar.pack_end (load_but, false, false, 0);
            main_actionbar.pack_end (new_lrc_blk, false, false, 0);

            lrc_scr = new Gtk.ScrolledWindow (null, null) {
                propagate_natural_width = true,
                margin_start = 10,
                margin_end = 10
            };
            lrc_scr.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            lrc_scr.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            lrc_scr.size_allocate.connect (resize_scr);
            lrc_scr.add (tree_view);

            text_lrc = new Gtk.TextView ();
            text_lrc.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            text_lrc.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);

            lrc_text = new Gtk.ScrolledWindow (null, null) {
                propagate_natural_width = true,
                margin_start = 10,
                margin_end = 10
            };
            lrc_text.set_policy (Gtk.PolicyType.EXTERNAL, Gtk.PolicyType.AUTOMATIC);
            lrc_text.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            lrc_text.add (text_lrc);

            stack = new Gtk.Stack () {
                transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
                transition_duration = 500,
                vhomogeneous = false
            };
            stack.add_named (lrc_scr, "lyric");
            stack.add_named (lrc_text, "lrctext");
            stack.visible_child = lrc_scr;
            stack.show_all ();

            new_lrc_blk.clicked.connect (() => {
                uri_this = NikiApp.window.player_page.playback.uri;
                stack.visible_child = stack.visible_child == lrc_scr? lrc_text : lrc_scr;
            });
            stack.notify["visible-child"].connect (() => {
                new_img_but ();
                clear_listmodel ();
                if (stack.visible_child == lrc_scr) {
                    string[] datains = text_lrc.buffer.text.split ("\n");
                    List<string> text_list = new List<string> ();
                    for (int i = 0; i < text_lrc.buffer.get_line_count (); i++) {
                        text_list.append (datains [i]);
                    }
                    foreach (var filename in text_list) {
                        Gtk.TreeIter iter;
                        listmodel.append (out iter);
                        listmodel.set (iter, LyricColumns.LYRIC, filename);
                    }
                }
            });

            var layout = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL
            };
            layout.add (stack);
            layout.add (main_actionbar);
            layout.show_all ();
            add (layout);
            show_all ();
            playerpage.size_allocate.connect (resize_scr);
            new_img_but ();
            NikiApp.settings.changed["make-lrc"].connect (() => {
                uri_this = NikiApp.window.player_page.playback.uri;
            });
        }

        public void set_time_sec (int64 time_in) {
            Gtk.TreeIter iter = selected_iter ();
            if (!listmodel.iter_is_valid (iter)) {
                return;
            }
            listmodel.set (iter, LyricColumns.TIMEVIEW, seconds_to_time ((int)time_in));

            if (listmodel.iter_next (ref iter)) {
                tree_view.get_selection ().select_iter (iter);
                tree_view.scroll_to_cell (listmodel.get_path (iter), null, true, 0.5f, 0);
            }
        }

        public void resize_scr () {
            if (NikiApp.settings.get_boolean ("audio-video")) {
                int height;
                NikiApp.window.get_size (null, out height);
                lrc_scr.height_request = height - 158;
                lrc_text.height_request = height - 158;
            }
        }

        private Gtk.TreeIter selected_iter () {
            Gtk.TreeIter iter;
            tree_view.get_selection ().get_selected (null, out iter);
            return iter;
        }

        public void clear_listmodel () {
            int b = listmodel.iter_n_children (null);
            for (int i = 0; i < b; i++) {
                Gtk.TreeIter iter;
                if (listmodel.get_iter_first (out iter)) {
                    listmodel.remove (ref iter);
                }
            }
        }

        private void new_img_but () {
            ((Gtk.Image) new_lrc_blk.image).icon_name = stack.visible_child_name == "lyric"? "document-new-symbolic" : "go-previous-symbolic";
            new_lrc_blk.tooltip_text = stack.visible_child_name == "lyric"? _("Writer") : _("Maker");
        }

        private void save_to_file (string filename) {
            var builder = new StringBuilder ();
            listmodel.foreach ((model, path, iter) => {
                string time_str, lyric_str;
                model.get (iter, LyricColumns.TIMEVIEW, out time_str, LyricColumns.LYRIC, out lyric_str);
                builder.append (@"[$(time_str)]$(lyric_str)\n");
                return false;
            });

            File file = File.new_for_path (filename);
            permanent_delete (file);
            try {
                FileOutputStream out_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
                out_stream.write (builder.str.data);
            } catch (Error e) {
                notify_app (_("Error Make"), _("%s").printf (e.message));
                return;
            }
            notify_app (_("Succes Make"), @"$(_("Save_to")) $(filename)");
        }

        private Gtk.Button loc_save () {
            var locat_button = new Gtk.Button ();
            locat_button.get_style_context ().add_class ("button_action");
            locat_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            locat_button.clicked.connect (() => {
                NikiApp.settings.set_int ("location-save", NikiApp.settings.get_int ("location-save") > 1? 0 : NikiApp.settings.get_int ("location-save") + 1);
                but_symbol (locat_button);
            });
            but_symbol (locat_button);
            return locat_button;
        }

        private void but_symbol (Gtk.Button button) {
            switch (NikiApp.settings.get_int ("location-save")) {
                case 0 :
                    button.set_image (new Gtk.Image.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.BUTTON));
                    button.tooltip_text = _("Location Music");
                    get_fol_rev.set_reveal_child (false);
                    break;
                case 1 :
                    button.set_image (new Gtk.Image.from_icon_name ("com.github.torikulhabib.niki.file-save-as-symbolic", Gtk.IconSize.BUTTON));
                    button.tooltip_text = _("Save to Folder");
                    get_fol_rev.set_reveal_child (true);
                    break;
                case 2 :
                    button.set_image (new Gtk.Image.from_icon_name ("system-help-symbolic", Gtk.IconSize.BUTTON));
                    button.tooltip_text = _("Ask Place");
                    get_fol_rev.set_reveal_child (false);
                    break;
            }
        }

        private void load_text (File file) {
            if (!file.get_uri ().down ().has_suffix (".lrc")) {
                text_lrc.buffer.text = "";
                try {
                    DataInputStream dis = new DataInputStream (file.read ());
                    dis.newline_type = DataStreamNewlineType.ANY;
                    string ln;
                    while ((ln = dis.read_line_utf8 ()) != null) {
                        text_lrc.buffer.text += @"$(ln.strip ()) \n";
                    }
                } catch (Error e) {
                    critical ("%s", e.message);
                }
                stack.visible_child_name = "lrctext";
            } else {
                clear_listmodel ();
                file_lyric (file.get_uri ()).foreach ((item) => {
                    Gtk.TreeIter iter;
                    listmodel.append (out iter);
                    listmodel.set (iter, LyricColumns.TIMEVIEW, seconds_to_time ((int)item.key / 1000000), LyricColumns.LYRIC, (item.value));
                    return true;
                });
                stack.visible_child_name = "lyric";
            }
        }
    }
}
