# VD data pipeline

Code to create tabular versions of the [VD17](http://www.vd17.de/) and [VD18](http://www.vd18.de/) bibliographic databases.

## Runnning the pipeline

Install Python dependencies using your favourite method. Then, just run `make -j`. This will:

1. Download the VD17 and VD18 data from the respective websites.
2. Download authority data referred to from the VD17 and VD18 data (along with a few additional GND ids) from the [GND](https://www.dnb.de/EN/Professionell/Standardisierung/GND/gnd_node.html).
3. Convert the downloaded data into Parquet and TSV formats using [bibxml2](https://github.com/hsci-r/bibxml2).
