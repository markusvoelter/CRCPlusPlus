# CRC++

A little utility that transforms text into a PlantUML class diagram source. See this Linkedin article for context: https://www.linkedin.com/pulse/crc-cards-reloaded-markus-voelter

## Prerequisites

This is ruby code. You gotta install Ruby for this to work. You also have to install the `Clipboard` and `pp` gems (as far as I can tell. I am not a Ruby expert at all).

## Running

Type `ruby crc2plantuml.rb <filename>`

There are two additional parameters which you can put in any order after the `<filename>`:
* `-nonotes` to suppresses rendering of the notes in the diagram. 
* `-shortCollab` uses a shorter notation on the collaboration arrows by replacing the name of the target with a `$`

## MD File Structure

At this point I expect the file to be structured like this example:

```
* T: TheFirstType
  * R: A responsibility for [TheFirstType]
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
* X: SomethingFromSomewhere
* D: ADataType {many}
  * C: also does something with [SomethingFromSomewhere]
  * R: stores some stuff
    * E: such as bananas
```

It produces the following class diagram (when the output is processed by PlantUML):

![image](https://user-images.githubusercontent.com/592330/223161398-6c1101ec-7283-4065-b866-c78ddca52a95.png)

Here is the alternative rendering with both additional parameters specified:

![image](https://user-images.githubusercontent.com/592330/223166304-5952714b-c16c-46e6-b681-e9cb15276e9d.png)
