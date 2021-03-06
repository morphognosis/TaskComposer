# Test world composer performance.

if [ "$1" = "" ]
then
   echo "Usage: world_composer_no_train_modular_paths_test.sh <number of runs>"
   exit 1
fi
runs=$1

# Parameters:
minBasePathLength=10
incrBasePathLength=10
maxBasePathLength=20
minModularPathLength=2
maxModularPathLength=5
minNumModularPaths=5
incrNumModularPaths=5
maxNumModularPaths=10
numNeurons=256
kernelSize=2

echo basePathLength,numModularPaths,numNeurons,pathModificationType,train_prediction_errors,train_total_predictions,train_error_pct,test_prediction_errors,test_total_predictions,test_error_pct > world_composer_no_train_nn_dilate_normalize_skew_test_results.csv
echo basePathLength,numModularPaths,numNeurons,pathModificationType,train_prediction_errors,train_total_predictions,train_error_pct,test_prediction_errors,test_total_predictions,test_error_pct > world_composer_no_train_rnn_test_results.csv
echo basePathLength,numModularPaths,kernelSize,pathModificationType,train_prediction_errors,train_total_predictions,train_error_pct,test_prediction_errors,test_total_predictions,test_error_pct > world_composer_no_train_tcn_test_results.csv

for basePathLength in $(seq $minBasePathLength $incrBasePathLength $maxBasePathLength)
do
 for numModularPaths in $(seq $minNumModularPaths $incrNumModularPaths $maxNumModularPaths)
 do
    for i in $(seq $runs)
    do
     numInsertionTestPaths=$(( $basePathLength / 2 ))
     numSubstitutionTestPaths=$(( $basePathLength / 2 ))
     numDeletionTestPaths=$(( $basePathLength / 2 ))
     randomSeed=$RANDOM
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths 0 -numDeletionTestPaths 0 -randomSeed $randomSeed
     python world_path_tcn.py --kernel_size $kernelSize
     echo ${basePathLength},${numModularPaths},${kernelSize},insert,$(cat world_path_tcn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_tcn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths 0 -randomSeed $randomSeed
     python world_path_tcn.py --kernel_size $kernelSize
     echo ${basePathLength},${numModularPaths},${kernelSize},substitute,$(cat world_path_tcn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_tcn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths 0 -numDeletionTestPaths $numDeletionTestPaths -randomSeed $randomSeed
     python world_path_tcn.py --kernel_size $kernelSize
     echo ${basePathLength},${numModularPaths},${kernelSize},delete,$(cat world_path_tcn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_tcn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths $numDeletionTestPaths -randomSeed $randomSeed
     python world_path_tcn.py --kernel_size $kernelSize
     echo ${basePathLength},${numModularPaths},${kernelSize},all,$(cat world_path_tcn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_tcn_test_results.csv
    done
 done
done

for basePathLength in $(seq $minBasePathLength $incrBasePathLength $maxBasePathLength)
do
 for numModularPaths in $(seq $minNumModularPaths $incrNumModularPaths $maxNumModularPaths)
 do
    for i in $(seq $runs)
    do
     numInsertionTestPaths=$(( $basePathLength / 2 ))
     numSubstitutionTestPaths=$(( $basePathLength / 2 ))
     numDeletionTestPaths=$(( $basePathLength / 2 ))
     randomSeed=$RANDOM

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths 0 -numDeletionTestPaths 0 -randomSeed $randomSeed
     python world_path_rnn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},insert,$(cat world_path_rnn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_rnn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths 0 -numDeletionTestPaths 0 -dilateEvents normalize -skew .5 -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},insert,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_dilate_normalize_skew_test_results.csv

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths 0 -randomSeed $randomSeed
     python world_path_rnn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},substitute,$(cat world_path_rnn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_rnn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths 0 -dilateEvents normalize -skew .5 -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},substitute,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_dilate_normalize_skew_test_results.csv

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths 0 -numDeletionTestPaths $numDeletionTestPaths -randomSeed $randomSeed
     python world_path_rnn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},delete,$(cat world_path_rnn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_rnn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths 0 -numDeletionTestPaths $numDeletionTestPaths -dilateEvents normalize -skew .5 -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},delete,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_dilate_normalize_skew_test_results.csv

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths $numDeletionTestPaths -randomSeed $randomSeed
     python world_path_rnn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},all,$(cat world_path_rnn_results.json | cut -d'"' -f12,16,20,32,36,40 | sed 's/"/,/g') >> world_composer_no_train_rnn_test_results.csv
     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths $numDeletionTestPaths -dilateEvents normalize -skew .5 -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},all,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_dilate_normalize_skew_test_results.csv

    done
 done
done

echo basePathLength,numModularPaths,numNeurons,pathModificationType,train_prediction_errors,train_total_predictions,train_error_pct,test_prediction_errors,test_total_predictions,test_error_pct > world_composer_no_train_nn_test_results.csv

for basePathLength in $(seq $minBasePathLength $incrBasePathLength $maxBasePathLength)
do
 for numModularPaths in $(seq $minNumModularPaths $incrNumModularPaths $maxNumModularPaths)
 do
    for i in $(seq $runs)
    do
     numInsertionTestPaths=$(( $basePathLength / 2 ))
     numSubstitutionTestPaths=$(( $basePathLength / 2 ))
     numDeletionTestPaths=$(( $basePathLength / 2 ))
     randomSeed=$RANDOM

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths 0 -numDeletionTestPaths 0 -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},insert,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_test_results.csv

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths 0 -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},substitute,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_test_results.csv

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths 0 -numSubstitutionTestPaths 0 -numDeletionTestPaths $numDeletionTestPaths -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},delete,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_test_results.csv

     ./world_composer.sh -noTrainModularPaths -basePathLength $basePathLength -minModularPathLength $minModularPathLength -maxModularPathLength $maxModularPathLength -numModularPaths $numModularPaths -numInsertionTestPaths $numInsertionTestPaths -numSubstitutionTestPaths $numSubstitutionTestPaths -numDeletionTestPaths $numDeletionTestPaths -randomSeed $randomSeed
     python world_path_nn.py --neurons $numNeurons
     echo ${basePathLength},${numModularPaths},${numNeurons},all,$(cat world_path_nn_results.json | cut -d'"' -f4,8,12,16,20,24 | sed 's/"/,/g') >> world_composer_no_train_nn_test_results.csv

    done
 done
done

exit 0

