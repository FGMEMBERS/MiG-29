# Mig-29 9-12
#
# Custom Mig-29 routines for the following support:
#
#	Afterburner selection and animation
#	Fuel reporting system
#	Maintain the gyros (should eventually be moved to custom electrical system)
#	Lights over MultiPlayer
#
# Note that MP vars 0-4 used so far:
#   0	Throttle L
#   1	Throttle R
#   2	Reheat L
#   3	Reheat R
#   4	Nav lights
#
# Gary Neely aka 'Buckaroo'


#######################
# Afterburner selection and animation
#######################

# Throttle and reheat nodes to avoid repeated property look-ups:

var Mig29throttle0	= props.globals.getNode("/controls/engines/engine[0]/throttle");
var Mig29throttle1	= props.globals.getNode("/controls/engines/engine[1]/throttle");
var Mig29reheat0	= props.globals.getNode("/controls/engines/engine[0]/reheat");
var Mig29reheat1	= props.globals.getNode("/controls/engines/engine[1]/reheat");
var Mig29mpThrottle0	= props.globals.getNode("/sim/multiplay/generic/float[0]");
var Mig29mpThrottle1	= props.globals.getNode("/sim/multiplay/generic/float[1]");
var Mig29mpReheat0	= props.globals.getNode("/sim/multiplay/generic/float[2]");
var Mig29mpReheat1	= props.globals.getNode("/sim/multiplay/generic/float[3]");

# Throttle listeners:
#   Engage reheat at 90% throttle in both engines
#   Pass throttle setting over Multiplayer via MP vars (/sim/multiplay/generic)

setlistener(Mig29throttle0, func {
  if(Mig29throttle0.getValue() >= 0.90) {
    Mig29reheat0.setValue(1);
  }
  else {
    Mig29reheat0.setValue(0);
  }
  Mig29mpThrottle0.setValue(Mig29throttle0.getValue())
},1);

setlistener(Mig29throttle1, func {
  if(Mig29throttle1.getValue() >= 0.90) {
    Mig29reheat1.setValue(1);
  }
  else {
    Mig29reheat1.setValue(0);
  }
  Mig29mpThrottle1.setValue(Mig29throttle1.getValue())
},1);


# Pass reheat settings over Multiplayer:

setlistener(Mig29reheat0, func {
  Mig29mpReheat0.setValue(Mig29reheat0.getValue())
});

setlistener(Mig29reheat1, func {
  Mig29mpReheat1.setValue(Mig29reheat1.getValue())
});


#######################
# Fuel reporting system
#######################

var Mig29tanks	= {};
var Mig29selectedTank		= 0;
var Mig29selectedTankLbs	= 0;

var fuel_update = func {
  Mig29selectedTankLbs.setValue(Mig29tanks[Mig29selectedTank.getValue()].getValue());
  settimer(fuel_update,1);
}

var fuel_update_init = func {
  Mig29tanks	= {	0 : props.globals.getNode("/consumables/fuel/tank[0]/level-lbs"),
			1 : props.globals.getNode("/consumables/fuel/tank[1]/level-lbs"),
			2 : props.globals.getNode("/consumables/fuel/tank[2]/level-lbs"),
			3 : props.globals.getNode("/consumables/fuel/tank[3]/level-lbs")
		  };
  Mig29selectedTank	= props.globals.getNode("/consumables/fuel/tank-select");
  Mig29selectedTankLbs	= props.globals.getNode("/consumables/fuel/tank-select-lbs");
  settimer(fuel_update,1);
}

# Allow a second or two for the fuel system to initialize before setting up
# vars and calling the main update timer

settimer(fuel_update_init,2);


#######################
# Feed the gyros
#######################

var ai_spin = props.globals.getNode("/instrumentation/attitude-indicator/spin");
var hi_spin = props.globals.getNode("/instrumentation/heading-indicator/spin");

var feed_gyros = func {
  ai_spin.setValue(0.9);
  hi_spin.setValue(0.9);
  settimer(feed_gyros,5); 
}

settimer(feed_gyros,2);


#######################
# Lights over MP
#######################


# Handles for light control props:

var Mig29_LightNav	= props.globals.getNode("/controls/lighting/nav");

# Handles for MP props:

var Mig29_MPNav		= props.globals.getNode("/sim/multiplay/generic/float[4]");

# Pass lighting settings over Multiplayer:

setlistener(Mig29_LightNav, func {
  Mig29_MPNav.setValue(Mig29_LightNav.getValue())
});
