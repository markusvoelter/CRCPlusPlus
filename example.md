* T: Repository
  * C: stores the [Model]
  * P: Is the central hub to which the other components connect, at least logically
  * Q: Is it really physically a centralized component?
* T: Editor
  * R: interacts with the users
  * P: Can be graphical, textual, projectional, etc.
  * C: Updates the [PrimaryModel] based on user's editing gestures
* T: Processor
  * C: Updates the [PrimaryModel] automatically based on algorithms
  * C: Creates and updates the [DerivedModel] based on algorithms
    * E: Type checkers
    * E: Scope calculators
    * E: Model desugarers
  * R: Can create external artifacts
    * E: generators producing text 
* D: Model {many}
  * P: Consists of nodes and edges typed based on a meta model
  * V: PrimaryModel {many}
    * P: Models that cannot be recomputed from others, always persistet
  * V: DerivedModel {many}
    * P: Models that are derived from other primary or derived models; optionally persisted
    * W: They can be persisted because recomputation can be expensive

