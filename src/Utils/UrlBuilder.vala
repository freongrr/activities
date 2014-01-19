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

namespace Activities.Utils {

    internal class UrlBuilder : Object {

        private StringBuilder buffer;
        private string? _protocol;
        private string? _host;
        private uint? _port;
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

        internal UrlBuilder port(uint port) {
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
}