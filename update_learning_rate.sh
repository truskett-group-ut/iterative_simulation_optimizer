#!/bin/bash

old_lr=$1
min_lr=$2
max_lr=$3
new_gr=$4
if [ -s ../convergence.txt ]; then              
    old_gr=`tail -n 1 ../convergence.txt | awk '{print $3}'i | sed 's/
else 
    old_gr=100.0
fi

frac_change=`echo "($new_gr - $old_gr) / $old_gr" | bc -l`

if (( $(echo "$frac_change > 0.1" | bc -l) )); then
    if (( $(echo "$frac_change < 0.25" | bc -l) )); then
        new_lr=$old_lr
    elif (( $(echo "$frac_change > 2.0" | bc -l) )); then
        new_lr=`echo "$old_lr * 0.25" | bc -l`
    else
        new_lr=`echo "$old_lr * 0.5" | bc -l`
    fi
elif (( $(echo "$frac_change < -0.1" | bc -l) )); then
    new_lr=$old_lr
else
    new_lr=`echo "$old_lr * 2.0" | bc -l`
fi

if (( $(echo "$new_lr > $max_lr" | bc -l) )); then
    new_lr=$max_lr
fi
if (( $(echo "$new_lr < $min_lr" | bc -l) )); then
    new_lr=$min_lr
fi

new_lr=`printf "%.3f\n" $new_lr`
echo $new_lr $old_lr $min_lr $max_lr $new_gr $old_gr $frac_change

sed -e "/<learning_rate>/ s/$old_lr/$new_lr/" ../settings.xml > settings.xml
cp settings.xml ../
wait