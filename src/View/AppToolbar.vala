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

    public class AppToolbar : Gtk.HeaderBar {

        public AppMenu menu { get; private set; }
        public Gtk.ToolButton new_button { get; private set; }
        public Gtk.ToolButton resume_button { get; private set; }
        public Gtk.ToolButton stop_button { get; private set; }
        public Gtk.ToolButton delete_button { get; private set; }

        public AppToolbar() {
            show_close_button = true;
            get_style_context().add_class("primary-toolbar");

            this.menu = new AppMenu();
            this.new_button = this.create_new_button();
            this.resume_button = this.create_resume_button();
            this.stop_button = this.create_stop_button();
            this.delete_button = this.create_delete_button();

            pack_start(this.new_button);
            pack_start(this.resume_button);
            pack_start(this.stop_button);
            pack_start(this.delete_button);
            pack_end(this.create_app_menu());
        }

        private Gtk.ToolButton create_new_button() {
            Gtk.Image image = new Gtk.Image.from_icon_name("document-new", Gtk.IconSize.SMALL_TOOLBAR);
            Gtk.ToolButton button = new Gtk.ToolButton(image, null);
            return button;
        }

        private Gtk.ToolButton create_resume_button() {
            Gtk.Image image = new Gtk.Image.from_icon_name("media-playback-start", Gtk.IconSize.SMALL_TOOLBAR);
            Gtk.ToolButton button = new Gtk.ToolButton(image, null);
            return button;
        }

        private Gtk.ToolButton create_stop_button() {
            Gtk.Image image = new Gtk.Image.from_icon_name("media-playback-stop", Gtk.IconSize.SMALL_TOOLBAR);
            Gtk.ToolButton button = new Gtk.ToolButton(image, null);
            return button;
        }

        private Gtk.ToolButton create_delete_button() {
            Gtk.Image image = new Gtk.Image.from_icon_name("edit-delete", Gtk.IconSize.SMALL_TOOLBAR);
            Gtk.ToolButton button = new Gtk.ToolButton(image, null);
            return button;
        }

        private Granite.Widgets.AppMenu create_app_menu() {
            var appMenu = new Granite.Widgets.AppMenu(menu);
            return appMenu;
        }
    }
}