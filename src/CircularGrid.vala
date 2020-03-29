namespace niki {
    public class CircularGrid : Gtk.Grid {
        private CircularProgressBar circularprogressbar;

        construct {
            circularprogressbar = new CircularProgressBar ();
            valign = Gtk.Align.CENTER;
            halign = Gtk.Align.CENTER;
            add (circularprogressbar);
        }
        public void circular_clear () {
            circularprogressbar.percentage = 0.0;
            circularprogressbar.count_file = 0;
        }
        public void count_uri (Gtk.ListStore liststore) {
            int n_child = liststore.iter_n_children (null);
            double count_to = 0.0;
            int pers_to = 0;
            if (n_child <= 100) {
                count_to = 100 / (double) n_child;
                pers_to = 100;
            } else if (n_child > 100 && n_child <= 1000) {
                count_to = 1000 / (double) n_child;
                pers_to = 1000;
            } else if (n_child > 1000 && n_child <= 10000) {
                count_to = 10000 / (double) n_child;
                pers_to = 10000;
            } else if (n_child > 10000 && n_child <= 100000) {
                count_to = 100000 / (double) n_child;
                pers_to = 100000;
            }
            int count = 1;
            double count_pro = count_to;
            Timeout.add (50,()=> {
                circularprogressbar.percentage = count_pro / pers_to;
                circularprogressbar.count_file = count;
                string filename;
                Gtk.TreeIter iter;
                liststore.get_iter_from_string (out iter, (count - 1).to_string ());
                if (liststore.iter_is_valid (iter)) {
                    liststore.get (iter, 0, out filename);
                    if (filename != null) {
                        NikiApp.window.player_page.playlist_widget ().add_item (File.new_for_uri (filename));
                    }
                }
                count ++;
                count_pro = count_pro + count_to;
                if (count > n_child) {
		            if (NikiApp.window.main_stack.visible_child_name == "welcome") {
		                if (NikiApp.window.welcome_page.index_but == 3) {
                            NikiApp.window.main_stack.visible_child_name = "player";
                            NikiApp.window.player_page.get_first ();
                        } else {
                            NikiApp.window.player_page.play_first_in_playlist ();
                        }
                    }
                    return false;
                } else {
                    return true;
                }
            });
        }
    }
}
