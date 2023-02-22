# CRCPlusPlus
A little utility that transforms text into a PlantUML class diagram source. See this Linkedin article for context: https://www.linkedin.com/pulse/crc-cards-reloaded-markus-voelter

## Prerequisites

This is ruby code. You gotta install Ruby for this to work. You also have to install the `Clipboard` and `pp` gems (as far as I can tell. I am not a Ruby expert at all).

## Running

Type `ruby crc2plantuml.rb <filename>`

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
