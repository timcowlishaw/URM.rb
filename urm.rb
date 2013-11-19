require 'values'
require 'hamster/vector'

class Concatenate < Value.new(:expression, :rest)
  def evaluate(environment, step=environment.instruction_pointer)
    if step == 0
      environment_2 = expression.evaluate(environment)
      Environment.new(
        environment_2.instruction_pointer + 1,
        environment_2.registers
      )
    else
      rest.evaluate(environment, step-1)
    end
  end

  def steps
    1 + rest.steps
  end

  def referenced
    expression.referenced + rest.referenced
  end
end

class Empty
  def evaluate(environment, step=environment.instruction_pointer)
    environment
  end

  def steps
    0
  end

  def referenced
    []
  end
end

class Zero < Value.new(:register)
  def evaluate(environment)
    Environment.new(
      environment.instruction_pointer,
      environment.registers.set(register.index, 0)
    )
  end

  def referenced
    [register]
  end
end

class Successor < Value.new(:register)
  def evaluate(environment)
    current = environment.registers.get(register.index)
    Environment.new(
      environment.instruction_pointer,
      environment.registers.set(register.index, current + 1)
    )
  end

  def referenced
    [register]
  end
end

class Copy < Value.new(:from, :to)
  def evaluate(environment)
    value = environment.registers.get(from.index)
      Environment.new(
        environment.instruction_pointer,
        environment.registers.set(to.index, value)
      )
  end

  def referenced
    [from, to]
  end
end

class Jump < Value.new(:left, :right, :pointer)
  def evaluate(environment)
    leftV = environment.registers.get(left.index)
    rightV = environment.registers.get(right.index)
    leftV == rightV ? Environment.new(pointer.instruction - 2, environment.registers) : environment
  end

  def referenced
    [left, right]
  end
end

class Identifier
  def initialize(register)
    @register = register.to_i
    freeze
  end
  attr_reader :register

  def index
    register - 1
  end

  def referenced
    [register]
  end
end

class InstructionPointer
  def initialize(instruction)
    @instruction = instruction.to_i
    freeze
  end
  attr_reader :instruction
end

class Environment

  def initialize(instruction_pointer=0, registers=nil)
    registers ||= Hamster.vector(*([0] * REGISTERS))
    @instruction_pointer = instruction_pointer
    @registers = registers
    @registers.freeze
    freeze
  end

  def result
    registers.get(0)
  end

  def inspect
    "#{instruction_pointer+1}: #{registers.to_a.join(",")}"
  end

  attr_reader :instruction_pointer, :registers
end

class Evaluator
  def self.evaluate(args, program)
    n_registers = program.referenced.map(&:index).max + 1
    registers = Hamster.vector(*(args + [0] * (n_registers - args.length)))
    environment = Environment.new(0, registers)

    while environment.instruction_pointer < program.steps
      puts environment.inspect
      environment = program.evaluate(environment)
    end

    puts environment.inspect
    environment
  end
end
