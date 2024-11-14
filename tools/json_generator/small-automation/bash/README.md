How to use these scripts to generate the json report following the ai power measurement sharing ?

1. Edit the form_gen.conf to specify how many objects you want to generate in the form
2. Use the gen_form.sh script 
   ./gen_form.sh <generation type> <parameters file> > <output filename>
   This script uses the references.param file which has been created manually from the json datamodel. Please don't modify this file.
   It uses the parameters file to create the form with the desired number of objects instances.
   The form is written in the filename.txt
3. Edit the filename.txt to complete the fields directly inside this file before using the second script.
4. Transform this text file into our json model using the form2json.sh
    ./form2json.sh <File to convert to json> > <output filename>
    You just created your first report !

troubleshooting : 
- if you have this error : "/bin/bash^M: bad interpreter: No such file or directory" -> use this command : sed -i -e 's/\r$//' <script_name>
