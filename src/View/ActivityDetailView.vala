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

        public signal void changed();

        public Model.Activity? activity {
            get {
                return this._activity;
            }

            set {
                if (value == null) {
                    this._activity = null;
                    debug("Setting activity: NULL");
                    this.update_view();
                } else {
                    this._activity = new Model.Activity.copy_from(value);
                    debug("Setting activity: %s", this._activity.to_string());
                    this.update_view();
                }
            }
        }

        internal Model.TaskStore task_store {
            get {
                return (Model.TaskStore) task_completion.get_model();
            }
            set {
                task_completion.set_model(value);
            }
        }

        internal Model.Backend backend;

        private Gtk.EntryCompletion task_completion;
        private Gtk.Entry task_entry;
        private Gtk.Entry description_entry;
        private Gtk.Entry tags_entry;
        private DateTimePicker start_picker;
        private DateTimePicker end_picker;
        private Gtk.TextView notes_text_view;

        private Model.Activity? _activity;
        private bool updating;

        internal ActivityDetailView() {
            task_completion = new Gtk.EntryCompletion();
            task_completion.set_model(new Model.TaskStore());
            task_completion.set_text_column(1);
            task_completion.set_match_func(match_task);
            task_completion.match_selected.connect((model, iter) => {
                if (!updating) {
                    GLib.Value v;
                    model.get_value(iter, 0, out v);
                    this.set_task((Model.Task) v);
                }
                return false;
            });

            this.task_entry = new Gtk.SearchEntry();
            this.task_entry.set_completion(task_completion);
            this.task_entry.changed.connect(() => {
                if (!updating) {
                    this.set_task_from_description(task_entry.text);
                }
            });

            this.description_entry = new Gtk.Entry();
            this.description_entry.changed.connect(() => {
                if (!updating && this._activity != null &&
                      this._activity.description != this.description_entry.text) {
                    this._activity.description = this.description_entry.text;
                    debug("Description changed: %s", this._activity.description);
                    this.changed();
                }
            });

            this.start_picker = new DateTimePicker();
            this.start_picker.date_time_changed.connect(() => {
                if (!updating && this._activity != null &&
                      this._activity.start_date != this.start_picker.date_time) {
                    this._activity.start_date = this.start_picker.date_time;
                    debug("Start date changed: %s", this._activity.start_date.to_string());
                    this.changed();
                }
            });

            this.end_picker = new DateTimePicker();
            this.end_picker.date_time_changed.connect(() => {
                if (!updating && this._activity != null &&
                      this._activity.end_date != this.end_picker.date_time) {
                    this._activity.end_date = this.end_picker.date_time;
                    debug("End date changed: %s", this._activity.end_date.to_string());
                    this.changed();
                }
            });

            this.tags_entry = new Gtk.Entry();
            this.tags_entry.changed.connect(() => {
                if (!updating) {
                  // TODO
                }
            });

            this.notes_text_view = new Gtk.TextView();
            this.notes_text_view.buffer.changed.connect(() => {
                if (updating) {
                  // TODO
                }
            });

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
            this.pack_start(this.create_label("Task Notes"), false, false, 0);
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

        private void update_view() {
            this.updating = true;

            if (this._activity == null) {
                debug("Update view -> clearing fields");

                this.task_entry.sensitive = false;
                this.description_entry.sensitive = false;
                this.tags_entry.sensitive = false;
                this.start_picker.sensitive = false;
                this.end_picker.sensitive = false;
                this.notes_text_view.sensitive = false;

                this.task_entry.text = "";
                this.description_entry.text = "";
                this.tags_entry.text = "";
                this.start_picker.date_time = null;
                this.end_picker.date_time = null;
                this.notes_text_view.buffer.text = "";
            } else {
                debug("Update view -> %s", this._activity.to_string());

                this.task_entry.sensitive = true;
                this.description_entry.sensitive = true;
                this.tags_entry.sensitive = true;
                this.start_picker.sensitive = true;
                this.end_picker.sensitive = true;

                var task = this._activity.task;
                if (task != null) {
                    if (task.key != null) {
                        this.task_entry.text = task.key + " - " + task.description;
                    } else {
                        this.task_entry.text = task.description;
                    }
                } else {
                    this.task_entry.text = "";
                }

                this.description_entry.text = this._activity.description;
                this.tags_entry.text = this.get_tags_as_string();
                this.start_picker.date_time = this._activity.start_date;
                this.end_picker.date_time = this._activity.end_date;
                this.notes_text_view.buffer.text = this._activity.task == null
                    ? "" : this._activity.task.notes;
            }

            this.updating = false;
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

        private bool match_task(Gtk.EntryCompletion completion, string query, Gtk.TreeIter iter) {
            var lower_case_query = query.down();

            GLib.Value store_value;
            completion.model.get_value(iter, 0, out store_value);

            var task = (Model.Task) store_value;
            try {
                return (task.key != null && task.key.down().contains(lower_case_query)) ||
                    task.description.down().contains(lower_case_query);
            } catch (Error e) {
                critical("Error while testing task: " +
                    (task == null ? "NULL" : task.to_string()), e);
                return false;
            }
        }

        private void set_task(Model.Task new_task) {
            var task = this._activity.task;
            if (task == null || task.local_id != new_task.local_id) {
                debug("Task selected: " + new_task.to_string());
                this._activity.task = new_task;
                this.changed();
            }
        }

        private void set_task_from_description(string description) {
            debug("Description changed: " + description);

            // TODO : we should only edit the description of NEW tasks
            // we could check for the remote_id, of if the task is used

            var task = this._activity.task;
            if (task == null) {
                if (this.task_store == null) {
                    warning("The store is null");
                    return;
                }
                task = this.task_store.new_task();
            } else if (task.description == description) {
                return;
            }

            // TODO : update the store?
            task.description = description;

            debug("Task edited: " + task.to_string());
            this._activity.task = task;
            this.changed();
        }
    }
}
