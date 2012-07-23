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

public class MousePath : GLib.Object {

    private const int SAMPLING_DISTANCE = 5;

    private Vector[] path;
    private Vector[] clicks;
    
    public MousePath() {
        reset();
    }
    
    public void reset() {
        path = {};
        clicks = {};
    }
    
    public string print() {
        string result = "";
        
        for(int i=0; i<path.length;++i) {
            if (i==0) result += "%i,%i".printf((int)path[i].x, (int)path[i].y);
            else      result += "/%i,%i".printf((int)path[i].x, (int)path[i].y);
        }
        
        result += "|";
        
        for(int i=0; i<clicks.length;++i) {
            if (i==0) result += "%i,%i".printf((int)clicks[i].x, (int)clicks[i].y);
            else      result += "/%i,%i".printf((int)clicks[i].x, (int)clicks[i].y);
        }
        
        return result;
    }
    
    public void clicked(Vector mouse) {
        clicks += mouse;
    }
    
    public void moved(Vector mouse) {
        if (path.length == 0) {
            path += mouse;
            return;
        } 
        
        double dist = Vector.distance(mouse, path[path.length-1]);

        if (dist > SAMPLING_DISTANCE) { 
            path += mouse;
        }
    }
}
