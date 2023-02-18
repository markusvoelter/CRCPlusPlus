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


def extractStructure(node)
  extract_text(node)
  node.children.each do |child|
    extractStructure(child)
  end
end

def createPlantUML(result, node)
  if !node then return end
  if !node.value then return end
  case node.cat
  when "T"
    result << "class " << node.text << " {\n"
    node.childrenOfCat("R").each do |child|
      result << "  " << child.text << "\n"
    end 
    if node.childrenOfCat("E").size > 0 
      result << "  ==\n"
      result << "  Examples:\n"
      node.childrenOfCat("E").each do |child|
        result << "  * " << child.text << "\n"
      end 
    end
    result << "}\n"
    node.childrenOfCat("Q").each do |child|
      result << "note top of " << node.text << " : (Question) " << child.text << "\n"
    end 
    node.childrenOfCat("W").each do |child|
      result << "note right of " << node.text << " : (Rationale) " << child.text << "\n"
    end 
    node.childrenOfCat("C").each do |child|
      target = child.text.scan(/\[(.*?)\]/).flatten.first
      text = child.text.gsub(/\[|\]/, '')
      result << node.text << " --> " << target << " : " << text << "\n"
    end 
  when "S"
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
root.children.select{|n| n.cat == "T"}.each do |child|
  createPlantUML(result, child)
end 
result << "@enduml\n"

Clipboard.copy(result)
puts "plantuml sources copied to clipboard."