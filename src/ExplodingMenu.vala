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

namespace GnomePie {

public class ExplodingMenu {

    private static BindingManager bindings = null;
    
    private static ExplodingMenu menu;
    
    public static void init() {
    
        menu = new ExplodingMenu();
    
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.show();
        });
    }
    
    private InvisibleWindow window;
    
    private GLib.List<MenuItem> items;
    
    private double start_x;
    private double start_y;
    
    public ExplodingMenu() {
        window = new InvisibleWindow();
        
        items.append(new MenuItem("Neu", "filenew"));
        items.append(new MenuItem("Öffnen...", "stock_open"));
        items.append(new MenuItem("Speichern", "stock_save"));
        
        window.on_draw.connect((ctx, frame_time) => {

            double mouse_x, mouse_y;
            window.get_mouse_pos(out mouse_x, out mouse_y);
            
            int top = (int)start_y;
            
            foreach (var item in items) {
                item.draw(ctx, window, (int)start_x, top, 190, 30, (top - (int)mouse_y + 20).abs() < 17.5);
                top += 35;
            }
            
            ctx.set_line_width(5);
            ctx.set_source_rgba (0.0, 0.0, 0.0, 0.6);
            ctx.move_to(start_x, start_y);
            ctx.line_to(mouse_x, mouse_y);
            ctx.stroke();
        });
    }
    
    public void show() {
        window.open();
        window.get_mouse_pos(out start_x, out start_y);
    }
}

}
