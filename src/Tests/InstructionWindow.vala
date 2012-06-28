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

public class InstructionWindow : Gtk.Window {
    
    /////////////////////////////////////////////////////////////////////
    /// C'tor, sets up the window.
    /////////////////////////////////////////////////////////////////////
    
    private RenderedText instruction;
    
    private const int WINDOW_WIDTH = 600;
    private const int WINDOW_HEIGHT = 200;

    public InstructionWindow() {
        this.set_title("Test");
//        this.set_skip_taskbar_hint(true);
//        this.set_skip_pager_hint(true);
        this.set_keep_above(true);
//        this.set_type_hint(Gdk.WindowTypeHint.NOTIFICATION);
        this.set_decorated(false);
        this.set_resizable(false);
//        this.stick();
        this.set_focus_on_map(false);
        this.set_accept_focus(false);
        this.icon_name = "gnome-pie";
        this.set_accept_focus(false);
        this.set_size_request(WINDOW_WIDTH, WINDOW_HEIGHT);
        this.set_app_paintable(true);
        this.set_visual(this.screen.get_rgba_visual());
  
        this.draw.connect(this.draw_window);
        
        instruction = new RenderedText("", WINDOW_WIDTH, WINDOW_HEIGHT, "ubuntu 26", new Color.from_rgb(0,0,0), 1.0);
    }
    
    public void open() {
        this.show();
        this.move((this.screen.get_width()-WINDOW_WIDTH)/2, 100);
    }
    
    public void set_text(string text) {
        this.instruction = new RenderedText.with_markup(text, WINDOW_WIDTH, WINDOW_HEIGHT, "ubuntu 26", new Color.from_rgb(0,0,0), 1.0);
        this.queue_draw();
    }

    private bool draw_window(Cairo.Context ctx) { 
        ctx.set_operator (Cairo.Operator.CLEAR);
        ctx.paint();
        ctx.set_operator (Cairo.Operator.OVER);
        
        ctx.translate(WINDOW_WIDTH/2, WINDOW_HEIGHT/2);
        instruction.paint_on(ctx);
        
        return true;
    }
}
