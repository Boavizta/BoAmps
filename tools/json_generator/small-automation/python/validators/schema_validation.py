import pydantic
from inference_schema_validator import Query,ParametersNLP
from algorithm_schema_validator import Algorithm, Hyperparameters, Hyperparameter

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
valid_props= Algorithm.Properties( algorithmName="Neural Network", framework="TensorFlow", frameworkVersion="2.4.1", classPath="models.MyModel", quantization=8, hyperparameters=hyperparams ) 
algorithm = Algorithm(properties=valid_props)