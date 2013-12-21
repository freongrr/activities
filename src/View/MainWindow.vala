/***
  BEGIN LICENSE

  Copyright(C) 2013-2014 Fabien Cortina <fabien.cortina@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

  END LICENSE
***/

namespace Activities.View {

    public class MainWindow : Gtk.Window {

        public MainWindow(string title) {
            this.title = title;
            this.icon_name = "preferences-system-time";
            this.set_size_request(700, 400);

var library_category = new Granite.Widgets.SourceList.ExpandableItem ("Libraries");
var store_category = new Granite.Widgets.SourceList.ExpandableItem ("Stores");
var device_category = new Granite.Widgets.SourceList.ExpandableItem ("Devices");

var music_item = new Granite.Widgets.SourceList.Item ("Music");

// "Libraries" will be the parent category of "Music"
library_category.add (music_item);

// We plan to add sub-items to the store, so let's use an expandable item
var my_store_item = new Granite.Widgets.SourceList.ExpandableItem ("My Store");
store_category.add (my_store_item);

var my_store_podcast_item = new Granite.Widgets.SourceList.Item ("Podcasts");
var my_store_music_item = new Granite.Widgets.SourceList.Item ("Music");

my_store_item.add (my_store_music_item);
my_store_item.add (my_store_podcast_item);

var player1_item = new Granite.Widgets.SourceList.Item ("Player 1");
var player2_item = new Granite.Widgets.SourceList.Item ("Player 2");

device_category.add (player1_item);
device_category.add (player2_item);

var source_list = new Granite.Widgets.SourceList ();


var root = source_list.root;

root.add (library_category);
root.add (store_category);
root.add (device_category);

var pane = new Granite.Widgets.ThinPaned ();
pane.pack1 (source_list, true, false);
pane.pack2 (new Gtk.Label("Hello Again World!"), true, false);

this.add(pane);

        }
    }
}