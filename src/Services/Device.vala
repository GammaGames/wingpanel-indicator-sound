/*
 * Copyright (c) 2015-2017 elementary LLC. (http://launchpad.net/wingpanel-indicator-sound)
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
 * License along with this program; If not, see <http://www.gnu.org/licenses/>.
 *
 */

[DBus (name = "org.bluez.Device1")]
public interface Sound.Services.Device : Object {
	public abstract void cancel_pairing () throws GLib.Error;
	public abstract void connect () throws GLib.Error;
	public abstract void connect_profile (string UUID) throws GLib.Error;
	public abstract void disconnect () throws GLib.Error;
	public abstract void disconnect_profile (string UUID) throws GLib.Error;
	public abstract void pair () throws GLib.Error;

	public abstract string[] UUIDs { owned get; }
	public abstract bool blocked { get; set; }
	public abstract bool connected { get; }
	public abstract bool legacy_pairing { get; }
	public abstract bool paired { get; }
	public abstract bool trusted { get; set; }
	public abstract int16 RSSI { get; }
	public abstract ObjectPath adapter { owned get; }
	public abstract string address { owned get; }
	public abstract string alias { owned get; set; }
	public abstract string icon { owned get; }
	public abstract string modalias { owned get;  }
	public abstract string name { owned get; }
	public abstract uint16 appearance { get; }
	public abstract uint32 @class { get; }
}

// This is a read-only class, set the properties via PulseAudioManager.
public class Sound.Device : GLib.Object {
    public class Port {
        public string name;
        public string description;
        public uint32 priority;
    }

    public signal void removed ();

    public bool input { get; set; default=true; }
    public uint32 index { get; construct; default=0U; }
    public string name { get; set; }
    public string display_name { get; set; }
    public string form_factor { get; set; }
    public bool is_default { get; set; default=false; }
    public bool is_muted { get; set; default=false; }
    public PulseAudio.CVolume cvolume { get; set; }
    public double volume { get; set; default=0; }
    public float balance { get; set; default=0; }
    public PulseAudio.ChannelMap channel_map { get; set; }
    public Gee.LinkedList<PulseAudio.Operation> volume_operations;
    public Gee.ArrayList<Port> ports { get; set; }
    public Port? default_port { get; set; default=null; }

    public Device (uint32 index) {
        Object (index: index);
    }

    construct {
        volume_operations = new Gee.LinkedList<PulseAudio.Operation> ();
        ports = new Gee.ArrayList<Port> ();
    }

    public string get_nice_form_factor () {
        switch (form_factor) {
            case "internal":
                return _("Built-in");
            case "speaker":
                return _("Speaker");
            case "handset":
                return _("Handset");
            case "tv":
                return _("TV");
            case "webcam":
                return _("Webcam");
            case "microphone":
                return _("Microphone");
            case "headset":
                return _("Headset");
            case "headphone":
                return _("Headphone");
            case "hands-free":
                return _("Hands-Free");
            case "car":
                return _("Car");
            case "hifi":
                return _("HiFi");
            case "computer":
                return _("Computer");
            case "portable":
                return _("Portable");
            default:
                return input? _("Input") : _("Output");
        }
    }

    private const string BASE_ICON_NAME = "audio-";
    private const string SYMBOLIC = "-symbolic";
    public string get_nice_icon () {
        string modifier;
        switch (form_factor) {
            case "handset":
                modifier = "headset";
                break;
            case "headset":
                modifier = "headset";
                break;
            case "headphone":
                modifier = "headphones";
                break;
            case "hifi":
                modifier = "card";
                break;
            default:
                modifier = "speakers";
                break;
        }
        return BASE_ICON_NAME + modifier + SYMBOLIC;
    }
}
