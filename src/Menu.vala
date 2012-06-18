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

public class Menu {

    public const int ITEM_HEIGHT = 30;
    public const int ITEM_RADIUS = 50;
    public const int ACTIVE_RADIUS = 30;
    
    public const int CIRCLE_PREVIEW_RADIUS = 2;
    public const int CIRCLE_NORMAL_SUB_RADIUS = 8;
    public const int CIRCLE_NORMAL_RADIUS = 10;
    public const int CIRCLE_CENTER_RADIUS = 40;
    
    public const int SLICE_HINT_RADIUS = 250;
    public const double SLICE_HINT_GAP = 0.0;
    public const double ANIMATION_TIME = 0.2;

    private static BindingManager bindings = null;
    private static Menu menu;
    
    private Vector start = null;
    
    public static void init() {
    
        menu = new Menu();
    
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.show();
        });
    }
    
    private InvisibleWindow window;
    private MenuItem root;
    
    public Menu() {
        window = new InvisibleWindow();
        start = new Vector(0, 0);
        
        root = new MenuItem("root", "");
        
        root.add_child(new MenuItem("Rückgängig", "stock_undo"));
        root.add_child(new MenuItem("Wiederholen", "stock_redo"));
        root.add_child(new MenuItem("Ausschneiden", "stock_cut"));
        root.add_child(new MenuItem("Kopieren", "stock_copy"));
        root.add_child(new MenuItem("Einfügen", "stock_paste"));
        root.add_child(new MenuItem("Neu", "filenew"));
        
        var tmp = new MenuItem("Speichern als...", "stock_save");
            tmp.add_child(new MenuItem("Textdatei", "gimp"));
            tmp.add_child(new MenuItem("Rich-Text Datei", "inkscape"));
            tmp.add_child(new MenuItem("Tabelle", "blender"));
            tmp.add_child(new MenuItem("Webseite", "blender"));
        
        root.add_child(tmp);
        
            tmp = new MenuItem("Öffnen mit...", "stock_open");
            tmp.add_child(new MenuItem("Gimp", "gimp"));
            tmp.add_child(new MenuItem("Inkscape", "inkscape"));
            tmp.add_child(new MenuItem("Blender", "blender"));
        root.add_child(tmp);

        window.on_draw.connect((ctx, frame_time) => {
            root.draw_root(ctx, window, start, frame_time);
        });
        
        window.on_press.connect((button) => {
            
        });
        
        window.on_release.connect((button) => {
            window.hide();
        });
        
        window.on_scroll.connect((up) => {
           
        });
    }
    
    public void show() {
        window.open();
        window.get_mouse_pos(out start.x, out start.y);
    }
}

}
