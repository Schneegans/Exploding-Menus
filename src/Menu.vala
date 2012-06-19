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

    public const int LABEL_HEIGHT = 35;
    
    public const int ACTIVE_ITEM_RADIUS = 35;
    
    public const int SELECTABLE_PIE_RADIUS = 55;
    public const int SELECTABLE_ITEM_RADIUS = 13;
    public const int SELECTABLE_ITEM_RADIUS_SMALL = 10;
    
    public const int PREVIEW_PIE_RADIUS = 14;
    public const int PREVIEW_ITEM_RADIUS = 4;
    
    public const int TRAIL_ITEM_RADIUS = 30;
    public const int TRAIL_PREVIEW_PIE_RADIUS = 39;
    public const int TRAIL_PREVIEW_ITEM_RADIUS = 7;

    public const int SLICE_HINT_RADIUS = 300;
    public const double SLICE_HINT_GAP = 0.0;
    public const double ANIMATION_TIME = 0.2;
    public const double FADE_OUT_TIME = 0.5;

    private static BindingManager bindings = null;
    private static Menu menu;
    
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
    
    private Vector center;
    private bool first_release;
    
    public Menu() {
        window = new InvisibleWindow();
        center = new Vector(0, 0);
        
        setup_menu();
        
        window.on_draw.connect((ctx, frame_time) => {
            root.draw(ctx, window, MenuItem.Direction.S, false, frame_time);
        });
        
        window.on_press.connect((button) => {
            first_release = false;
        });
        
        window.on_release.connect((button) => {
            if (!first_release) {
                if (button == 3 || !root.activate(window.get_mouse_pos())) {
                    
                    var activated = root.got_selected();
                    
                    root.close(activated);
                    
                    if (activated) {
                        GLib.Timeout.add((uint)((FADE_OUT_TIME+ANIMATION_TIME)*1000), () => {
                            window.hide();
                            return false;
                        });
                    } else {
                        GLib.Timeout.add((uint)((ANIMATION_TIME)*1000), () => {
                            window.hide();
                            return false;
                        });
                    }
                }
                root.update_position(center, MenuItem.Direction.S, ANIMATION_TIME);
            }
        });
        
        window.on_scroll.connect((up) => {
           
        });
    }
    
    public void show() {
        setup_menu();
        
        first_release = true;
        
        window.open();
        center = window.get_mouse_pos();
        root.set_state(MenuItem.State.ACTIVE);
        root.update_position(center, MenuItem.Direction.S, 0.0);
    }
    
    private void setup_menu() {
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
            
                var tmp2 = new MenuItem("Etwas anderes...", "stock_save");
                tmp2.add_child(new MenuItem("Bild", "gimp"));
                tmp2.add_child(new MenuItem("JPEG", "inkscape"));
                tmp2.add_child(new MenuItem("3D-Date", "blender"));
            
            tmp.add_child(tmp2);
            
        root.add_child(tmp);
        
            tmp = new MenuItem("Öffnen mit...", "stock_open");
            tmp.add_child(new MenuItem("Gimp", "gimp"));
            tmp.add_child(new MenuItem("Inkscape", "inkscape"));
            tmp.add_child(new MenuItem("Blender", "blender"));
        root.add_child(tmp);
    }
}

}
