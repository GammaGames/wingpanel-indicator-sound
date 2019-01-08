// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2016-2017 elementary LLC. (https://elementary.io)
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

public class Sound.DeviceRow : Gtk.ListBoxRow {
    public signal void set_as_default ();

    public Device device { get; construct; }
    private Gtk.Label name_label;
    private Gtk.Image img_form;
    private Gtk.RadioButton activate_radio;
    public DeviceRow (Device device) {
        Object (device: device);
    }

    public void link_to_row (DeviceRow row) {
        activate_radio.join_group (row.activate_radio);
        activate_radio.active = device.is_default;
    }

    public void set_default() {
        activate_radio.active = true;
    }

    construct {
        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.margin_start = 6;
        grid.margin_end = 6;
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        name_label = new Gtk.Label (device.display_name);
        name_label.hexpand = true;
        name_label.xalign = 0;
        img_form = new Gtk.Image ();
        img_form.icon_size = Gtk.IconSize.MENU;
        img_form.halign = Gtk.Align.END;
        activate_radio = new Gtk.RadioButton (null);
        get_style_context ().add_class ("menuitem");
        grid.add (activate_radio);
        grid.add (name_label);
        grid.add (img_form);
        add (grid);
        activate.connect (() => {activate_radio.active = true;});
        activate_radio.toggled.connect (() => {
            if (activate_radio.active) { //} && !ignore_default) {
                set_as_default ();
            }
        });

        device.bind_property ("display-name", name_label, "label");
        img_form.icon_name = device.get_nice_icon ();
        //  img_form.show_all ();

        device.removed.connect (() => destroy ());
        //  device.notify["is-default"].connect (() => {
        //      ignore_default = true;
        //      activate_radio.active = device.is_default;
        //      ignore_default = false;
        //  });

        //  device.notify["form-factor"].connect (() => {
        //      description_label.label = device.get_nice_form_factor ();
        //  });
    }
}
