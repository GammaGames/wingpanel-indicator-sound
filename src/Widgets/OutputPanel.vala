// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2016-2018 elemntary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class Sound.OutputPanel : Gtk.Grid {
    public signal void device_changed ();
    private Gtk.ListBox devices_listbox;
    private unowned PulseAudioManager pam;

    Gtk.Scale volume_scale;
    Gtk.Switch volume_switch;
    Gtk.Scale balance_scale;
    Gtk.ComboBoxText ports_dropdown;

    private Device default_device = null;

    construct {
        margin = 0;
        margin_top = 6;
        column_spacing = 12;
        row_spacing = 6;
        var available_label = new Gtk.Label (_("Available Output Devices:"));
        available_label.halign = Gtk.Align.START;
        available_label.margin_start = 8;
        devices_listbox = new Gtk.ListBox ();
        devices_listbox.activate_on_single_click = true;

        devices_listbox.row_activated.connect(this.row_activated);
        //  var devices_frame = new Gtk.Frame (null);
        //  devices_frame.expand = true;
        //  devices_frame.margin_bottom = 18;
        //  devices_frame.add (devices_listbox);

        var no_device_grid = new Granite.Widgets.AlertView (_("No Output Device"), _("There is no output device detected. You might want to add one to start listening to anything."), "audio-volume-muted-symbolic");
        no_device_grid.show_all ();
        devices_listbox.set_placeholder (no_device_grid);

        attach (available_label, 0, 0, 3, 1);
        attach (devices_listbox, 0, 1, 3, 1);

        pam = PulseAudioManager.get_default ();
        pam.new_device.connect (add_device);
        pam.notify["default-output"].connect (() => {
            default_changed ();
        });

        volume_switch.bind_property ("active", volume_scale, "sensitive", BindingFlags.DEFAULT);
        volume_switch.bind_property ("active", balance_scale, "sensitive", BindingFlags.DEFAULT);

        //  connect_signals ();
    }

    private void row_activated(Gtk.ListBoxRow row) {
        var index = row.get_index();
        Sound.DeviceRow? r = (DeviceRow) devices_listbox.get_row_at_index (index);

        if(r != null) {
            r.set_default();
            device_changed();
        }
    }

    private void default_changed () {
        //  disconnect_signals ();
        lock (default_device) {
            if (default_device != null) {
                default_device.notify.disconnect (device_notify);
            }

            default_device = pam.default_output;
            if (default_device != null) {
                volume_switch.active = !default_device.is_muted;
                volume_scale.set_value (default_device.volume);
                balance_scale.set_value (default_device.balance);

                //  rebuild_ports_dropdown ();

                default_device.notify.connect (device_notify);
            }
        }

        //  connect_signals ();
    }

    //  private void port_changed () {
    //      disconnect_signals ();
    //      pam.context.set_sink_port_by_index (default_device.index, ports_dropdown.active_id);
    //      connect_signals ();
    //  }

    //  private void disconnect_signals () {
    //      volume_switch.notify["active"].disconnect (volume_switch_changed);
    //      volume_scale.value_changed.disconnect (volume_scale_value_changed);
    //      balance_scale.value_changed.disconnect (balance_scale_value_changed);
    //      ports_dropdown.changed.disconnect (port_changed);
    //  }

    //  private void connect_signals () {
    //      volume_switch.notify["active"].connect (volume_switch_changed);
    //      volume_scale.value_changed.connect (volume_scale_value_changed);
    //      balance_scale.value_changed.connect (balance_scale_value_changed);
    //      ports_dropdown.changed.connect (port_changed);
    //  }

    //  private void volume_scale_value_changed () {
    //      disconnect_signals ();
    //      pam.change_device_volume (default_device, (float)volume_scale.get_value ());
    //      connect_signals ();
    //  }

    //  private void balance_scale_value_changed () {
    //      disconnect_signals ();
    //      pam.change_device_balance (default_device, (float)balance_scale.get_value ());
    //      connect_signals ();
    //  }

    //  private void volume_switch_changed () {
    //      disconnect_signals ();
    //      pam.change_device_mute (default_device, !volume_switch.active);
    //      connect_signals ();
    //  }

    private void device_notify (ParamSpec pspec) {
        //  disconnect_signals ();
        //  switch (pspec.get_name ()) {
        //      case "is-muted":
        //          volume_switch.active = !default_device.is_muted;
        //          break;
        //      case "volume":
        //          volume_scale.set_value (default_device.volume);
        //          break;
        //      case "balance":
        //          balance_scale.set_value (default_device.balance);
        //          break;
        //      case "default-port":
        //          if (default_device.default_port != null) {
        //              ports_dropdown.active_id = default_device.default_port.name;
        //          }

        //          break;
        //      case "ports":
        //          rebuild_ports_dropdown ();
        //          break;
        //  }

        //  connect_signals ();
    }

    //  private void rebuild_ports_dropdown () {
    //      ports_dropdown.remove_all ();
    //      ports_dropdown.sensitive = !default_device.ports.is_empty;

    //      foreach (var port in default_device.ports) {
    //          ports_dropdown.append (port.name, port.description);
    //      }

    //      if (default_device.default_port != null) {
    //          ports_dropdown.active_id = default_device.default_port.name;
    //      }
    //  }

    private void add_device (Device device) {
        if (device.input) {
            return;
        }

        var device_row = new DeviceRow (device);
        Gtk.ListBoxRow? row = devices_listbox.get_row_at_index (0);
        if (row != null) {
            device_row.link_to_row ((DeviceRow) row);
        }

        device_row.show_all ();
        devices_listbox.add (device_row);
        device_row.set_as_default.connect (() => {
            pam.set_default_device (device);
        });
    }
}
