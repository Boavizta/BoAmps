import pydantic
from inference_schema_validator import Query,ParametersNLP
from algorithm_schema_validator import Algorithm, Hyperparameters, Hyperparameter
from dataset_schema_validator import Dataset
from hardware_schema_validator import Hardware
from measure_schema_validator import Measure

#Validation for algorithm_schema_validator
valid_parameternlp = ParametersNLP(nb_tokens_input=1,
                                  nb_words_input=1,
                                  nb_tokens_output=1,
                                  nb_words_output=1,
                                  context_windows_size=12.2,
                                  cache=True)

valid_querry = Query(nb_request=1,ParametersNLP=valid_parameternlp)


#Validation for algorithm_schema_validator
hp1 = Hyperparameter(hyperparameterName="learning_rate", hyperparameterValue="0.01") 
hp2 = Hyperparameter(hyperparameterName="batch_size", hyperparameterValue="32") 
hyperparams = Hyperparameters(tuningMethod="grid_search", values=[hp1, hp2]) 
valid_algorith = Algorithm(algorithmName="centroids", 
                           framework="Pytorch", 
                           frameworkVersion="1.2.0", 
                           classPath="\src", 
                           quantization="12", 
                           hyperparameters=hyperparams)


#Validation for dataset_schema_validator
valid_dataset = Dataset(dataType="tabular",
                        fileType="3gpp",
                        volume=12,
                        volumeUnit="tera",
                        items=12,
                        shape=[1,2],
                        inferenceProperties=[valid_querry],
                        source="public",
                        sourceUri="me",
                        owner="me")


#validation for hardware_schema_validator
valid_hardware = Hardware(componentName="cpu",
                          nbComponent=12,
                          memorySize=12,
                          manufacturer="intel",
                          family="i5",
                          series="10",
                          share=0.4)

valid_measure = Measure(measurementMethod="direct";
                        manufacturer="nvidia";
                        cpuTrackingMode="native",
                        gpuTrackingMode="native",
                        averageUtilizationCpu="3.2",
                        averageUtilizationGpu="2.2",
                        serverSideInference="full",
                        unit="k",
                        powerCalibrationMeasurement=1.2,
                        durationCalibrationMeasurement=3.0,
                        powerCalibrationMeasurement=1.2,
                        measurementDuration=1.2,
                        measurementDateTime=1209)