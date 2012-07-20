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
    
    private Gtk.Label instruction;
    
    private const int WINDOW_WIDTH = 600;
    private const int WINDOW_HEIGHT = 200;

    public InstructionWindow() {
        this.set_title("Test");
        this.set_keep_above(true);
        this.set_decorated(false);
        this.set_focus_on_map(false);
        this.set_accept_focus(false);
        this.set_accept_focus(false);
        this.set_size_request(WINDOW_WIDTH, WINDOW_HEIGHT);
        this.set_app_paintable(true);
        this.set_visual(this.screen.get_rgba_visual());
        
        instruction = new Gtk.Label("");
        instruction.wrap_mode = Pango.WrapMode.WORD;
        instruction.wrap = true;
        instruction.width_request = WINDOW_WIDTH;
        instruction.justify = Gtk.Justification.FILL;
        this.add(instruction);
        instruction.show();
  
        this.draw.connect(this.draw_window);
    }
    
    public void open() {
        this.show();
        this.move((this.screen.get_width()-WINDOW_WIDTH)/2, 100);
    }
    
    public void set_text(string text) {
        this.instruction.set_markup("<span size='20000' color='black'>" + text + "</span>");
    }

    private bool draw_window(Cairo.Context ctx) { 
        ctx.set_operator (Cairo.Operator.CLEAR);
        ctx.paint();
        ctx.set_operator (Cairo.Operator.OVER);
        
        instruction.draw(ctx);
        
        return true;
    }
}
