Some proposition of changes can be seen in `codecarbonVersFormulaire.md`.

How to use these scripts to generate the json report following the ai power measurement sharing ?

1. Edit the form_Gen.conf to specify how many objects you want to generate in the form

2. Use the gen_form.sh script 
   ./gen_form.sh <generation type> <parameters file> > <output file>
   generation type can be -a for all fields, -m for mandatory fields
   <parameters file> is form_Gen.conf in this directory
   <output file> can be a txt file

   Example: ./gen_form.sh -a form_Gen.conf > report1.txt 

   This script uses the references.param file which has been created manually from the json datamodel. Please don't modify this file.

   It uses the parameters file to create the form with the desired number of objects instances.
   The form is written in the <output file>.

3. Edit the <output file> to complete the fields directly inside this file before using the second script.

4. Transform this text file into our json model using the form2json.sh
    ./form2json.sh <File to convert to json> > <output filename>
    You just created your first report !

troubleshooting : 
- if you have this error : "/bin/bash^M: bad interpreter: No such file or directory" -> use this command : sed -i -e 's/\r$//' <script_name>

Why is ├quantization mandatory?
├cpuTrackingMode what is this?
├gpuTrackingMode what is this?

├averageUtilizationCpu how to get this, same for gpu?


Lots of optional fields make it annoying to create the report
├formatVersionSpecificationUri


What can be automated / improved?

├licensing → MULTI select common license or other
├formatVersion → always use same format for all documents 0.0.1
├reportId → generate UUID automatically
├reportDatetime → generate date automatically 
├reportStatus →  MULTI draft, final, corrective, $other


├confidentialityLevel → MULTI public, internal, confidential, secret

├publicKey generate automatically?


Can be automated in python:
 ├os=                                                                                              
 ├distribution=                                                                                
 ├distributionVersion=  

