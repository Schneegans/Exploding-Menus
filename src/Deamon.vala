/*
Copyright (c) 2011-2012 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
*/

public class Deamon : GLib.Object {

    /////////////////////////////////////////////////////////////////////
    /// The beginning of everything.
    /////////////////////////////////////////////////////////////////////

    public static int main(string[] args) {
        Logger.init();
        Gdk.threads_init();
        Gtk.init(ref args);

        // create the Deamon and run it
        var deamon = new Deamon();
        deamon.run(args);

        return 0;
    }

    /////////////////////////////////////////////////////////////////////
    /// Available command line options.
    /////////////////////////////////////////////////////////////////////

    private static string mode = "test";
    private static bool schematize = false;
    private static bool hidemouse = false;
    private static int id = 0;

    private const GLib.OptionEntry[] options = {
        { "mode", 'm', 0, GLib.OptionArg.STRING, out mode,
          "Possible values: normalize, test" },
        { "schematize", 's', 0, GLib.OptionArg.NONE, out schematize,
          "If set, the touchmenu will be schematized." },
        { "hidemouse", 'h', 0, GLib.OptionArg.NONE, out hidemouse,
          "If set, the pointer will be hidden." },
        { "ID", 'i', 0, GLib.OptionArg.INT, out id,
          "The current user's ID" },
        { null }
    };

    /////////////////////////////////////////////////////////////////////
    /// C'tor of the Deamon. It checks whether it's the firts running
    /// instance of Gnome-Pie.
    /////////////////////////////////////////////////////////////////////

    public void run(string[] args) {
        // create command line options
        var context = new GLib.OptionContext("");
        context.set_help_enabled(true);
        context.add_main_entries(options, null);
        context.add_group(Gtk.get_option_group (false));

        try {
            context.parse(ref args);
        } catch(GLib.OptionError error) {
            warning(error.message);
        }

        Icon.init();

        // connect SigHandlers
        Posix.signal(Posix.SIGINT, sig_handler);
	    Posix.signal(Posix.SIGTERM, sig_handler);

	    // finished loading... so run the prog!
	    message("Started happily...");

	    Logger.set_id(id);

        var settings  = new GLib.Settings("org.gnome.openpie.touchmenu");
        settings.set_boolean("schematize", schematize);
        settings.set_boolean("hidemouse", hidemouse);

        if (mode == "normalize") {

            var test = new NormalizeTest();
            test.on_finish.connect(() => {
                Gtk.main_quit();
            });
            test.init();
            Gtk.main();

        } else if (mode == "test") {

            var test = new Test();
            test.on_finish.connect(() => {
                Gtk.main_quit();
            });
            test.init(hidemouse);
            Gtk.main();

        } else {

            // var menu = new MenuManager();
            // menu.init(menu_type, menu_mode, width, depth);

            // menu.on_cancel.connect(() => {
            //     message("Canceled.");
            // });

            // menu.on_select.connect((item, time) => {
            //     message("Selected: %s in %u Milliseconds.", item, time);
            // });

            // Gtk.main();
        }

        settings.set_boolean("hidemouse", false);
    }

    /////////////////////////////////////////////////////////////////////
    /// Print a nifty message when the prog is killed.
    /////////////////////////////////////////////////////////////////////

    private static void sig_handler(int sig) {
        stdout.printf("\n");
        message("Caught signal (%d), bye!".printf(sig));
        Gtk.main_quit();
    }
}
