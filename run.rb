$: << File.dirname(__FILE__)
require 'urm'
require 'treetop'
URMParser = Treetop.load('urm')
parser = URMParser.new
text = File.read(ARGV[0])
program = parser.parse(text).to_ast
args = ARGV[1..-1].map(&:to_i)
Evaluator.evaluate(args, program)
