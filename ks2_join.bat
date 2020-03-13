D:\Tools\clean.exe .\fos\ks2\data\ks2_data.dat .\fos\ks2\data\ks2_data.json --export --json
echo {"meta":[ > .\fos\ks2\data\ks2_sly.json
more .\fos\ks2\data\ks2_meta_fields.json >> .\fos\ks2\data\ks2_sly.json
echo ], >> .\fos\ks2\data\ks2_sly.json
more .\fos\ks2\data\ks2_meta_extra.json >> .\fos\ks2\data\ks2_sly.json
echo "globals":{ >> .\fos\ks2\data\ks2_sly.json
echo "National": >> .\fos\ks2\data\ks2_sly.json
more .\fos\ks2\data\ks2_natavgs.json >> .\fos\ks2\data\ks2_sly.json
echo }, >> .\fos\ks2\data\ks2_sly.json
echo "data":[ >> .\fos\ks2\data\ks2_sly.json
more .\fos\ks2\data\ks2_data.json >> .\fos\ks2\data\ks2_sly.json
echo ]} >> .\fos\ks2\data\ks2_sly.json
