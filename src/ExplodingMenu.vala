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
        bindings.bind(new Trigger.from_string("button2"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.show();
        });
    }
    
    
    
    private InvisibleWindow window;
    
    public ExplodingMenu() {
        window = new InvisibleWindow();
    
    }
    
    public void show() {
        window.open();
    }
    
    
}

}
