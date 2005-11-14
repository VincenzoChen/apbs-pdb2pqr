#!/bin/bash

if [[ $1 = "" ]]; then
    echo "Please use \"make test\" to run the tests."
    exit
fi


logfile=TESTRESULTS.log
nettime=0
vsmall=0.000000001000

input=( apbs-mol apbs-smol apbs-spl2 ) 

results=( -5.244143066515E+01 -5.403934162196E+01 -1.217756522672E+01)

# Initialize the results file

date=`date`
echo "Date     : ${date}" >> $logfile
echo "Directory: hca-bind" >> $logfile
echo "Results  :" >> $logfile

# For each file in the directory, run APBS and get the value

for i in 0 1 2 
do
  echo "----------------------------------------"
  echo "Testing input file ${input[i]}.in"
  echo ""

 
  starttime=`date +%s`
  $1 ${input[i]}.in > ${input[i]}.out 
  answer=`grep "Global net" ${input[i]}.out | awk '{print $5}'`
 
  echo "Global net energy: $answer"
  sync

  fanswer=`printf "%.12f" $answer`
  fexpected=`printf "%.12f" ${results[i]}`
  r=`echo "scale=12;if($fanswer>($fexpected-$vsmall) && $fanswer<($fexpected+$vsmall))r=1;if($fanswer == $fexpected)r=2;r" | bc`
  case "$r" in
      2)  echo "*** PASSED ***"
          echo "           ${input[i]}.in: PASSED ($answer)" >> $logfile ;;
      1)  echo "*** PASSED (with rounding error - see log) ***"
          echo "           ${input[i]}.in: PASSED with rounding error ($answer; expected ${results[i]})" >> $logfile ;;
      *)  echo "*** FAILED ***"
          echo "   APBS returned $answer"
          echo "   Expected result is ${results[i]}"
          echo "           ${input[i]}.in: FAILED ($answer; expected ${results[i]})" >> $logfile ;;
  esac
  
  endtime=`date +%s`
  let elapsed=$endtime-$starttime
  let nettime=$nettime+$elapsed
  echo "Total elapsed time: $elapsed seconds"
  echo "----------------------------------------"

done

echo "Test results have been logged to ${logfile}."
echo "Total time for this directory: ${nettime} seconds."

echo "Time     : ${nettime} seconds" >> $logfile
echo "" >> $logfile
