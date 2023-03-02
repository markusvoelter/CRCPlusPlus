* T: TheFirstType
  * R: A responsibility
    * E: An example for the responsibility
  * E: An example for the Type
  * C: A collaboration with [ASecondType]
  * C: Creates [ADataType]
* T: Package::ASecondType 
  * R: consumes fuel
  * Q: A Question for ASecondType
  * W: A rationale for ASecondType
  * C: Read [ADataType]
  * V: Package::ASecondTypeBla
    * R: it does other stuff
    * C: Reads and writes [ADataType]
* D: ADataType
  * R: stores some stuff
    * E: such as apples
