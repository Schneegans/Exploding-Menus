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

public class Vector {
    public int x = 0;
    public int y = 0;
    
    public Vector(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public double length() {
        return GLib.Math.sqrt(length_sqr());
    }
    
    public double length_sqr() {
        return x*x + y*y;
    }
}

}
