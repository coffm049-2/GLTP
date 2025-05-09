Lake Ontario TP modeling data
- glerl.noaa.gov/waf/data/loofs_for_epa.tar - NOAA/GLERL data (Kessler and Rowe) 3/13/2024
	- loofs = Lake Ontario Operational Forecast
	- See README within for description of all files included
- Converted spherical to cartesian (see files in conversionFunctions)
- Converted WRF to FVCOM grid

```bash
/work/GLHABS/LakeOntario/shared/WRF2FVCOM/wrf2fvcom \
-i /work/GLHABS/LakeOntario/shared/loofs_for_epa/forcing/loofs_met_2018_06.nc \
-o /work/GLHABS/LakeOntario/shared/loofs_for_epa/forcing/loofs_met_2018_06_FVCOM.nc \
-v 4.0
```


## River inputs
- Taken from Wilson EFDC model
	- /work/GLFBREEZ/Lake_Ontario/River_Loads/2018
	- bigger rivers have daily values
	- smaller rivers have same value every day

## other sources

-	Lake_Ontario_Extracted_Flows_2013.xlsx    This file contains 7 rivers including the two St Lawrence outflows.  River flow data are stored in separate tabs.  Data was extracted from this file     EFDC_intflw.bin

-	Lake_Ontario_Extracted_Flows_2018.xlsx   This file contains 9 rivers including the two St Lawrence outflows plus the Salmon and Black rivers.  River flow data are stored in separate tabs.  Data was extracted from this file     EFDC_intflw.bin

Comments:
-	Flows are units of m3/s.
-	Flows are specified for each vertical layer.  There are a total of 10 layers.
-	Add up the flow of each vertical layer to obtain a total flow for a given record.
-	There are no timestamps associated with the data although I think flow data start on April 1st. 
-	The column labeled “Record” is the record number of each data entry.  It is just a counter.
-	I have the suspicion the output frequency of the data is 6 hours or so, but I could be wrong.
-	Not sure how similar this extracted flow data is to the one in qser.inp.  I think they should be similar but this will have to be confirmed.
-	The EFDC_intflw.bin file is read in by the water qualtiy model. 


#    USGS 04264331 ST. LAWRENCE R AT CORNWALL ONT NR MASSENA NY
- https://waterdata.usgs.gov/nwis/dv?referred_module=sw&site_no=04264331
- cubic feet per second