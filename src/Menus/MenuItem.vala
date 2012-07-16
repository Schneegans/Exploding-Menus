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

public class MenuItem {
    public string name;
    public string icon;
    
    public Gee.ArrayList<MenuItem> children;
    
    public MenuItem(string name, string icon) {
        this.name = name;
        this.icon = icon;
        
        this.children = new Gee.ArrayList<MenuItem>();
    }
    
    public void add_child(MenuItem item) {
        children.add(item);
    }
    
    public string get_valid_entry(bool root = true) {
        if (root) {
            if (children.size > 0) {
                int index = GLib.Random.int_range(0, children.size);
                return children[index].get_valid_entry(false);
            }
            return "";
        }
       
        if (children.size > 0) {
            int index = GLib.Random.int_range(0, children.size);
            return name + "|" + children[index].get_valid_entry(false);
        }
        return name;
        
    }
}
