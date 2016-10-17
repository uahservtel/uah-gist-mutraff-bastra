
import optparse
import sys
import os
import subprocess
import traci
from bastralib import BastraLog
from bastralib import Sim as Sim
from bastralib import Command
from sumolib import checkBinary
from lxml import etree


def getConfig():
    parser = optparse.OptionParser("Configuration file is needed: bastra2.py -c name.conf.xml")
    parser.add_option("-c", dest="config_file", type="string")
    (options, args) = parser.parse_args()
    return options

def readOption(option, program):
    try:
        tree=etree.parse(config_file)
        root=tree.getroot()
        l_config=root.findall(program)
        label=l_config[ 0].find(option)
        value=label.get("value")
    except:
        sys.exit("Configuration error: value for " + option + " in " + program + " not found.")

    return value

def load_config():
    dict_conf={}
    dict_conf["tmp_dir"]=readOption("tmp_dir", "Bastra")
    dict_conf["results_dir"]=readOption("results_dir", "Bastra")
    dict_conf["log_dir"]=readOption("log_dir", "Bastra")
    dict_conf["log_file"]=readOption("log_file", "Bastra")
    dict_conf["log_level"]=readOption("log_level", "Bastra")
    dict_conf["dump_dir"]=readOption("dump_dir", "Bastra")
    dict_conf["new_routes_file"]=readOption("new_routes_file", "Bastra")
    dict_conf["route_file"]=readOption("route_file", "Bastra")
    dict_conf["logit"]=readOption("logit", "Bastra")
    dict_conf["commands_file"]=readOption("commands_file", "Bastra")
    dict_conf["statistics_f"]=readOption("statistics_file", "Bastra")
    dict_conf["begin"]=readOption("begin", "Bastra")
    dict_conf["end"]=readOption("end", "Bastra")

    dict_conf["f_tries"]=0
    try:
      dict_conf["f_tries"]=int(readOption("foresight_tries", "Bastra"))
    except:
      dict_conf["f_tries"]=0

    dict_conf["f_steps"]=0
    try:
      dict_conf["f_steps"]=int(readOption("foresight_steps", "Bastra"))
    except:
      dict_conf["f_steps"]=0

    dict_conf["f_halting"]=readOption("foresight_halting", "Bastra")
    dict_conf["f_penalty"]=readOption("foresight_penalty", "Bastra")

    # Alvaro Added: 15/09/16
    try:
      dict_conf["csv_sep"]=readOption("csv_sep", "Bastra")
    except:
       dict_conf["csv_sep"]=','

    # Alvaro Added: 10/10/16
    dict_conf["edge_stats_dump"]=False
    try:
      # True / False
      if( readOption("edge_stats_dump", "Bastra").lower() == "true" ):
        dict_conf["edge_stats_dump"]=True
    except:
       dict_conf["edge_stats_dump"]=False
    try:
      dict_conf["edge_stats_file"]=readOption("edge_stats_file", "Bastra")
    except:
      dict_conf["edge_stats_file"]='edge_stats.csv'

    try:
      dict_conf["edge_stats_sampling"]=int(readOption("edge_stats_sampling", "Bastra"))
    except:
      # If not defined, use a value enough to take at least 10 samples
      v = int((int(dict_conf["end"])-int(dict_conf["begin"]))/10)
      if( v < 0 ):
        v = 1
      dict_conf["edge_stats_sampling"]=v

    str_verbose=readOption("verbose", "Bastra")
    str_verbose.lower()
    if str_verbose=="true":
        dict_conf["verbose"]=True
    elif str_verbose=="false":
        dict_conf["verbose"]=False
    else:
        sys.exit("Configuration error: wrong value for 'verbose' in bastra's configuration file")
    str_balanced=readOption("use_balance", "Bastra")
    balanced=str_balanced.lower()
    if balanced=="true":
        dict_conf["balanced"]=True
    elif balanced=="false":
        dict_conf["balanced"]=False
    else:
        sys.exit("Configuration error: wrong value for 'use_balance' in bastra's configuration file")

    str_interactive=readOption("interactive", "Sumo")
    str_interactive.lower()
    if str_interactive=="true":
        dict_conf["interactive"]=True
    elif str_interactive=="false":
        dict_conf["interactive"]=False
    dict_conf["net_file"]=readOption("net_file", "Sumo")
    dict_conf["sumo_log_file"]=readOption("log_file", "Sumo")
    dict_conf["sumo_config"]=readOption("sumo_config", "Sumo")
    str_sumoPort=readOption("port", "Sumo")
    try:
        dict_conf["sumoPort"]=int(str_sumoPort)
    except:
        sys.exit("Configuration error: wrong value for SumoPort in " + config_file)

    if not os.path.isdir(dict_conf["tmp_dir"]):
        sys.exit("Configuration error: directory pointed by tmp_dir value not found")

    if not os.path.isdir(dict_conf["log_dir"]):
        sys.exit("Configuration error: directory pointed by log_dir value not found")

    if not os.path.isdir(dict_conf["dump_dir"]):
        sys.exit("Configuration error: directory pointed by dump_dir value not found")

    if not os.path.isdir(dict_conf["results_dir"]):
        sys.exit("Configuration error: directory pointed by results_dir value not found")


    return dict_conf


def readCommandsSequence(file_name):
    command_list=[]

    try:
        tree=etree.parse(file_name)
        root=tree.getroot()
        l_commands=root.findall("command")
        for comm in l_commands:
            time=int(comm.get("time"))
            name=comm.get("name")
            str_param=comm.get("param")
            param=str_param.split(' ')
            new_command=Command.Command(name, time, param)
            command_list.append(new_command)
    except:
        log_file.printLog(LEVEL1, "Error reading commands for " + file_name + "\n" )
        sys.exit("Error reading commands for " + file_name)

    return command_list


def get_simulation_results():
    l_vehicles_in=traci.vehicle.getIDList()
    for veh in l_vehicles_in:
        sim.actVehicleStatistics(veh)
    l_vehicles_out=traci.simulation.getArrivedIDList()
    for veh in l_vehicles_out:
        sim.actArriveTime(veh)

    return

# ==========================================================================
if __name__ == '__main__':

    #constants
    LEVEL1=1
    LEVEL2=2
    LEVEL3=3

    # -------------------------------------------------
    # Config reading parameters
    # -------------------------------------------------
    param=getConfig()
    config_file=param.config_file
    config=load_config().copy()
    log_file=BastraLog.BastraLog(config)

    # -------------------------------------------------
    # Check sumo installed
    # -------------------------------------------------
    try:
        sys.path.append(os.path.join(os.path.dirname(
            __file__), '..', '..', '..', '..', "tools"))
        sys.path.append(os.path.join(os.environ.get("SUMO_HOME", os.path.join(
            os.path.dirname(__file__), "..", "..", "..")), "tools"))  # tutorial in doc
    except ImportError:
        sys.exit("please declare environment variable 'SUMO_HOME' as the root directory of your sumo installation (it should contain folders 'bin', 'tools' and 'docs')")

    sim = Sim.simulated_traffic(config, log_file)
    if config["interactive"]:
        sumoBinary = checkBinary('sumo-gui')
    else:
        sumoBinary = checkBinary('sumo')

    # -------------------------------------------------
    # Start sumo and connect to it (traci)
    # -------------------------------------------------
    commands_sequence=readCommandsSequence(config["commands_file"])
    sumoProcess = subprocess.Popen([sumoBinary, "-c", config["sumo_config"],"--remote-port", str(config["sumoPort"])], stdout=sys.stdout, stderr=sys.stderr)
    traci.init(config["sumoPort"])

    # -------------------------------------------------
    # Simulation main loop:
    #	- End condition 1: reach max num simulations
    #	- End condition 2: do not exceed max time
    # -------------------------------------------------
    while (traci.simulation.getMinExpectedNumber() > 0) and (int(sim.getCurTime())<int(sim.getEnd())):
    	# ---------------------------------------------
	# Each simulation step:
    	# ---------------------------------------------
        sim.actCurTime()
        log_file.printLog(LEVEL3,"Processing step: " + str(sim.getCurTime()) + "\n")
        sim.processPendings()
        while len(commands_sequence)>0 and commands_sequence[0].getTime()==sim.getCurTime():
            command=commands_sequence.pop(0)
            log_file.printLog(LEVEL3,str(command.getTime()) + ": " + command.getName() + "\n")
            log_file.printLog (LEVEL3,str(command.getParams()) + "\n")
            com_name=command.getName().lower()
            com_params=command.getParams()

            if com_name=="maps":
                sim.processMaps(com_params[0])
            elif com_name=="incident":
                sim.processIncident(com_params[0])
            elif com_name=="restore":
                sim.processRestore(com_params[0])
            else:
                log_file.printLog(LEVEL1,"Command " + com_name + " not recognized \n")

        veh_list=traci.vehicle.getIDList()
        sim.reroute(veh_list)
        sim.foresight(veh_list, config)
        traci.simulationStep()
        get_simulation_results()

        sim.edge_stats_add( )

    # -------------------------------------------------
    # End of simulation
    # -------------------------------------------------
    sim.edge_stats_dump( )
    traci.close()
    print("Process terminated: step " + str(sim.getCurTime()) + "\n")
    sumoProcess.terminate()
    sim.printStatistics(config)

exit(0)
