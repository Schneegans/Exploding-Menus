/* 
Copyright (c) 2011 by Simon Schneegans

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

using GLib.Math;

namespace GnomePie {

/////////////////////////////////////////////////////////////////////////    
///  An invisible window. Used to draw Pies onto.
/////////////////////////////////////////////////////////////////////////

public class InvisibleWindow : Gtk.Window {

    public signal void on_draw(Cairo.Context ctx, double frame_time);
    public signal void on_release(uint button);
    public signal void on_press(uint button);
    public signal void on_scroll(bool up);
    
    /////////////////////////////////////////////////////////////////////
    /// A timer used for calculating the frame time.
    /////////////////////////////////////////////////////////////////////
    
    private GLib.Timer timer;
    
    /////////////////////////////////////////////////////////////////////
    /// C'tor, sets up the window.
    /////////////////////////////////////////////////////////////////////

    public InvisibleWindow() {
        this.set_title("Gnome-Pie");
        this.set_skip_taskbar_hint(true);
        this.set_skip_pager_hint(true);
        this.set_keep_above(true);
        this.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU);
        this.set_decorated(false);
        this.set_resizable(false);
        this.icon_name = "gnome-pie";
        this.set_accept_focus(false);
        this.maximize();
        
        this.set_visual(this.screen.get_rgba_visual());
        
        // set up event filter
        this.add_events(Gdk.EventMask.BUTTON_RELEASE_MASK |
                        Gdk.EventMask.BUTTON_PRESS_MASK |
                        Gdk.EventMask.SCROLL_MASK |
                        Gdk.EventMask.POINTER_MOTION_MASK);

        // activate on left click
        this.button_release_event.connect ((e) => {
            on_release(e.button);
            return true;
        });
        
        this.scroll_event.connect ((e) => {
            if (e.direction == Gdk.ScrollDirection.UP || e.direction == Gdk.ScrollDirection.DOWN)
                on_scroll(e.direction == Gdk.ScrollDirection.UP);
            return true;
        });
        
         // cancel on right click
        this.button_press_event.connect ((e) => {
            on_press(e.button);
            return true;
        });
        
        // notify the renderer of mouse move events
        this.motion_notify_event.connect((e) => {

            return true;
        });
        
        this.show.connect_after(() => {
            Gtk.grab_add(this);
            FocusGrabber.grab(this.get_window(), true, true, false);
        });

        // draw the pie on expose
        this.draw.connect(this.draw_window);
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Opens the window. load_pie should have been called before.
    /////////////////////////////////////////////////////////////////////
    
    public void open() {
        // capture the input focus
        this.show();

        // start the timer
        this.timer = new GLib.Timer();
        this.timer.start();
        this.queue_draw();
        
        // the main draw loop
        GLib.Timeout.add((uint)(1000.0/60.0), () => {  
            if (!this.visible)
                return false;
                              
            this.queue_draw();
            return this.visible;
        }); 
    }
    
    public void get_mouse_pos(out int mouse_x, out int mouse_y) {
        // get the mouse position
        this.get_pointer(out mouse_x, out mouse_y);
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Gets the center position of the window.
    /////////////////////////////////////////////////////////////////////
    
    public void get_center_pos(out int out_x, out int out_y) {
        int x=0, y=0, width=0, height=0;
        this.get_position(out x, out y);
        this.get_size(out width, out height);
        
        out_x = x + width/2;
        out_y = y + height/2;
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Draw the Pie.
    /////////////////////////////////////////////////////////////////////

    private bool draw_window(Cairo.Context ctx) { 
        // paint the background image if there is no compositing
        ctx.set_operator (Cairo.Operator.CLEAR);
        ctx.paint();
        ctx.set_operator (Cairo.Operator.OVER);
        
        // store the frame time
        double frame_time = this.timer.elapsed();
        this.timer.reset();
        
        this.on_draw(ctx, frame_time);
        
        return true;
    }
    
    public void close() {
        Gtk.grab_remove(this);
        FocusGrabber.ungrab();
        this.hide();
    }
}

}
