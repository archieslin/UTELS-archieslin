#!//bin/csh

#foreach per (10)
foreach per (`cat period_10_50.txt`)
foreach st (`cat station.txt`)

set threshold_avg=9999
set threshold_med=9999
set threshold_avg_2=1
set threshold_med_2=1
set a=1
set b=1

set dfile=`ls $per""sec10snr$st.txt`
set lon=`cat $dfile | gawk 'NR==1 {print $3-360}'`
set lat=`cat $dfile | gawk 'NR==1 {print $4}'`
set quantity=`cat $dfile | gawk 'END {print NR}'`
set quantity_avg=$quantity
set quantity_med=$quantity
#### Average ####
while ( `echo "$threshold_avg_2 >= 0.1"| bc -l`)
#while ( $a <= 3 )
echo //// $st "Do While(AVG)" $a times. ////
echo //// $st "Do While(AVG)" $a times. //// >> Data/Check_Data/$per""s_avg_HV_test.txt

set avghv=`awk '($5<=cc) {sum+=$5} END {printf "%6.5f", sum/NR}' cc=$threshold_avg $dfile`
set stdev_avg=`awk -v a=$avghv '($5<=cc) {sum+=(($5-a)^2)} END {printf "%6.5f", sqrt(sum/(NR))}' cc=$threshold_avg $dfile`
set quantity_avg=`cat $dfile | gawk '($5<=cc)' cc=$threshold_avg | gawk 'END {print NR}'`
set stderr_avg=`echo "scale=5; $stdev_avg / $quantity_avg" | bc -l`
set stderr_avg=`printf "%.5f" $stderr_avg`
echo Average: $avghv $stdev_avg $quantity_avg $stderr_avg
echo Average: $avghv $stdev_avg $quantity_avg $stderr_avg >> Data/Check_Data/$per""s_avg_HV_test.txt

set threshold_avg_new=`echo "$avghv+2*$stdev_avg" | bc -l`
set threshold_avg_3=`echo "$threshold_avg-$threshold_avg_new" | bc -l`
set threshold_avg_2=`printf "%.5f" $threshold_avg_3`
set threshold_avg_1=`printf "%.5f" $threshold_avg_new`
set threshold_avg=`printf "%.5f" $threshold_avg_new`
echo Threshold_avg: $threshold_avg $threshold_avg_2"\n"
echo Threshold_avg: $threshold_avg $threshold_avg_2"\n" >> Data/Check_Data/$per""s_avg_HV_test.txt
@ a++
end

set aa=`echo "$a-1" | bc`
#echo $st $aa times >> Data/Check_Data/$per""s_times_avg.txt

#### Median ####
while ( `echo "$threshold_med_2 >= 0.1"| bc -l`)
#while ( $b <= 3 )
echo //// $st "Do while(MED)" $b times. ////
echo //// $st "Do while(MED)" $b times. //// >> Data/Check_Data/$per""s_med_HV_test.txt

set median=`awk '($5<=dd) { a[i++]=$5; } END { x=int((i+1)/2); if (x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1]; }' dd=$threshold_med $dfile`
set stdev_med=`awk -v m=$median '($5<=dd) {sum+=(($5-m)^2)} END {printf "%6.5f", sqrt(sum/(NR))}' dd=$threshold_med $dfile`
set quantity_med=`cat $dfile | gawk '($5<=dd)' dd=$threshold_med | gawk 'END {print NR}'`
set stderr_med=`echo "scale=5; $stdev_med / $quantity_med" | bc -l`
set stderr_med=`printf "%.5f" $stderr_med`
echo Median: $median $stdev_med $quantity_med $stderr_med
echo Median: $median $stdev_med $quantity_med $stderr_med >> Data/Check_Data/$per""s_med_HV_test.txt

set threshold_med_new=`echo "$median+2*$stdev_med" | bc -l`
set threshold_med_3=`echo "$threshold_med-$threshold_med_new" | bc -l`
set threshold_med_2=`printf "%.5f" $threshold_med_3`
set threshold_med_1=`printf "%.5f" $threshold_med_new`
set threshold_med=`printf "%.5f" $threshold_med_new`
echo Threshold_med: $threshold_med $threshold_med_2"\n"
echo Threshold_med: $threshold_med $threshold_med_2"\n" >> Data/Check_Data/$per""s_med_HV_test.txt
@ b++
end

set bb=`echo "$b-1" | bc`
#echo $st $bb times >> Data/Check_Data/$per""s_times_med.txt

if (`echo "$quantity_avg >= $quantity*0.5" | bc -l`) then
echo $st $lon $lat $avghv $stdev_avg $stderr_avg $quantity_avg >> Data/HV_Data/$per""s_HV_Avg_Data.txt
echo $st $aa times >> Data/Check_Data/$per""s_times_avg.txt
else
echo $st $quantity $quantity_avg $aa times  >> Data/Check_Data/$per""s_times_avg.txt
endif

if (`echo "$quantity_med >= $quantity*0.5" | bc -l`) then
echo $st $lon $lat $median $stdev_med $stderr_med $quantity_med >> Data/HV_Data/$per""s_HV_Med_Data.txt
echo $st $bb times >> Data/Check_Data/$per""s_times_med.txt
else
echo $st $quantity $quantity_med $bb times >> Data/Check_Data/$per""s_times_med.txt
endif

end
echo $per""s Done.
end

