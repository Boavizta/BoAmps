import pydantic
from inference_schema_validator import Query,ParametersNLP
from algorithm_schema_validator import Algorithm, Hyperparameters, Hyperparameter
from dataset_schema_validator import Dataset
from hardware_schema_validator import Hardware
from measure_schema_validator import Measure
from report_schema_validator import Publisher, Header, Task, System, Software, Infrastructure, Environment, Hash, Report

#Validation for algorithm_schema_validator
valid_parameternlp = ParametersNLP(nb_tokens_input=1,
                                  nb_words_input=1,
                                  nb_tokens_output=1,
                                  nb_words_output=1,
                                  context_windows_size=12,
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
                        volumeUnit="terabyte",
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

valid_measure = Measure(measurementMethod="both",
                        manufacturer="nvidia",
                        cpuTrackingMode="native",
                        gpuTrackingMode="native",
                        averageUtilizationCpu=0.8,
                        averageUtilizationGpu=0.2,
                        serverSideInference="both",
                        unit="kWh",
                        powerCalibrationMeasurement=0.4,
                        durationCalibrationMeasurement=0.3,
                        powerConsumption=1.2,
                        measurementDuration=1.2,
                        measurementDateTime=1209)


#Validation for report_schema_validator
publisher = Publisher( name="John Doe", 
                      division="Research", 
                      projectname="AI Project", 
                      confidentialityLevel="internal", 
                      publicKey="public_key_here" ) 


header = Header( licensing="MIT", 
                formatVersion="1.0", 
                formatVersionSpecificationUri="https://example.com/spec", 
                reportId="12345", 
                reportDatetime="2024-11-15T16:00:00", 
                reportStatus="draft", 
                publisher=publisher ) 


task = Task( taskType="Classification", 
            taskFamily="Machine Learning", 
            taskStage="Training", 
            algorithms=[Algorithm(algorithmName="centroids"), Algorithm(algorithmName="centroids")], 
            datasets=[Dataset(dataType="tabular"), Dataset(dataType="tabular")], 
            measuredAccuracy=0.85, 
            estimatedAccuracy="good" ) 


system = System( os="Linux", 
                distribution="Ubuntu", 
                distributionVersion="20.04" ) 


software = Software( language="Python", 
                    version="3.8" ) 


hardware = Hardware( componentName="CPU", 
                    nbComponent=2, 
                    memorySize=32, 
                    manufacturer="Intel", 
                    family="Xeon", 
                    series="E5", 
                    share=0.5 ) 


infrastructure = Infrastructure( infraType="publicCloud", 
                                cloudProvider="AWS", 
                                cloudInstance="t2.large",
                                components=[hardware] ) 


environment = Environment( country="France",
                           latitude=45.188529, 
                           longitude=5.724524, 
                           location="Grenoble", 
                           powerSupplierType="public", 
                           powerSource="nuclear", 
                           powerSourceCarbonIntensity=12.5 )


hash = Hash( hashAlgorithm="SHA-256", 
            cryptographicAlgorithm="RSA", 
            country="France" ) 


report = Report( header=header, 
                model=task, 
                measures=[valid_measure], 
                system=system, 
                software=software, 
                infrastructure=infrastructure,
                quality="high", 
                hash=hash )