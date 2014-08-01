/**
 * Use L.Circle to draw arrows.
 * Mozart Diniz <mozart.diniz@gmail.com>
 */

/*jshint browser:true, strict:false, globalstrict:false, indent:4, white:true, smarttabs:true*/
/*global L:true*/

L.Arrow = L.Circle.extend({
	options: {
		startAngle: 0,
		stopAngle: 359.9999,
		pointAngle: 180
	},

	// make sure 0 degrees is up (North) and convert to radians.
	startAngle: function () {
		return (this.options.startAngle) * L.LatLng.DEG_TO_RAD;
	},
	
	stopAngle: function () {
		return (this.options.stopAngle) * L.LatLng.DEG_TO_RAD;
	},
	
    pointAngle: function () {
        return (this.options.pointAngle) * L.LatLng.DEG_TO_RAD;
    },	

	//rotate point x,y+r around x,y with angle.
	rotated: function (angle, r) {
		return this._point.add(
			L.point(Math.cos(angle), Math.sin(angle)).multiplyBy(r)
		).round();
	},
	
	getPathString: function () {
		var center = this._point,
		    r = this._radius;

		var start = this.rotated(this.startAngle(), r),
			end = this.rotated(this.stopAngle(), r),
			point = this.rotated(this.pointAngle(), r);

		if (this._checkIfEmpty()) {
			return '';
		}

		if (L.Browser.svg) {
            
            //move to point
            var ret = "M" + point.x + "," + point.y;
            
            //lineTo start point
            ret += "L " + start.x + "," + start.y;
            
            //lineTo center
            ret += "L " + center.x + "," + center.y;
            
            //lineTo end point
            ret += "L " + end.x + "," + end.y;                      

			return ret;
		} 
	},
	setStartAngle: function (angle) {
		this.options.startAngle = angle;
		return this.redraw();
	},
	setStopAngle: function (angle) {
		this.options.stopAngle = angle;
		return this.redraw();
	},
	setPointAngle: function(angle) {
        this.options.pointAngle = angle;
        return this.redraw();	    
	},
	setDirection: function (direction, degrees) {
	    
		if (degrees === undefined) {
			degrees = 10;
		}
		
		degrees = degrees * -1;
		
		this.options.startAngle = direction - (degrees / 2);
		this.options.stopAngle  = direction + (degrees / 2);
		this.options.pointAngle = direction + 180;

		return this.redraw();
	}
});

L.arrow = function (latlng, radius, options) {
    return new L.Arrow(latlng, radius, options);
};