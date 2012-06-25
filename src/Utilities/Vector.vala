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

public class Vector : GLib.Object {
    public double x = 0;
    public double y = 0;
    
    public Vector(double x, double y) {
        this.x = x;
        this.y = y;
    }
    
    public double length() {
        return GLib.Math.sqrt(length_sqr());
    }
    
    public double length_sqr() {
        return x*x + y*y;
    }
    
    public Vector copy() {
        return new Vector(x, y);
    }
    
    public void normalize() {
        double length = length();
        
        if (length > 0) {
            x /= length;
            y /= length;
        }
    }
    
    public static Vector direction(Vector from, Vector to) {
        return new Vector(to.x - from.x, to.y - from.y);
    }
    
    public static double distance(Vector from, Vector to) {
        return direction(from, to).length();
    }
    
    public static double angle(Vector a, Vector b) {
        return GLib.Math.acos(dot(a, b)/(a.length() * b.length()));
    }
    
    public static double dot(Vector a, Vector b) {
        return a.x*b.x + a.y*b.y;
    }
}
