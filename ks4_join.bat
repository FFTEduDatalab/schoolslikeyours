D:\Tools\clean.exe .\fos\ks4\data\ks4_data.dat .\fos\ks4\data\ks4_data.json --export --json
echo {"meta":[ > .\fos\ks4\data\ks4_sly.json
more .\fos\ks4\data\ks4_meta_fields.json >> .\fos\ks4\data\ks4_sly.json
echo ], >> .\fos\ks4\data\ks4_sly.json
more .\fos\ks4\data\ks4_meta_extra.json >> .\fos\ks4\data\ks4_sly.json
echo "globals":{ >> .\fos\ks4\data\ks4_sly.json
echo "National": >> .\fos\ks4\data\ks4_sly.json
more .\fos\ks4\data\ks4_natavgs.json >> .\fos\ks4\data\ks4_sly.json
echo }, >> .\fos\ks4\data\ks4_sly.json
echo "data":[ >> .\fos\ks4\data\ks4_sly.json
more .\fos\ks4\data\ks4_data.json >> .\fos\ks4\data\ks4_sly.json
echo ]} >> .\fos\ks4\data\ks4_sly.json
