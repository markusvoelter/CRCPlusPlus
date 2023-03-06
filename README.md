# CRC++

A little utility that transforms text into a PlantUML class diagram source. See this Linkedin article for context: https://www.linkedin.com/pulse/crc-cards-reloaded-markus-voelter

## Prerequisites

This is ruby code. You gotta install Ruby for this to work. You also have to install the `Clipboard` and `pp` gems (as far as I can tell. I am not a Ruby expert at all).

## Running

Type `ruby crc2plantuml.rb <filename>`

You can add an optional second argument `-nonotes` to suppress rendering of the notes in the diagram. 

## MD File Structure

At this point I expect the file to be structured like this example:

```
* T: TheFirstType
  * R: A responsibility
    * E: An example for the responsibility
  * E: An example for the Type
  * C: A collaboration with [Package::ASecondType]
  * C: Creates [ADataType]
* T: Package::ASecondType 
  * R: consumes fuel
  * Q: A Question for ASecondType
  * W: A rationale for ASecondType
  * C: Read [ADataType]
  * V: Package::ASecondTypeBla
    * R: it does other stuff
    * C: Reads and writes [ADataType]
* D: ADataType {many}
  * R: stores some stuff
    * E: such as bananas
* X: SomethingFromSomewhere
```

It produces the following class diagram (when the output is processed by PlantUML):

![image](https://user-images.githubusercontent.com/592330/221001868-59c4ada1-2d44-42b4-b418-d804cde80563.png)
  * W: A rationale for ASecondType
