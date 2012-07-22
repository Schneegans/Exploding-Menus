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

/////////////////////////////////////////////////////////////////////////  
/// A static class which beautifies the messages of the default logger.
/// Some of this code is inspired by plank's written by Robert Dyer. 
/// Thanks a lot for this project! 
/////////////////////////////////////////////////////////////////////////

public class Logger {

    /////////////////////////////////////////////////////////////////////
    /// If these are set to false, the according messages are not shown
    /////////////////////////////////////////////////////////////////////
    
    private static const bool display_debug = true; 
    private static const bool display_warning = true; 
    private static const bool display_error = true; 
    private static const bool display_message = true; 
    
    /////////////////////////////////////////////////////////////////////
    /// If true, a time stamp is shown in each message.
    /////////////////////////////////////////////////////////////////////
    
    private static const bool display_time = false; 
    
    /////////////////////////////////////////////////////////////////////
    /// If true, the origin of the message is shown. In form file:line
    /////////////////////////////////////////////////////////////////////
    
    private static const bool display_file = false; 
    
    /////////////////////////////////////////////////////////////////////
    /// A regex, used to format the standard message.
    /////////////////////////////////////////////////////////////////////
    
    private static Regex regex = null;
    
    /////////////////////////////////////////////////////////////////////
    /// Possible terminal colors.
    /////////////////////////////////////////////////////////////////////
    
    private enum Color {
        BLACK,
        RED,
        GREEN,
        YELLOW,
        BLUE,
        PURPLE,
        TURQUOISE,
        WHITE
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Creates the regex and binds the handler.
    /////////////////////////////////////////////////////////////////////
    
    public static void init() {
        try {
			regex = new Regex("""(.*)\.vala(:\d+): (.*)""");
		} catch {}
		
        GLib.Log.set_handler(null, GLib.LogLevelFlags.LEVEL_MASK, log_func);
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Appends a line to the log file
    /////////////////////////////////////////////////////////////////////
    
    public static void write(string line) {
        var log = GLib.FileStream.open("training.log", "a");
            
        if (log != null) {
            log.puts(line + "\n");
        }
    }
    
    public static string simplify(string s) {
        var result = s;
        result = result.replace(" ", "_");
        result = result.replace("|", "_");
        result = result.down();
        return result;
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Displays a message.
    /////////////////////////////////////////////////////////////////////
    
    private static void message(string message) {
        if (display_message) {
            stdout.printf(set_color(Color.GREEN, false) + "[" + (display_time ? get_time() + " " : "") + "MESSAGE]" + message);
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Displays a Debug message.
    /////////////////////////////////////////////////////////////////////
    
    private static void debug(string message) {
        if (display_debug) {
            stdout.printf(set_color(Color.BLUE, false) + "[" + (display_time ? get_time() + " " : "") + " DEBUG ]" + message);
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Displays a Warning message.
    /////////////////////////////////////////////////////////////////////
    
    private static void warning(string message) {
        if (display_warning) {
            stdout.printf(set_color(Color.YELLOW, false) + "[" + (display_time ? get_time() + " " : "") + "WARNING]" + message);
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Displays a Error message.
    /////////////////////////////////////////////////////////////////////
    
    private static void error(string message) {
        if (display_error) {
            stdout.printf(set_color(Color.RED, false) + "[" + (display_time ? get_time() + " " : "") + " ERROR ]" + message);
        }
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Helper method which resets the terminal color.
    /////////////////////////////////////////////////////////////////////
    
    private static string reset_color() {
		return "\x001b[0m";
	}
	
	/////////////////////////////////////////////////////////////////////
	/// Helper method which sets the terminal color.
	/////////////////////////////////////////////////////////////////////
	
	private static string set_color(Color color, bool bold) {
	    if (bold) return "\x001b[1;%dm".printf((int)color + 30);
	    else      return "\x001b[0;%dm".printf((int)color + 30);
	}
	
	/////////////////////////////////////////////////////////////////////
	/// Returns the current time in hh:mm:ss:mmmmmm
	/////////////////////////////////////////////////////////////////////
	
	public static string get_time() {
        var now = new DateTime.now_local();
	    return "%.4d:%.2d:%.2d:%.2d:%.2d:%.2d:%.6d".printf(now.get_year(), now.get_month(), now.get_day_of_month(), now.get_hour(), now.get_minute(), now.get_second(), now.get_microsecond());
	}
	
	/////////////////////////////////////////////////////////////////////
    /// Helper method to format the message.
    /////////////////////////////////////////////////////////////////////
	
	private static string create_message(string message) {
	    if (display_file && regex != null && regex.match(message)) {
			var parts = regex.split(message);
			return " [%s%s]%s %s\n".printf(parts[1], parts[2], reset_color(), parts[3]);
		} else if (regex != null && regex.match(message)) {
		    var parts = regex.split(message);
			return "%s %s\n".printf(reset_color(), parts[3]);
		} else {
		    return reset_color() + " " + message + "\n";
		}
	}
	
	/////////////////////////////////////////////////////////////////////
	/// The handler function.
	/////////////////////////////////////////////////////////////////////
	
	private static void log_func(string? d, LogLevelFlags flags, string text) {
		switch (flags) {
		    case LogLevelFlags.LEVEL_ERROR:
		    case LogLevelFlags.LEVEL_CRITICAL:
			    error(create_message(text));
			    break;
		    case LogLevelFlags.LEVEL_INFO:
		    case LogLevelFlags.LEVEL_MESSAGE:
			    message(create_message(text));
			    break;
		    case LogLevelFlags.LEVEL_DEBUG:
			    debug(create_message(text));
			    break;
		    case LogLevelFlags.LEVEL_WARNING:
		    default:
			    warning(create_message(text));
			    break;
		}
	}
}
