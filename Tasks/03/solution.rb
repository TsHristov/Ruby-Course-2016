module ParseArguments
  def argument?(arg)
    arg if !(option? arg) && !(option_with_parameter? arg)
  end

  def option?(arg)
    arg.chars.take(1) == ['-'] && arg.length == 2 || \
    arg.chars.take(2) == ['-', '-'] && !(arg.chars.include? '=')
  end

  def option_with_parameter?(arg)
    arg.chars.take(1) == ['-'] && arg.length > 2 || \
    arg.chars.take(2) == ['-', '-'] && (arg.chars.include? '=')
  end
end

# Not the best name ever (work in progress)
class Base
  include ParseArguments

  def initialize(block)
    @block = block
  end

  def parse(command_runner, arg)
    @block.call command_runner, arg
  end
end

class Argument < Base
  def initialize(name, block)
    super block
    @name = name
  end

  def parse(command_runner, arg)
    super
  end

  def help
    " [#{@name}]"
  end
end

class Option < Base
  def initialize(short_name, full_name, help, block)
    super block
    @short_name = short_name
    @full_name  = full_name
    @help = help
  end

  def exists?(arg)
    arg.include? ("-#{@short_name}" || "--#{@full_name}")
  end

  def parse(command_runner, arg)
      super command_runner, true if option?(arg) && exists?(arg)
  end

  def help
    "\   -#{@short_name}, --#{@full_name} #{@help}"
  end
end

class OptionWithParameter

  def initialize(short_name, full_name, help, placeholder, block)
    super block
    @short_name = short_name
    @full_name = full_name
    @help = help
    @placeholder = placeholder
  end

  def parse(command_runner, arg)
    super
  end

  def help
    "\    -#{@short_name}, --#{@full_name}"\
    +"=#{@placeholder} #{@help}\n"
  end
end

class CommandParser
  include ParseArguments

  def initialize(command_name)
    @command_name = command_name
    @arguments    = []
  end

  def argument(argument_name, &block)
    @arguments << Argument.new(argument_name, block)
  end

  def option(short_name, full_name, help, &block)
    @arguments << Option.new(short_name, full_name, help, block)
  end

  def option_with_parameter(short_name, full_name, help, placeholder, &block)
    @arguments <<
    OptionWithParameter.new(short_name, full_name, help, placeholder, block)
  end

  def parse(command_runner, argv)
    @arguments.each.zip(argv) do |element, arg|
      element.parse(command_runner, arg)
    end
  end

  def help
    header = "Usage: #{@command_name}"
    @arguments.each do |argument|
      header += "#{argument.help}"
    end
    header
  end
end
