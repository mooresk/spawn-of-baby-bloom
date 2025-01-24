README.txt - Hints for using SCS data from FSVs

The SCS data from sensors on the Shimada are raw. There will be instances where the data will be dropped or end up with a value you don't expect. If you want to do any averaging over the dataset, it would be wise to clean it up first.

I have taken chunks out that I want to use and plot it to view the outliers. I would suggest doing something like that for all sensors, including the GPS. I found a couple of bad data points this year in both the derived lat and lon.

Other hints:
	- The filenames for the sensor information are organized by date (YYYYMMDDTHHMMSSZ) followed by a message about what the sensor is
	- Event Data: here is what is recorded when a 'button' is pressed in SCS to denote an event has happened. For our survey, that includes things like our trawl events, starting and ending transects, ctd and uctd deployments, etc.
	- GPS: I tend to use the derived lat and derived lon files for this
	- TSG: After talking with various survey techs over the years, I use the TSG21-SBE38 sensor
	
Good luck, and let me know if you have any other questions!