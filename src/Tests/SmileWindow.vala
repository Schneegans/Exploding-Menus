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

public class SmileWindow : Gtk.Window {
    
    /////////////////////////////////////////////////////////////////////
    /// C'tor, sets up the window.
    /////////////////////////////////////////////////////////////////////
    
    private Image bg;
    private Image normal;
    private Image state;
    
    private AnimatedValue alpha;

    public SmileWindow() {
        this.set_title("Test");
        this.set_decorated(false);
        this.set_resizable(false);
        this.set_focus_on_map(false);
        this.set_app_paintable(true);
        this.set_position(Gtk.WindowPosition.CENTER);
        this.set_accept_focus(false);
        this.set_app_paintable(true);
        this.maximize();
        
        bg = new Image.from_file("bg.jpg");
        normal = new Image.from_file("normal.png");
        state = new Image.from_file("normal.png");
  
        this.draw.connect(this.draw_window);
        
        this.alpha = new AnimatedValue.linear(0, 0, 0);
    }
    
    public void open() {
        this.show();
        
        GLib.Timeout.add(100, () => {
            alpha.update(100);
            queue_draw();
            return visible;
        });
    }
    
    public void notify(bool happy) {
        if (happy) {
            state = new Image.from_file("happy.png");
        } else {
            state = new Image.from_file("sad.png");
        }
        
        alpha = new AnimatedValue.linear(1, 1, 0);
        
        GLib.Timeout.add(1000, ()=>{
            alpha = new AnimatedValue.linear(1, 0, 500);
            return false;
        });
    }

    private bool draw_window(Cairo.Context ctx) { 
        ctx.translate(get_window().get_width()/2, get_window().get_height()/2);
        bg.paint_on(ctx);
        normal.paint_on(ctx);
        state.paint_on(ctx, alpha.val);
        
        return true;
    }
}
