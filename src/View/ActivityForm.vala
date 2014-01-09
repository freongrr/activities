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

    internal class ActivityDetailView : Gtk.Box {

        public signal void changed(Model.Activity activity);

        public Model.Activity activity {
            get {
                return this._activity;
            }

            set {
                this._activity = new Model.Activity.copy_from(value);
                this.update_view();
            }
        }

        private Gtk.Entry task_entry;
        private Gtk.Entry description_entry;
        private Gtk.Entry tags_entry;
        private DateTimePicker start_picker;
        private DateTimePicker end_picker;
        private Gtk.TextView notes_text_view;

        private Model.Activity _activity;

        internal ActivityDetailView() {
            this.task_entry = new Gtk.Entry();
            this.task_entry.changed.connect(this.on_changed);

            this.description_entry = new Gtk.Entry();
            this.description_entry.changed.connect(this.on_changed);

            this.start_picker = new DateTimePicker();
            this.start_picker.date_time_changed.connect(this.on_changed);

            this.end_picker = new DateTimePicker();
            this.end_picker.date_time_changed.connect(this.on_changed);

            this.tags_entry = new Gtk.Entry();
            this.tags_entry.changed.connect(this.on_changed);

            this.notes_text_view = new Gtk.TextView();
            this.notes_text_view.buffer.changed.connect(this.on_changed);

            this.layout();
        }

        private void layout() {
            this.orientation = Gtk.Orientation.VERTICAL;
            this.border_width = 10;
            this.spacing = 5;

            this.pack_start(this.create_label("Task"), false, false, 0);
            this.pack_start(this.task_entry, false, false, 0);
            this.pack_start(this.create_label("Start"), false, false, 0);
            this.pack_start(this.start_picker, false, false, 0);
            this.pack_start(this.create_label("End"), false, false, 0);
            this.pack_start(this.end_picker, false, false, 0);
            this.pack_start(this.create_label("Description"), false, false, 0);
            this.pack_start(this.description_entry, false, false, 0);
            this.pack_start(this.create_label("Tags"), false, false, 0);
            this.pack_start(this.tags_entry, false, false, 0);
            this.pack_start(this.create_label("Notes"), false, false, 0);
            this.pack_start(this.create_frame(this.notes_text_view), true, true, 0);
        }

        private Gtk.Label create_label(string text) {
            var label = new Gtk.Label(text);
            label.xalign = 0;
            return label;
        }

        private Gtk.Widget create_frame(Gtk.Widget widget) {
            Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow(null, null);
            scroll.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scroll.add(widget);

            // TODO : no shadow because of a bug?
            // http://stackoverflow.com/questions/13001990/why-is-there-no-a-border-on-this-gtkframe
            Gtk.Frame frame = new Gtk.Frame(null);
            frame.shadow_type = Gtk.ShadowType.IN;
            frame.add(scroll);

            return frame;
        }

        private void on_changed() {
            this._activity.description = this.description_entry.text;
            this._activity.start_date = this.start_picker.date_time;
            this._activity.end_date = this.end_picker.date_time;
            // TODO : other attributes

            stdout.printf("Activity changed: %s\n", this._activity.to_string());
        }

        private void update_view() {
            this.task_entry.text = this._activity.task.key + " - " + this._activity.task.description;
            this.description_entry.text = this._activity.description;
            this.tags_entry.text = this.get_tags_as_string();
            this.start_picker.date_time = this._activity.start_date;
            this.end_picker.date_time = this._activity.end_date;
            this.notes_text_view.buffer.text = this._activity.task.notes;
        }

        private string get_tags_as_string() {
            StringBuilder builder = new StringBuilder();
            foreach (var tag in this._activity.tags) {
                if (builder.len > 0)
                    builder.append(", ");
                builder.append(tag);
            }
            return builder.str;
        }
    }
}