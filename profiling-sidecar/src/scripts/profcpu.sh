#!/bin/bash

# Based on Microsoft's perfcollect
# https://aka.ms/perfcollect
# Some pieces of code was taken from there

######################################
## FOR DEBUGGING ONLY
######################################
# set -x

######################################
## Helper Functions
######################################

# $1 == Message.
FatalError()
{
    echo "ERROR: $1"
    PrintUsage
    exit 1
}

PrintUsage()
{
    echo "./profcpu <action>"
    echo "Valid Actions: collect postprocess"
    echo ""
    echo "collect:"
    echo "    Collect on CPU samples and create a flamegraph out of them."
    echo "    -pid          : ID of the process from which samples will be collected. Defaults to 1."
    echo "    -duration     : Collection duration. Defaults to 30 seconds."
    echo ""
    echo "postprocess:"
    echo "    Post-process a previously collected perf data."
    echo "    -dir          : Directory containing collected data."
    echo ""
}


######################################
# Argument Processing
######################################
action=''
collectionPid="1"
collectionDuration="30"
postProcessDir=''

ProcessArguments()
{
    # Set the action
    action=$1

    # Not enough arguments.
    if [ "$#" -le "0" ]
    then
        FatalError "Not enough arguments have been specified."
    fi

    # Validate action name.
    if [ "$action" != "collect" ] && [ "$action" != "postprocess" ]
    then
        FatalError "Invalid action specified."
    fi

    # Process remaining arguments.
    # First copy the args into an array so that we can walk the array.
    args=( "$@" )
    for (( i=1; i<${#args[@]}; i++ ))
    do
        # Get the arg.
        local arg=${args[$i]}

        # Convert the arg to lower case.
        arg=`echo $arg | tr '[:upper:]' '[:lower:]'`

        # Get the arg value.
        if [ ${i+1} -lt $# ]
        then
            local value=${args[$i+1]}
        fi

        # Match the arg to a known value.
        if [ "-pid" == "$arg" ]
        then
            collectionPid=$value
            i=$i+1
        elif [ "-duration" == "$arg" ]
        then
            collectionDuration=$value
            i=$i+1
        elif [ "-dir" == "$arg" ]
        then
            postProcessDir=$value
            i=$i+1
        else
            echo "Unknown arg ${arg}, ignored..."
        fi
    done
    
}

# $1 == perf.data out dir
OnCPURecord() {
    recordFrequency=99
    echo -e "> Starting 'perf record' of PID $collectionPid with sampling frequency $recordFrequency Hz..."
    echo -e "> Will record for $collectionDuration seconds..."

    perf record -F $recordFrequency -p $collectionPid -g -k 1 -- sleep $collectionDuration

    mkdir -p $1
    mv perf.data $1

    echo -e "> Finished gathering data."
}

# $1 == directory of the perf.data to be processed
PostProcess() {
    echo -e "\n> Starting post process..."

    echo -e "> Files will be saved at '$1'"

    cd $1

    chown root:root ./*
    rm -f prof.tar.gz

    # perf inject --jit --input perf.data --output perf.jit.data
    # perf script --header --input perf.jit.data > "./perf_script.out"
    perf script --header --input perf.data > "./perf_script.out"

    echo -e "\n> Generating flamegraphs..."
    /workspace/flamegraph-utils/stackcollapse-perf.pl "./perf_script.out" > "./folded_stacks.out"
    /workspace/flamegraph-utils/flamegraph.pl "./folded_stacks.out" > "./flamegraph.svg"

    chown 1000:1000 "/workspace/profilings"
    chown 1000:1000 "."
    chown 1000:1000 ./*

    tar -czf prof.tar.gz *

    chown 1000:1000 ./*

    cd $2
    rm -f flamegraphs.tar.gz
    tar -czf flamegraphs.tar.gz **/flamegraph.svg
    chown 1000:1000 flamegraphs.tar.gz
    echo -e "> Created flamegraphs.tar.gz file with all flamegraphs from profiles"
}

########################################

ProcessArguments $@

if [ "$action" == "collect" ]; then
    prevDir=$PWD
    currentDate=$(date +"%H-%M-%S_%F")
    outdir="profilings/$currentDate"
    profilingsDir="$PWD/profilings"
    OnCPURecord $outdir
    PostProcess $outdir $profilingsDir $currentDate
elif [ "$action" == "postprocess" ]; then
    PostProcess $postProcessDir
fi;