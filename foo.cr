require "compiler/crystal/syntax"

include Crystal

parser = Parser.new(File.read(ARGV.first))
  # def foo(maybe)
  #   if maybe
  #     true
  #   else
  #     false
  #   end
  # end
# "

nodes = parser.parse

puts "Before:"
puts nodes

class FlipConditionTransformer < Transformer
  def transform(node : If)
    tmp = node.else
    node.else = node.then
    node.then = tmp
    node
  end
end

transformed = nodes.transform(FlipConditionTransformer.new)

puts "After:"
puts transformed
