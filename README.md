# CRCPlusPlus
A little utility that transforms text into a PlantUML class diagram source. See HERE for the background.

## Running

This is ruby code. You gotta install Ruby for this to work. Then you run

```
ruby crc2plantuml.rb <filename>
``` 

## MD File Structure

At this point I expect the file to be structured like this example:

```
* T: Car
  * R: drives the people
  * E: A mercedes
  * E: An Audi
* T: Engine
  * R: consumes fuel
  * C: propels the [Car]
  * Q: Question
  * W: This is why!
* T: ElectricalEngine
  * S: Engine    
```
