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
    
    private static string menu_mode = "real_circular";
    
    private const GLib.OptionEntry[] options = {
        { "mode", 'm', 0, GLib.OptionArg.STRING, out menu_mode, 
          "Possible values: test, real_circular, real_linear, numbers, compass, directions, names_circular, names_linear" },
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
        
        Gdk.threads_enter();
        Icon.init();
        
        if (menu_mode == "test")    Test.init(); 
        else                        MenuManager.init(menu_mode);

        // connect SigHandlers
        Posix.signal(Posix.SIGINT, sig_handler);
	    Posix.signal(Posix.SIGTERM, sig_handler);
	
	    // finished loading... so run the prog!
	    message("Started happily...");
	    
	    Gtk.main();
	    
	    Gdk.threads_leave();
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
