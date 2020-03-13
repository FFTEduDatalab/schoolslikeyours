D:\Tools\clean.exe .\fos\special\data\special_data.dat .\fos\special\data\special_data.json --export --json
echo {"meta":[ > .\fos\special\data\special_sly.json
more .\fos\special\data\special_meta_fields.json >> .\fos\special\data\special_sly.json
echo ], >> .\fos\special\data\special_sly.json
more .\fos\special\data\special_meta_extra.json >> .\fos\special\data\special_sly.json
echo "data":[ >> .\fos\special\data\special_sly.json
more .\fos\special\data\special_data.json >> .\fos\special\data\special_sly.json
echo ]} >> .\fos\special\data\special_sly.json
