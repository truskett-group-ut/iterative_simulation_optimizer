#!/bin/bash
#wp: pre-processing script to check the last partial or completed step and if not, create an initial step
#
# first check to find the last completed step
#

#wp: root name for all iteration folders
STEP_PRE=step_
#wp: Resume or initial iterations limited by these values
i=999
j=999
OLD_DIR=$STEP_PRE$j
#wp: Checks existence of old dir with '-d' operator; moves backward from some limit number and breaks once it finds one
while [ ! -d $OLD_DIR ] && [ $i -gt 0 ]; do
    let i-=1
    printf -v j "%03g" $i
    OLD_DIR=$STEP_PRE$j
done

#wp:choose procedure based on num of components
num_components=$1

if [ $num_components -eq 1 ]; then 
	#wp: If it can't find any directories, then creates a zero calories guess
	if [ $i -eq 0 ]; then
	    if [ ! -d $OLD_DIR ]; then
		mkdir $OLD_DIR
	    fi
	    #wp: copies initial user guess of parameters to the created folder
	    if [ -f params_val.json ]; then
		cp params_val.json $OLD_DIR/params_val_out.json
	    elif [ -f $OLD_DIR/params_val.json ]; then #if they are there then signal for next step
		cp $OLD_DIR/params_val.json $OLD_DIR/params_val_out.json
	    fi    
	    #wp: flag to indicate old directory has undergone simulation 
	    if [ ! -f $OLD_DIR/done.txt ]; then
		touch $OLD_DIR/done.txt
	    fi
	fi

	#wp: operator 'z' checks if string length is 0; 
	while [ -z ${NEW_DIR+x} ]; do
	    #wp: operator 's' checks if file exists and has size > 0; 
	    # If the file exists then create new directory (the next step)
	    if [ -s $OLD_DIR/params_val_out.json ]; then
		let i+=1
		printf -v j "%03g" $i
		NEW_DIR=$STEP_PRE$j
	    else #wp: file does not exist --> step not post processed
		#wp:If 'done.txt' exists, simulation for that step was performed
		if [ -f $OLD_DIR/done.txt ]; then
		    NEW_DIR=$OLD_DIR
		else #wp: step didn't run simulation nor was post-processed
		    d=$(date +%F-%T)
		    mv $OLD_DIR $OLD_DIR-$d
		    let i-=1
		    printf -v j "%03g" $i
		    OLD_DIR=$STEP_PRE$j
		fi
	    fi
	done

	#wp: If none of the flagging files can be found in the old dir, then user don goof and the plug is pulled 
	if [ ! -s $OLD_DIR/params_val.json ] && [ ! -s $OLD_DIR/params_val_out.json ]; then
	    echo "need initial parameters in file" $OLD_DIR
	    exit 1    
	fi
elif [ $num_components -gt 1 ]; then
	#wp: If it can't find any directories, then creates a zero calories guess
	if [ $i -eq 0 ]; then
	    if [ ! -d $OLD_DIR ]; then
		mkdir $OLD_DIR
	    fi
	    #wp: copies initial user guess of parameters to the created folder
	    filetocheck="params_val_A_B.json" #wp: some responsability is passed onto the user to have the rest of files for now 
	    if [ -f $filetocheck ]; then
		for param_i in params_val_?_?.json; do
			#wp:picks out the file component name e.g. _A_A
			comp_pair=${param_i:10:4}	
			#wp:reconstructs new val param file for appropriate component
			params_val_ij='params_val'$comp_pair'_out.json' 
			#wp:Then copies it
			cp $param_i $OLD_DIR/$params_val_ij
		done
	    elif [ -f $OLD_DIR/$filetocheck ]; then #if they are there then signal for next step
		cd $OLD_DIR
		for param_i in params_val_?_?.json; do
			#wp:picks out the file component name e.g. _A_A
			comp_pair=${param_i:10:4}	
			#wp:reconstructs new val param file for appropriate component
			params_val_ij='params_val'$comp_pair'_out.json' 
			#wp:Then copies it
			cp $param_i $params_val_ij
		done
		cd ..
	    fi    
	    #wp: flag to indicate old directory has undergone simulation 
	    if [ ! -f $OLD_DIR/done.txt ]; then
		touch $OLD_DIR/done.txt
	    fi
	fi

	#wp: operator 'z' checks if string length is 0; 
	filetocheck2="params_val_A_B_out.json" #wp: some responsability is passed onto the user to have the rest of files for now
	while [ -z ${NEW_DIR+x} ]; do
	    #wp: operator 's' checks if file exists and has size > 0; 
	    # If the file exists then create new directory (the next step)
	    if [ -s $OLD_DIR/$filetocheck2 ]; then
		let i+=1
		printf -v j "%03g" $i
		NEW_DIR=$STEP_PRE$j
	    else #wp: file does not exist --> step not post processed
		#wp:If 'done.txt' exists, simulation for that step was performed
		if [ -f $OLD_DIR/done.txt ]; then
		    NEW_DIR=$OLD_DIR
		else #wp: step didn't run simulation nor was post-processed
		    d=$(date +%F-%T)
		    mv $OLD_DIR $OLD_DIR-$d
		    let i-=1
		    printf -v j "%03g" $i
		    OLD_DIR=$STEP_PRE$j
		fi
	    fi
	done

	#wp: If none of the flagging files can be found in the old dir, then user don goof and the plug is pulled 
	if [ ! -s $OLD_DIR/$filetocheck ] && [ ! -s $OLD_DIR/$filetocheck2 ]; then
	    echo "need initial parameters in file" $OLD_DIR
	    exit 1    
	fi
fi #wp:end component if

#wp:prints directory names
echo $OLD_DIR
echo $NEW_DIR
