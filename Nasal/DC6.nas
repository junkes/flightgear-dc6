var Vvolume = props.globals.getNode("sim/sound/view-volume",1);
var FDM="";
var counter=0;
aircraft.livery.init("Aircraft/dc6/Models/Liveries"); 

var createMessage = func {
  var window = screen.window.new(nil, nil, 10, 10);
  window.fg = [0, 1, 0, 0.8];
  window.bg = [0, 0, 0, 0.8];
  return window;
}

var message = createMessage();

#tire rotation per minute by circumference/groundspeed#
TireSpeed = {
  new : func(unit,diameter){
    m = { parents : [TireSpeed] };
    m.num=unit;
    m.circumference = diameter*math.pi;
    m.tire = props.globals.initNode("gear/gear["~m.num~"]/tire-rpm", 0.0, "DOUBLE");
    m.wow = props.globals.getNode("gear/gear["~m.num~"]/wow");
    m.geardown = props.globals.getNode("gear/gear["~m.num~"]/position-norm");
    m.rpm = 0;
    return m;
  },
  #### calculate and write rpm ###########
  get_rotation: func (fdm1) {
    var speed=0;
    if (me.geardown.getValue()==0) {
      me.rpm=0;
      return;
    }
    if (fdm1=="yasim") { 
      speed = getprop("gear/gear["~me.num~"]/rollspeed-ms") or 0;
      speed=speed*60;
    } elsif (fdm1=="jsb") {
      speed =getprop("fdm/jsbsim/gear/unit["~me.num~"]/wheel-speed-fps") or 0;
      speed=speed*18.288;
    }
    var wow = me.wow.getBoolValue();
    if(wow){
      me.rpm = speed / me.circumference;
    }else{
      if(me.rpm > 0) me.rpm=me.rpm*0.95;
    }
    me.tire.setValue(me.rpm);
  },
};


var tire=[];
append(tire,TireSpeed.new(0,1.055));
append(tire,TireSpeed.new(1,1.151));
append(tire,TireSpeed.new(2,1.151));

setlistener("/sim/signals/fdm-initialized", func {
  Vvolume.setDoubleValue(-0.3);
  FDM=getprop("sim/flight-model");
  update();
});

setlistener("/sim/signals/reinit", func(rset) {
  if(rset.getValue()==0){
  }
},1,0);

setlistener("/sim/current-view/internal", func(vw){
  if(vw.getBoolValue()){
    Vvolume.setDoubleValue(0.1);
  }else{
    Vvolume.setDoubleValue(1);
  }
},1,0);

setlistener("/sim/model/autostart", func(idle){
  if(idle.getBoolValue()){
    Startup();
  }else{
    Shutdown();
  }
},0,0);


var Startup = func{ ################################### edited by Julio Junkes
  setprop("controls/electric/engine[0]/generator",1);
  setprop("controls/electric/engine[1]/generator",1);
  setprop("controls/electric/engine[2]/generator",1);
  setprop("controls/electric/engine[3]/generator",1);
  setprop("controls/electric/battery-switch",1);
  setprop("controls/lighting/instrument-lights",1);
  setprop("controls/lighting/nav-lights",1);
  setprop("controls/lighting/beacon",1);
  setprop("controls/engines/engine[0]/magnetos",3);
  setprop("controls/engines/engine[0]/fuel-pump",1);
  setprop("controls/engines/engine[0]/propeller-pitch",1);
  setprop("controls/engines/engine[0]/mixture",1);
  # setprop("engines/engine[0]/rpm",1000);
  setprop("controls/engines/engine[1]/magnetos",3);
  setprop("controls/engines/engine[1]/fuel-pump",1);
  setprop("controls/engines/engine[1]/propeller-pitch",1);
  setprop("controls/engines/engine[1]/mixture",1);
  # setprop("engines/engine[1]/rpm",1000);
  setprop("controls/engines/engine[2]/magnetos",3);
  setprop("controls/engines/engine[2]/fuel-pump",1);
  setprop("controls/engines/engine[2]/propeller-pitch",1);
  setprop("controls/engines/engine[2]/mixture",1);
  # setprop("engines/engine[2]/rpm",1000);
  setprop("controls/engines/engine[3]/magnetos",3);
  setprop("controls/engines/engine[3]/fuel-pump",1);
  setprop("controls/engines/engine[3]/propeller-pitch",1);
  setprop("controls/engines/engine[3]/mixture",1);
  # setprop("engines/engine[3]/rpm",1000);
  if(FDM=="jsb"){
      setprop("fdm/jsbsim/propulsion/set-running",-1);
  }else{
   
    message.write("Starting engines, please wait");

    settimer(func(){ 
      
      setprop("controls/engines/engine[0]/starter",1);
    }, 0);
    settimer(func(){ 
      setprop("controls/engines/engine[0]/starter",0);
      message.write("Engine 1 Ok!");
      setprop("controls/engines/engine[3]/starter",1);
    }, 5);
    settimer(func(){ 
      setprop("controls/engines/engine[3]/starter",0);
      message.write("Engine 4 Ok!");
      setprop("controls/engines/engine[2]/starter",1);
    }, 10);
    settimer(func(){ 
      setprop("controls/engines/engine[2]/starter",0);
      message.write("Engine 3 Ok!");
      setprop("controls/engines/engine[1]/starter",1);
    }, 15);
    settimer(func(){
      setprop("controls/engines/engine[1]/starter",0);
      message.write("Engine 2 Ok!");
    }, 20);
  }
}

var Shutdown = func{
  setprop("controls/electric/engine[0]/generator",0);
  setprop("controls/electric/engine[1]/generator",0);
  setprop("controls/electric/engine[2]/generator",0);
  setprop("controls/electric/engine[3]/generator",0);
  setprop("controls/electric/battery-switch",0);
  setprop("controls/lighting/instrument-lights",0);
  setprop("controls/lighting/nav-lights",0);
  setprop("controls/lighting/beacon",0);
  setprop("controls/engines/engine[0]/magnetos",0);
  setprop("controls/engines/engine[0]/fuel-pump",0);
  setprop("controls/engines/engine[1]/magnetos",0);
  setprop("controls/engines/engine[1]/fuel-pump",0);
  setprop("controls/engines/engine[2]/magnetos",0);
  setprop("controls/engines/engine[2]/fuel-pump",0);
  setprop("controls/engines/engine[3]/magnetos",0);
  setprop("controls/engines/engine[3]/fuel-pump",0);
  message.write("Shutdown Ok!");
}

var update = func {
  updateBMEP();
  tire[counter].get_rotation(FDM);
  counter+=1;
  if(counter>2)counter=0;

  var agl=getprop("position/gear-agl-ft") or 0;
  var pdeg=getprop("orientation/pitch-deg") or 0;
  var rdeg=getprop("orientation/roll-deg") or 0;

  setprop("sim/multiplay/generic/float[0]",agl);
  setprop("sim/multiplay/generic/float[1]",pdeg);
  setprop("sim/multiplay/generic/float[2]",rdeg);

  settimer(update,0);
}

var updateBMEP = func {
  var hp=0;
  var rpm=0;
  var bmep=0;
  var torque=0;
  
  for(var engine=0; engine< 4; engine+=1)
  {
    if (FDM=="jsb"){
        rpm=getprop("engines/engine["~engine~"]/rpm") or 1;
        hp=getprop("fdm/jsbsim/propulsion/engine["~engine~"]/power-hp");
        bmep=hp*285/rpm;
    } else {
        torque=getprop("engines/engine["~engine~"]/torque-ftlb") or 0;
        bmep = 150.8 * torque / 2804;
    }
      setprop("engines/engine["~engine~"]/bmep", bmep);
  }
}


#########################  new from Lake of Constance Hangar #########################
var switch5SoundToggle = func{
  var switchSound = props.globals.getNode("/sim/sound/switch5",1);
  if(switchSound.getBoolValue()){
    switchSound.setBoolValue(0);
  }else{
    switchSound.setBoolValue(1);
  }
}

var switch6SoundToggle = func{
  var switchSound = props.globals.getNode("/sim/sound/switch6",1);
  if(switchSound.getBoolValue()){
    switchSound.setBoolValue(0);
  }else{
    switchSound.setBoolValue(1);
  }
}


############################ Adicionado por Julio Junkes ##############################

# diminui automaticamente a mistura para 0.6 em cruzeiro
# setlistener("autopilot/internal/vert-speed-fpm", func (fpm) {
#     var kt = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
#     if (kt > 180 and fpm.getValue() < 100 and fpm.getValue() > -100) {
#         if (getprop("controls/engines/engine[0]/mixture") != 0.6) {
#             setprop("controls/engines/engine[0]/mixture", 0.6);
#             setprop("controls/engines/engine[1]/mixture", 0.6);
#             setprop("controls/engines/engine[2]/mixture", 0.6);
#             setprop("controls/engines/engine[3]/mixture", 0.6);
#             message.write("Setting mixture: " ~ getprop("controls/engines/engine[0]/mixture"));
#         }
#     } else {
#         if (getprop("controls/engines/engine[0]/mixture") != 1) {
#             setprop("controls/engines/engine[0]/mixture", 1);
#             setprop("controls/engines/engine[1]/mixture", 1);
#             setprop("controls/engines/engine[2]/mixture", 1);
#             setprop("controls/engines/engine[3]/mixture", 1);
#             message.write("Setting mixture: " ~ getprop("controls/engines/engine[0]/mixture"));
#         }
#     }
# });

# Toogle [ altitude hold <=> vertical speed ] and speed
# setlistener("instrumentation/altimeter/indicated-altitude-ft", func (ft) {
#   if (getprop("autopilot/switches/ap") and getprop("autopilot/switches/gps") and getprop("instrumentation/airspeed-indicator/indicated-speed-kt") > 110) {
#     var target_ft = getprop("autopilot/settings/target-altitude-ft");
#     var mixture = 1;
#     if (getprop("autopilot/switches/alt") and ft.getValue() > (target_ft + 300)) {
#       setprop("autopilot/settings/target-speed-kt", 150);
#       setprop("autopilot/settings/vertical-speed-fpm", -2000);
#       setprop("autopilot/switches/pitch", 1);
#       message.write("Setting target speed: 150 kt");
#       message.write("Setting flaps: 50%");
#       setprop("controls/flight/flaps", 0.5);
#       message.write("Setting vertical speed: -2000 fpm");
#     }

#     if (getprop("autopilot/switches/alt") and ft.getValue() < (target_ft - 300)) {
#       setprop("autopilot/settings/target-speed-kt", 150);
#       setprop("autopilot/settings/vertical-speed-fpm", 1000);
#       setprop("autopilot/switches/pitch", 1);
#       message.write("Setting target speed: 150 kt");
#       message.write("Setting flaps: 50%");
#       setprop("controls/flight/flaps", 0.5);
#       message.write("Setting vertical speed: 1000 fpm");
#     }

#     if (getprop("autopilot/switches/pitch") and ft.getValue() > (target_ft - 300) and ft.getValue() < (target_ft + 300)) {
#       setprop("autopilot/switches/alt", 'true');
#       setprop("controls/flight/flaps", 0);
#       mixture = 0.6;
#       var speed = 220;
#       if ((target_ft - getprop("autopilot/route-manager/destination/field-elevation-ft")) <= 2500 ) {
#         setprop("controls/flight/flaps", 1);
#         speed = 115;
#         mixture = 1;
#       }
#       setprop("controls/engines/engine[0]/mixture", mixture);
#       setprop("controls/engines/engine[1]/mixture", mixture);
#       setprop("controls/engines/engine[2]/mixture", mixture);
#       setprop("controls/engines/engine[3]/mixture", mixture);
#       setprop("autopilot/settings/target-speed-kt", speed);
#       message.write("Setting target speed: " ~ speed ~ " kt");
#       message.write("Setting altitude hold: " ~ target_ft ~ "ft");
#       message.write("Setting mixture: " ~ mixture);
#     }
#   }
# });

