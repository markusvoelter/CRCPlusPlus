require 'pp'
require 'clipboard'

class Node
  attr_accessor :parent, :indent, :value, :children, :cat, :text

  def initialize(parent, indent, value)
    @indent = indent 
    @parent = parent
    @value = value
    @children = []
    @cat = ""
    @text = ""
  end

  def childrenOfCat(cat) 
    @children.select{|n| n.cat == cat}
  end
end

def build_tree(lines, parent)
  if lines.empty? then return end
  line = lines[0]
  rest = lines.drop(1)

  indent_level = line[/^\s*/].size
  line_value = line.strip

  if indent_level == parent.indent
    newNode = Node.new(parent.parent, indent_level, line_value)
    parent.parent.children << newNode
    build_tree(rest, newNode)
  elsif indent_level > parent.indent
    newNode = Node.new(parent, indent_level, line_value)
    parent.children << newNode
    build_tree(rest, newNode)
  else
    build_tree(lines, parent.parent)
  end
end

def extract_text(node)
  match = /([A-Z]):(.*)$/.match(node.value)
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
  result << current_line.strip if current_line.length > 0
  result.join("\\n")
end

def extractStructure(node)
  extract_text(node)
  node.children.each do |child|
    extractStructure(child)
  end
end

def createPlantUML(result, node)
  if !node then return end
  if !node.value then return end
  if node.cat == "T" || node.cat == "D"
    if node.cat == "T"
      result << "class " << node.text << " {\n"
    else 
      result << "class " << node.text << "<<data>>" << " {\n"
    end
    node.childrenOfCat("R").each do |r|
      result << "-- Responsibility --\n"
      result << "  " << splitString(r.text, 50) << "\n"
      r.childrenOfCat("E").each do |e|
        result << "  E: " << splitString(e.text, 50) << "\n"
      end 
    end 
    if node.childrenOfCat("E").size > 0 
      node.childrenOfCat("E").each do |child|
        result << "-- Example --\n"
        result << "  * " << splitString(child.text, 50) << "\n"
      end 
    end
    result << "}\n"
    node.childrenOfCat("Q").each do |child|
      result << "note top of " << node.text << " : (Question) " << splitString(child.text) << "\n"
    end 
    node.childrenOfCat("W").each do |child|
      result << "note right of " << node.text << " : (Rationale) " << splitString(child.text) << "\n"
    end 
    node.childrenOfCat("C").each do |child|
      target = child.text.scan(/\[(.*?)\]/).flatten.first
      text = child.text.gsub(/\[|\]/, '')
      result << node.text << " --> " << target << " : " << splitString(text, 25) << "\n"
    end 
  end
  if node.cat == "S"
    result << node.text << " <|-- " << node.parent.text
  end
  node.children.each do |child|
    createPlantUML(result, child)
  end 
end



def printtree(node, indent)
  print indent
  print node.value
  print "\n"
  node.children.each do |child|
    printtree(child, indent + "  ")
  end 
end

lines = File.readlines(ARGV[0])
root = Node.new(nil, -1, "X: ROOT")
build_tree(lines, root)
extractStructure(root)
result = ""
result << "@startuml\n"
result << "skinparam class {\n"
result << "  BackgroundColor<<data>> PaleGreen\n"
result << "  ArrowColor #222222\n"
result << "  BorderColor #222222\n"
result << "}\n"
result << "hide circles\n"
result << "\n"
root.children.select{|n| n.cat == "T" || n.cat == "D"}.each do |child|
  createPlantUML(result, child)
end 
result << "@enduml\n"

Clipboard.copy(result)
puts "plantuml sources copied to clipboard."