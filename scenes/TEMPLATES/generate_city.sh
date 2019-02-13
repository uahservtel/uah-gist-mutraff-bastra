#!/bin/bash

# ----------------------------------------------------------------
function default_params() {

  # Group: traffic
  # Descr: Traffic type
  # Default: randomtraffic, fulltraffic, dirtraffic
  export __TRAFFIC_TYPE=randomtraffic

  # Group: global
  # Descr: apply Bastra or not
  # Default: Bastra, noBastra
  export __USE_BASTRA=noBastra

  # Group: global
  # Descr: commands file to use
  # Default: nomaps, directedPenalty, reference
  #	rand05x1_timeALL, random05x2_timeALL, random05x4_timeALL, random05x8_timeALL,
  #	rand05x2_time2000, random05x4_time2000
  #	rand2x2_timeALL, random2x4_timeALL, rand2x2_time2000, random2x4_time2000
  export __MAP_USAGE="adhocmaps"

  # Group: global
  # Descr: commands time to start application
  # Default: 0
  export __MAP_TIME_INI="0"

  # Group: global
  # Descr: commands time to end application
  # Default: 10000
  export __MAP_TIME_END="10000"

  # Group: network
  # Descr: network name
  # Default: grid16, radial16, grid32, radial32, etc
  export __NET_NAME=cityname

  # Group: network
  # Descr: length of edges in meters
  # Default: 50
  export __ROADLENGTH="50"

  # Group: network
  # Descr: type of network to generate
  # Default: grid, radial, city
  export __NET_TYPE="city"

  # Group: network
  # Descr: number of lanes per edge
  # Default: 1
  export __LANES="1"

  # Group: network
  # Descr: max speed in the edges
  # Default: 13.9
  export __MAX_SPEED="13.9"

  # Group: time
  # Descr: simulation starting time
  # Default: 0
  export __SIMUL_TIME_INI="0"

  # Group: time
  # Descr: simulation end time
  # Default: 4000
  export __SIMUL_TIME_END="4000"

  # Group: traffic
  # Descr: aVEhicle 's routing algorithm
  # Default: '', allowed values:'dijstra', 'astar', 'ch', 'chwrapper'
  export __ROUTING_ALGORITHM=""

  # Group: traffic
  # Descr: ability and time to teleport a vehicle.
  # Default: '-1', allowed values:'60', '30', sumo's default '300'
  export __TELEPORTING="60"

  # Group: traffic
  # Descr: baseline traffic: random trips to be generated
  # Default: 3000
  export __TRAFFIC_BASELINE="3000"

  # Group: traffic
  # Descr: directional traffic, peaks, traffic to be generated at certain edges
  # Default: 200
  export __TRAFFIC_BRANCH="0"

  # Group: traffic
  # Descr: Use pre-defined traffic DEMAND distribution (typed-trips). Is a file name with the traffic distribution to use. WARNING: it is bounded to a concrete network file.
  # Default: ""
  # Examples: "../DEMANDS/alcalahenares/alcalahenares.XXL.typed-routes.xml", "../DEMANDS/grid16/M.typed-routes.xml", "../DEMANDS/radial16/XS.typed-routes.xml"
  export __PREDEFINED_TRAFFIC_DEMAND=""

  # Group: traffic
  # Descr: Set generated typed demand as pre-defined distribution (typed-trips). Is a file name with the traffic distribution to use. WARNING: it is bounded to a concrete network file.
  # Default: ""
  # Examples: "../DEMANDS/alcalahenares/alcalahenares.XXL.typed-routes.xml", "../DEMANDS/grid16/M.typed-routes.xml", "../DEMANDS/radial16/XS.typed-routes.xml"
  export __SET_AS_PREDEFINED_TRAFFIC_DEMAND=""

  # Group: network-grid
  # Descr: square size of the grid
  # Default: 16
  export __GRID_SIZE="16"

  # Group: network-spider
  # Descr: number of radial arms starting from the central point
  # Default: 16
  export __SPIDER_ARMS="16"

  # Group: network-spider
  # Descr: number of rings for the network
  # Default: 16
  export __SPIDER_CIRCLES="16"

  # Group: mutraff
  # Descr: mutraff algorithms is active?
  # Default: true
  export __BASTRA_USE_BALANCE="false"

  # Group: mutraff
  # Descr: percent of users using Bastra application to route their vehicles
  # Default:  0.5
  export __BASTRA_LOGIT="0"

  # Group: mutraff-Foresight
  # Descr: oresight, following edges to consider in the planned route
  # Default: 1
  export __BASTRA_FORESIGHT_STEPS="0"

  # Group: mutraff-Foresight
  # Descr: foresight, number of alternative edges to consider (in a 4 sides crossing, use the 3 resting edges)
  # Default: 3
  export __BASTRA_FORESIGHT_TRIES="0"

  # Group: mutraff-Foresight
  # Descr: foresight, number of halted vehicles to decide jam occurence
  # Default: 3
  export __BASTRA_FORESIGHT_HALTING="0"

  # Group: mutraff-Foresight
  # Descr: weight multiplier for function cost: if congestion is detected increment traveltime x this factor
  # Default: 50
  export __BASTRA_FORESIGHT_PENALTY="1"

  # Group: sumo
  # Descr: SUMO's listening PORT
  # Default: 
  # export __SUMO_PORT="2081"
  export __SUMO_PORT="2081"

  # Group: sumo
  # Descr: Enable SUMO GUI
  # Default: 
  # export __SUMO_GUI="false"
  export __SUMO_GUI="false"

  # Group: global
  # Descr: name of simulation
  # Default: 
  # export __PREFIX="canogrid_noBastra_adhocmaps_randomtraffic"
  export __PREFIX="${__NET_NAME}_${__USE_BASTRA}_${__MAP_USAGE}_${__TRAFFIC_TYPE}"
}

# ----------------------------------------------------------------
function load_config() {
  default_params
  [ $# -eq 1 ] || return
  CONF_FILE=$1
  if [ -f $CONF_FILE ]
  then
  	echo "Configuration file $CONF_FILE loaded"
	. $CONF_FILE
  else
	echo "Configuration file $CONF_FILE not found"
	exit
  fi
}

echo ${PARAM_A}

# ----------------------------------------------------------------
load_config $*

# ----------------------------------------------------------------
cat <<EOF > /tmp/filter.sed
s/__PREFIX__/${__PREFIX}/g
s/__MAP_TIME_INI__/${__MAP_TIME_INI}/g
s/__MAP_TIME_END__/${__MAP_TIME_END}/g
s/__ROADLENGTH__/${__ROADLENGTH}/g
s/__NET_TYPE__/${__NET_TYPE}/g
s/__LANES__/${__LANES}/g
s/__MAX_SPEED__/${__MAX_SPEED}/g
s/__SIMUL_TIME_INI__/${__SIMUL_TIME_INI}/g
s/__SIMUL_TIME_END__/${__SIMUL_TIME_END}/g
s/__ROUTING_ALGORITHM__/${__ROUTING_ALGORITHM}/g
s/__TELEPORTING__/${__TELEPORTING}/g
s/__TRAFFIC_BASELINE__/${__TRAFFIC_BASELINE}/g
s/__TRAFFIC_BRANCH__/${__TRAFFIC_BRANCH}/g
s/__GRID_SIZE__/${__GRID_SIZE}/g
s/__SPIDER_ARMS__/${__SPIDER_ARMS}/g
s/__SPIDER_CIRCLES__/${__SPIDER_CIRCLES}/g
s/__BASTRA_USE_BALANCE__/${__BASTRA_USE_BALANCE}/g
s/__BASTRA_LOGIT__/${__BASTRA_LOGIT}/g
s/__BASTRA_FORESIGHT_STEPS__/${__BASTRA_FORESIGHT_STEPS}/g
s/__BASTRA_FORESIGHT_TRIES__/${__BASTRA_FORESIGHT_TRIES}/g
s/__BASTRA_FORESIGHT_HALTING__/${__BASTRA_FORESIGHT_HALTING}/g
s/__BASTRA_FORESIGHT_PENALTY__/${__BASTRA_FORESIGHT_PENALTY}/g
s/__SUMO_PORT__/${__SUMO_PORT}/g
s/__SUMO_GUI__/${__SUMO_GUI}/g
s/length=".*" /length="${__ROADLENGTH}" /g
EOF

# ----------------------------------------------------------------
__OUT_BASTRA_FILE="bastra.conf.xml"
__OUT_DUA_FILE="${__PREFIX}.duarouter.conf"
__OUT_CMDS_FILE="${__PREFIX}.commands.xml"
__OUT_MAPS_FILE="${__PREFIX}.maps.xml"
__OUT_NET_FILE="${__PREFIX}.net.${__NET_TYPE}.conf"
__OUT_OD_FILE="${__PREFIX}.od.conf"
__OUT_ODMAT_FILE="${__PREFIX}.odmat.xml"
__OUT_SUMO_FILE="${__PREFIX}.sumo.conf"
__OUT_NETGEN_FILE="${__PREFIX}.net.xml"
__OUT_TAZ_FILE="${__PREFIX}.${__NET_NAME}.taz.xml"
__OUT_VEH_FILE="${__PREFIX}.vehicle_distrib.conf"

OUT_TMP_FILE="/tmp/tmp.net.xml"

# ----------------------------------------------------------------
function die() {
  echo "******************************************"
  echo "ERROR: $*"
  echo "******************************************"
  exit 1
}

# ----------------------------------------------------------------
echo "--- GENERATING SCENARIO: ${__PREFIX} --"

# ----------------------------------------------------------------
echo "--- Checking NETWORK FILES ---"
[ -r "cities/${__NET_NAME}/sumo/${__NET_NAME}.net.xml" ]  || die "Cannot find cities/${__NET_NAME}/sumo/${__NET_NAME}.net.xml"

# ----------------------------------------------------------------
echo "--- Checking necessary TEMPLATES ---"
[ -r "TEMPLATE.bastra.conf" ]  || die "Cannot find TEMPLATE.bastra.conf"
[ -r "TEMPLATE.duarouter.conf" ] || die "Cannot find TEMPLATE.duarouter.conf"
# [ -r "TEMPLATE.net.${__NET_TYPE}.conf" ] || die "Cannot find TEMPLATE.net.${__NET_TYPE}.conf"
[ -r "TEMPLATE.od.conf" ]      || die "Cannot find TEMPLATE.od.conf"
[ -r "TEMPLATE.odmat.${__NET_NAME}.xml" ]    || die "Cannot find TEMPLATE.odmat.${__NET_NAME}.xml"
[ -r "TEMPLATE.sumo.conf" ]    || die "Cannot find TEMPLATE.sumo.conf"
[ -r "TEMPLATE.${__NET_NAME}.taz.xml" ] || die "Cannot find TEMPLATE.${__NET_NAME}.taz.xml"

SRC_MAP="maps/TEMPLATE.${__NET_NAME}.${__MAP_USAGE}.maps.xml"
[ -d "maps" ]           || die "Cannot find maps dir"
[ -r "${SRC_MAP}" ]     || die "Cannot find ${SRC_MAP}"

SRC_MAP_DIR="maps/${__NET_NAME}.maps"
[ -d "${SRC_MAP_DIR}" ] || die "Cannot find ${SRC_MAP_DIR} dir"

[ -d "commands" ]                  || die "Cannot find commands dir"
[ -r "commands/TEMPLATE.commands.${__MAP_USAGE}.xml" ] || die "Cannot find commands/TEMPLATE.commands.${__MAP_USAGE}.xml"

echo "Found all the necessary TEMPLATE FILES"

# ----------------------------------------------------------------
OUT_DIR="../${__PREFIX}"
mkdir $OUT_DIR 2>&1

# ----------------------------------------------------------------
(
cat <<EOF
.............................................
    BASTRA SIMULATION TOOL
    ESCENARIO: ${__PREFIX}

    alvaro.paricio@uah.es
(This file has been generated automatically by generate_cities.sh)
.............................................
EOF
env | sort | grep __
) > $OUT_DIR/SCENARIO_DESCRIPTION.md

# ----------------------------------------------------------------
echo "--- Adapting conf files ---"

echo "Generating ${__OUT_BASTRA_FILE}"
sed -f /tmp/filter.sed TEMPLATE.bastra.conf > ${OUT_DIR}/${__OUT_BASTRA_FILE}

echo "Generating ${__OUT_DUA_FILE}"
sed -f /tmp/filter.sed TEMPLATE.duarouter.conf > ${OUT_DIR}/${__OUT_DUA_FILE}

echo "Generating ${__OUT_CMDS_FILE}"
sed -f /tmp/filter.sed commands/TEMPLATE.commands.${__MAP_USAGE}.xml > ${OUT_DIR}/${__OUT_CMDS_FILE}

echo "Generating ${__OUT_MAPS_FILE}"
sed -f /tmp/filter.sed ${SRC_MAP} > ${OUT_DIR}/${__OUT_MAPS_FILE}

# echo "Generating ${__OUT_NET_FILE}"
# sed -f /tmp/filter.sed TEMPLATE.net.${__NET_TYPE}.conf > ${OUT_DIR}/${__OUT_NET_FILE}

echo "Generating ${__OUT_OD_FILE}"
sed -f /tmp/filter.sed TEMPLATE.od.conf > ${OUT_DIR}/${__OUT_OD_FILE}

echo "Generating ${__OUT_ODMAT_FILE}"
sed -f /tmp/filter.sed TEMPLATE.odmat.${__NET_NAME}.xml > ${OUT_DIR}/${__OUT_ODMAT_FILE}

echo "Generating ${__OUT_SUMO_FILE}"
sed -f /tmp/filter.sed TEMPLATE.sumo.conf > ${OUT_DIR}/${__OUT_SUMO_FILE}

echo "Generating ${__OUT_TAZ_FILE}"
sed -f /tmp/filter.sed TEMPLATE.${__NET_NAME}.taz.xml > ${OUT_DIR}/${__OUT_TAZ_FILE}

echo "Generating ${__OUT_VEH_FILE}"
sed -f /tmp/filter.sed TEMPLATE.vehicle_distrib.conf > ${OUT_DIR}/${__OUT_VEH_FILE}
cp vehicle_types.xml ${OUT_DIR}/vehicle_types.xml
cp cities/${__NET_NAME}/sumo/${__NET_NAME}.net.xml ${OUT_DIR}/${__OUT_NETGEN_FILE}
# XXXXXXXXX
LOCATION=`grep "netOffset" ${OUT_DIR}/${__OUT_NETGEN_FILE}`
echo "LOCATION=${LOCATION}" >> $OUT_DIR/SCENARIO_DESCRIPTION.md

mkdir ${OUT_DIR}/maps
cp $SRC_MAP_DIR/* ${OUT_DIR}/maps

cd $OUT_DIR

# ----------------------------------------------------------------
echo "--- Adjusting the NETWORK ---"
# netgenerate -c ${__OUT_NET_FILE}
# echo "Adjusting length and speed"
# sed -f /tmp/filter.sed ${__OUT_NETGEN_FILE} | grep -v '</net>' > ${OUT_TMP_FILE}
echo "Adding TAZ files"
cat ${__OUT_NETGEN_FILE} | grep -v '</net>' > ${OUT_TMP_FILE}
cat ${__OUT_TAZ_FILE} >> ${OUT_TMP_FILE}
echo "</net>" >> ${OUT_TMP_FILE}
cp ${OUT_TMP_FILE} ${__OUT_NETGEN_FILE}

# ----------------------------------------------------------------
# DEMAND GENERATION
# ----------------------------------------------------------------
echo "-- DEMAND GENERATION --"

if [ ! -z ${__PREDEFINED_TRAFFIC_DEMAND} ]
then
  echo "!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "--- Using predefined DEMAND file: ${__PREDEFINED_TRAFFIC_DEMAND} ---"
  echo ""
  echo "    PLEASE CHECK THAT THEY'RE USING SAME NETWORK FILE VERSION"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  DEMAND_FILE="${__PREFIX}.typed-routes.xml"
  if [ -f ${__PREDEFINED_TRAFFIC_DEMAND} ]
  then
    cp ${__PREDEFINED_TRAFFIC_DEMAND} ${DEMAND_FILE}
  else
    die "Cannot access defined DEMAND file: ${__PREDEFINED_TRAFFIC_DEMAND}"
  fi
else
  echo "--- Generating the DEMAND od2trips ---"
  od2trips -c ${__OUT_OD_FILE} 

  # ----------------------------------------------------------------
  echo "--- Generating the DEMAND duarouter ---"
  duarouter -c ${__OUT_DUA_FILE} 2>&1 | tee duarouter.err
  TRIP_FILE=`ls -1 *trip*`
  echo "Generated "`grep "trip id=" $TRIP_FILE | wc -l`" trips"
  echo "--- Removing invalid trips ---"

  # -- ALGORYTHM 1 --
  # cat duarouter.err | grep " has no valid route" | cut -f2 -d"'" | while read i; do echo '(id=\"'$i'\" )'; done | sort > duarouter.invalid_vehicles.txt
  # echo "Removing "`wc -l duarouter.invalid_vehicles.txt`" invalid trips"
  # paste -s -d"|" duarouter.invalid_vehicles.txt > duarouter.filter_regex
  # egrep -v -f duarouter.filter_regex $TRIP_FILE > $TRIP_FILE.tmp

  # -- ALGORYTHM 2 --
  # cp $TRIP_FILE $TRIP_FILE.tmp
  # cat duarouter.err | grep " has no valid route" | cut -f2 -d"'" | while read i; do echo "Removing $i";grep -v '(id=\"'$i'\" )' $TRIP_FILE.tmp > $TRIP_FILE.tmp2; mv $TRIP_FILE.tmp2 $TRIP_FILE.tmp; done

  # -- ALGORYTHM 3 --
  cat duarouter.err | grep " has no valid route" | cut -f2 -d"'" | while read i; do echo '(id=\"'$i'\" )'; done | sort > duarouter.invalid_vehicles.txt
  echo "Removing "`wc -l duarouter.invalid_vehicles.txt`" invalid trips"
  paste -s -d"|" duarouter.invalid_vehicles.txt > duarouter.filter_regex
  python ../../tools/PYGREP/pygrep.py -v -f duarouter.filter_regex -d $TRIP_FILE > $TRIP_FILE.tmp

  mv $TRIP_FILE.tmp $TRIP_FILE

  # ----------------------------------------------------------------
  echo "--- Typing the vehicles generated in the DEMAND file ---"
  python ../../tools/randomVehType.py -c ${__OUT_VEH_FILE} 
fi

# ----------------------------------------------------------------
if [ ! -z ${__SET_AS_PREDEFINED_TRAFFIC_DEMAND} ]
then
  DEMAND_FILE="${__PREFIX}.typed-routes.xml"
  echo "-- Setting PREDEFINED DEMAND FILE: ${__SET_AS_PREDEFINED_TRAFFIC_DEMAND}"
  cp ${DEMAND_FILE} ${__SET_AS_PREDEFINED_TRAFFIC_DEMAND}
fi

# ----------------------------------------------------------------
cd -
