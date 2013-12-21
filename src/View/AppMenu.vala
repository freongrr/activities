/***
  Copyright (C) 2013-2014 Fabien Cortina <fabien.cortina@gmail.com>
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as published
  by the Free Software Foundation.
  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE. See the GNU General Public License for more details.
  You should have received a copy of the GNU General Public License along
  with this program. If not, see 
***/

namespace TimeShift.View {

    public class AppMenu : Gtk.Menu {

        public Gtk.MenuItem about { get; private set; }

        public AppMenu() {
            about = new Gtk.MenuItem.with_label(_("About"));
            append(about);
        }
    }
}