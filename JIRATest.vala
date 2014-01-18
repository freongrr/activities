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

errordomain MyError {
    REQUEST,
    IO,
    INVALID_FORMAT
}

public class JIRATest : Object {

    private Soup.Session session;

    public JIRATest() {
        this.session = new Soup.SessionSync();
    }

    private UrlBuilder api_url() {
        return new UrlBuilder().protocol("https").host("jira.atlassian.com").path("rest/api/latest");
    }

    private void search(string predicate, int start_at, int max_results) throws MyError {
        var url = this.api_url();
        url.path("search");
        url.parameter("jql", predicate);
        url.parameter_int("startAt", start_at);
        url.parameter_int("maxResults", max_results);
        url.parameter("fields", "id,key,summary,worklog");

        var node = this.request(url.to_string());

        this.deserialize_search_results(node);
        // TODO
    }

    private void work_log(string issue_id_or_key) throws MyError {
        var url = this.api_url();
        url.path("issue").path(issue_id_or_key).path("worklog");
        //url.parameter_int("startAt", start_at);
        //url.parameter_int("maxResults", max_results);
        //url.parameter("fields", "id,key,summary,worklog");

        var node = this.request(url.to_string());
        this.deserialize_worklogs(node);
    }

    private Json.Node request(string url) throws MyError {
        stdout.printf("GET %s\n", url);
//        var stream = this.send_request(url);
//        var json = this.stream_content(stream);
        var json = this.http_get(url);
        stdout.printf("RESPONSE: %s\n", json);
        return this.parse_json(json);
    }

    private string http_get(string url) throws MyError {
        try {
            Soup.Message message = new Soup.Message("GET", url);
            this.session.send_message(message);

            // TODO : test message.status_code
            return (string) message.response_body.data;
        } catch (Error e) {
            throw new MyError.REQUEST("Request failed %s", e.message);
        }
    }

/*
    private InputStream send_request(string url) throws MyError {
        try {
            Soup.Request request = this.session.request_http("GET", url);
            InputStream stream = request.send();
            return stream;
        } catch (Error e) {
            throw new MyError.REQUEST("Request failed %s", e.message);
        }
    }

    private string stream_content(InputStream stream) throws MyError {
        try {
            DataInputStream data_stream = new DataInputStream(stream);

            StringBuilder builder = new StringBuilder();
            string? line;
            while ((line = data_stream.read_line()) != null) {
                builder.append(line);
                builder.append("\n");
            }

            return builder.str;
        } catch (GLib.IOError e) {
            throw new MyError.IO("IO error %s", e.message);
        }
    }
*/

    private Json.Node parse_json(string json) throws MyError {
        try {
            Json.Parser parser = new Json.Parser();
            parser.load_from_data(json);
            return parser.get_root();
        } catch (Error e) {
            throw new MyError.INVALID_FORMAT("Can't parse response: %s", e.message);
        }
    }

    private void deserialize_search_results(Json.Node node) throws MyError {
        if (node.get_node_type () != Json.NodeType.OBJECT) {
            throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
        }

        // TODO : store in a list and return it

        var wrapper = node.get_object();
        var issues = wrapper.get_array_member("issues");
        issues.foreach_element((array, index, element_node) => {
            // TODO : how do we handle exceptions here?
            this.deserialize_issue(element_node);
        });
    }

    private void deserialize_issue(Json.Node node) throws MyError {
        if (node.get_node_type () != Json.NodeType.OBJECT) {
            throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
        }

        var issue = node.get_object();
        var fields = issue.get_object_member("fields");

        var remote_id = issue.get_string_member("id");
        var key = issue.get_string_member("key");
        var summary = fields.get_string_member("summary");

        stdout.printf("--- Task ---\n");
        stdout.printf("id: %s\n", remote_id);
        stdout.printf("key: %s\n", key);
        stdout.printf("summary: %s\n", summary);

        var worklog_wrapper = fields.get_member("worklog");
        this.deserialize_worklogs(worklog_wrapper);
    }

    private void deserialize_worklogs(Json.Node node) throws MyError {
        if (node.get_node_type () != Json.NodeType.OBJECT) {
            throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
        }

// TODO : store in a list and return it

        var wrapper = node.get_object();
        var entries = wrapper.get_array_member("worklogs");
        entries.foreach_element((array, index, element_node) => {
            // TODO : how do we handle exceptions here?
            this.deserialize_worklog(element_node);
        });
    }

    private void deserialize_worklog(Json.Node node) throws MyError {
        if (node.get_node_type () != Json.NodeType.OBJECT) {
            throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
        }

        var worklog = node.get_object();
        var remote_id = worklog.get_string_member("id");
        var comment = worklog.get_string_member("comment");
        var started = worklog.get_string_member("started");
        var seconds = worklog.get_string_member("timeSpentSeconds");

        stdout.printf("--- Activity ---\n");
        stdout.printf("id: %s\n", remote_id);
        stdout.printf("comment: %s\n", comment);
        stdout.printf("started: %s\n", started);
        stdout.printf("seconds: %s\n", seconds);
    }

    public static int main(string[] args) {
        try {
            var test = new JIRATest();
            test.search("project = JRA AND updated > \"-7d\"", 0, 10);
//            test.work_/log("JRA-9");
        } catch (MyError e) {
            stderr.printf("MyError: %s\n", e.message);
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
        return 0;
    }
}

internal class UrlBuilder {

    private StringBuilder buffer;
    private string? _protocol;
    private string? _host;
    private int? _port;
    private bool has_query_string = false;

    internal UrlBuilder() {
        this.buffer = new StringBuilder();
    }

    internal string to_string() {
        var copy = new StringBuilder();

        if (this._protocol != null) {
            copy.append(this._protocol);
            copy.append("://");
        }

        if (this._host != null) {
            copy.append(this._host);
        } else if (this._protocol != null || this._port != null) {
            copy.append("localhost");
        }

        if (this._port != null) {
            copy.append(":");
            copy.append(this._port.to_string());
        }

        copy.append(this.buffer.str);
        return copy.str;
    }

    internal UrlBuilder protocol(string protocol) {
        this._protocol = protocol;
        return this;
    }

    internal UrlBuilder host(string host) {
        this._host = host;
        return this;
    }

    internal UrlBuilder port(int port) {
        this._port = port;
        return this;
    }

    internal UrlBuilder path(string path) {
        this.ensure_slash();
        this.buffer.append(path);
        return this;
    }

    internal UrlBuilder parameter(string name, string val) {
        this.append_parameter(name, this.url_encode(val));
        return this;
    }

    internal UrlBuilder parameter_int(string name, int val) {
        this.append_parameter(name, val.to_string());
        return this;
    }

    private void append_parameter(string name, string encoded) {
        if (this.has_query_string) {
            this.buffer.append("&");
        } else {
            this.buffer.append("?");
            has_query_string = true;
        }
        this.buffer.append(name);
        this.buffer.append("=");
        this.buffer.append(encoded);
    }

    private void ensure_slash() {
        if (this.buffer.len == 0 || this.buffer.data[this.buffer.len - 1] != '/') {
            this.buffer.append("/");
        }
    }

    private string url_encode(string url) {
        var encoded = url.replace(" ", "%20");
        encoded = encoded.replace("<", "%3C");
        encoded = encoded.replace("=", "%3D");
        encoded = encoded.replace("\"", "%22");
        return encoded;
    }
}