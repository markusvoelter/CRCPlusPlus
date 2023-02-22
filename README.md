# CRCPlusPlus
A little utility that transforms text into a PlantUML class diagram source. See this Linkedin article for context: https://www.linkedin.com/pulse/crc-cards-reloaded-markus-voelter

## Prerequisites

This is ruby code. You gotta install Ruby for this to work. You also have to install the `Clipboard` and `pp` gems (as far as I can tell. I am not a Ruby expert at all).

## Running

Type `ruby crc2plantuml.rb <filename>`

## MD File Structure

At this point I expect the file to be structured like this example:

```
* T: TheFirstType
  * R: A responsibility
    * E: An example for the responsibility
  * E: An example for the Type
  * C: A collaboration with [ASecondType]
  * C: Creates [ADatyType]
* T: ASecondType 
  * R: consumes fuel
  * Q: A Question for ASecondType
  * W: A rationale for ASecondType
  * C: Read [ADatyType]
* D: ADatyType
  * R: stores some stuff
    * E: such as bananas
```

It produces the following class diagram (when the output is processed by PlantUML):

![image](https://user-images.githubusercontent.com/592330/220734258-dab2044e-8170-4ce1-b609-dcde95decac2.png)
