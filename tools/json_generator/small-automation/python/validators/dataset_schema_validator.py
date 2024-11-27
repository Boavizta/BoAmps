from pydantic import BaseModel, Field
from typing import Annotated, List
from inference_schema_validator import Query
from typing import Optional
#from \model\dataset_schema.json

class Dataset(BaseModel):
    dataType: Optional[Annotated[str, Field(pattern=r"(tabular|audio|boolean|image|video|object|text|$other)")]] = None
    fileType: Optional[Annotated[str, Field(pattern=r"(3gp|3gpp|3gpp2|8svx|aa|aac|aax|act|afdesign|afphoto|ai|aiff|alac|amr|amv|ape|arrow|asf|au|avi|avif|awb|bmp|bpg|cd5|cda|cdr|cgm|clip|cpt|csv|deep|dirac|divx|drawingml|drw|dss|dvf|ecw|eps|fits|flac|flif|flv|flvf4v|gem|gerber|gif|gle|gsm|heif|hp-gl|html|hvif|ico|iklax|ilbm|img|ivs|jpeg|json|kra|lottie|m4a|m4b|m4p|m4v|mathml|matroska|mdp|mmf|movpkg|mp3|mpc|mpeg1|mpeg2|mpeg4|msv|mxf|naplps|netpbm|nmf|nrrd|nsv|odg|ods|ogg|opus|pam|parquet|pbm|pcx|pdf|pdn|pgf|pgm|pgml|pict|plbm|png|pnm|postscript|ppm|psd|psp|pstricks|qcc|quicktime|ra|raw|realmedia|regis|rf64|roq|sai|sgi|sid|sql|sln|svg|svi|swf|text|tga|tiff|tinyvg|tta|vicar|vivoactive|vml|vob|voc|vox|wav|webm|webp|wma|wmf|wmv|wv|xaml|xar|xcf|xisf|xls|xlsx|xml|xps|yaml|$other|null)")]] = None
    volume: Optional[int] = 0
    volumeUnit: Optional[Annotated[str, Field(pattern=r"(kilobyte|megabyte|gigabyte|terabyte|petabyte|exabyte|zettabyte|yottabyte)")]] = None
    items: Optional[int] = 0
    shape: Optional[List[int]] = 0
    inferenceProperties: Optional[List[Query]] = []
    source: Optional[Annotated[str, Field(pattern=r"(public|private|$other)")]] = None
    sourceUri: Optional[str] = None
    owner: Optional[str] = None