require 'pp'
require 'clipboard'

$inputFileName = ARGV[0]
$outputFileName = $inputFileName + ".plantuml"
$includeNotes = true
$shortCollab = false
if ARGV.include?("-nonotes")
  $includeNotes = false
end
if ARGV.include?("-collabShortcut")
  $shortCollab = true
end

class Node
  attr_accessor :parent, :indent, :value, :children, :cat, :text, :many

  def initialize(parent, indent, value)
    @indent = indent 
    @parent = parent
    @value = value
    @children = []
    @cat = ""
    @text = ""
    @many = false
  end

  def childrenOfCat(cat) 
    @children.select{|n| n.cat == cat}
  end

  def childrenOfCatDo(cat, result, fun) 
    for x in childrenOfCat(cat)
      result << fun.call(x) << "\n"
    end
  end
  def childrenOfCatDoHeader(header, cat, result, fun) 
    if childrenOfCat(cat).size > 0 
      result << "-- " + header + " --\n"
      for x in childrenOfCat(cat)
        result << fun.call(x) << "\n"
      end
    end
  end
end

def buildTree(lines, parent)
  if lines.empty? then return end
  line = lines[0]
  rest = lines.drop(1)

  indent_level = line[/^\s*/].size
  line_value = line.strip

  if indent_level == parent.indent
    newNode = Node.new(parent.parent, indent_level, line_value)
    parent.parent.children << newNode
    buildTree(rest, newNode)
  elsif indent_level > parent.indent
    newNode = Node.new(parent, indent_level, line_value)
    parent.children << newNode
    buildTree(rest, newNode)
  else
    buildTree(lines, parent.parent)
  end
end

def extractText(node)
  s = node.value
  if s.include?("{many}")
    node.many = true
    s.gsub!("{many}", "")
  end
  match = /([A-Z]):(.*)$/.match(s)
  if match
    node.cat = match[1].strip
    node.text = match[2].strip
  end
end

def splitString(str, len = 35)
  result = []
  current_line = ''
  str.split(' ').each do |word|
    if current_line.length + word.length > len
      result << current_line.strip
      current_line = ''
    end
    current_line += word + ' '
  end
  current_line = current_line.gsub(/\[(.*?)\]/, '<b>\1</b>')
  result << current_line.strip if current_line.length > 0
  result.join("\\n")
end

def extractStructure(node)
  extractText(node)
  node.children.each do |child|
    extractStructure(child)
  end
end

def printTree(node, indent)
  print indent
  print node.value
  print "\n"
  node.children.each do |child|
    printTree(child, indent + "  ")
  end 
end

def isToplevel(node) 
  return node.cat == "T" || node.cat == "D" || node.cat == "X" || node.cat == "M"
end

def processTypeNode(result, node, overridingCategory = nil)
  many = ""
  if node.many then many = " [*]" end
  fullLabel = node.text
  shortLabel = fullLabel
  if shortLabel.include?("::")
    shortLabel = shortLabel.split("::").last
  end
  title = "\"<b><size:16>" + shortLabel + many + "</size></b>\" as " + fullLabel + " "
  cat = node.cat
  if overridingCategory != nil then cat = overridingCategory end
  if cat == "T"
    result << "class " << title << " {\n"
  elsif cat == "D" 
    result << "class " << title << "<<data>>" << " {\n"
  elsif cat == "M" 
    result << "class " << title << "<<model>>" << " {\n"
  else
    result << "circle " << node.text << "\n"
  end
  if node.childrenOfCat("P").size > 0 
    result << "-- Properties --\n"
    for r in node.childrenOfCat("P")
      result << "  <b>[P]</b> " << splitString(r.text, 50) << "\n"
      r.childrenOfCatDo("E", result, lambda {|c| "  :::<b>[E]</b> " + splitString(c.text, 50) })
      r.childrenOfCatDo("W", result, lambda {|c| "  :::<b>[W]</b> " + splitString(c.text, 50) })
    end 
  end
  if node.childrenOfCat("R").size > 0 
    result << "-- Responsibilities --\n"
    for r in node.childrenOfCat("R")
      result << "  <b>[R]</b> " << splitString(r.text, 50) << "\n"
      r.childrenOfCatDo("E", result, lambda {|c| "  :::<b>[E]</b> " + splitString(c.text, 50) })
      r.childrenOfCatDo("W", result, lambda {|c| "  :::<b>[W]</b> " + splitString(c.text, 50) })
    end
  end 
  node.childrenOfCatDoHeader("Examples", "E", result, lambda {|c| "  <b>[E]</b> " + splitString(c.text, 50) })
  if cat != "X"
    result << "}\n"
  end
  if $includeNotes == true
    node.childrenOfCatDo("Q", result, lambda {|c| "note top of " << node.text << " : <b>[Q]</b> " << splitString(c.text) })
    node.childrenOfCatDo("W", result, lambda {|c| "note top of " << node.text << " : <b>[W]</b> " << splitString(c.text) })
  end
  node.childrenOfCat("C").each do |child|
    target = child.text.scan(/\[(.*?)\]/).flatten.first
    if $shortCollab
      text = child.text.gsub(/\[(.*?)\]/, '$')
      if text.end_with?("$")
        text = text.chop
      end
    else
      text = child.text.gsub(/\[|\]/, '')
    end
    result << node.text << " --> " << target << " : " << splitString(text, 25) << "\n"
  end 
  node.childrenOfCat("V").each do |child|
    processTypeNode(result, child, cat)
    result << node.text << " <|-- " << child.text << "\n"
  end 

end



def createPlantUML(result, node)
  if !node then return end
  if !node.value then return end
  if isToplevel(node)
    processTypeNode(result, node)
  end
  node.children.each do |child|
    createPlantUML(result, child)
  end 
  
end




lines = File.readlines($inputFileName)


root = Node.new(nil, -1, "X: ROOT")
buildTree(lines, root)
extractStructure(root)
result = ""
result << "@startuml\n"
result << "skinparam class {\n"
result << "  BackgroundColor #e5f4f9\n"
result << "  BackgroundColor<<data>> #8dc6d9\n"
result << "  BackgroundColor<<model>> #9ffec3\n"
result << "  BackgroundColor<<proxy>> #8dc6d9\n"
result << "  ArrowColor #003233\n"
result << "  BorderColor #003233\n"
result << "  ArrowThickness 1.5\n"
result << "  BorderThickness 1.5\n"
result << "  FontColor #003233\n"
result << "}\n"
result << "skinparam linetype polyline\n"
result << "skinparam groupInheritance 2\n"
result << "hide circles\n"
result << "hide stereotype\n"
result << "set separator ::\n"
result << "\n"
root.children.select{|n| isToplevel(n) }.each do |child|
  createPlantUML(result, child)
end 
result << "@enduml\n"

Clipboard.copy(result)
puts "PlantUML sources copied to clipboard; paste them into the demo server at https://www.plantuml.com/plantuml/uml/"
File.write($outputFileName, result)
puts "PlantUML sources written to " + $outputFileName
