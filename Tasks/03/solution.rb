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

  # def get_arguments(argv)
  #   argv.select { |arg| argument? arg }
  # end
  #
  # def get_options(argv)
  #   argv.select { |arg| option? arg }
  # end
  #
  # def get_options_with_parameter(argv)
  #   argv.select { |arg| option_with_parameter? arg }
  # end
end

class Base
  include ParseArguments

  def initialize(block, **args)
    @block = block
    @args = args
  end

  def parse(command_runner, arg)
    @block.call command_runner, arg
  end

  def attributes
    @args
  end
end

class Argument < Base
  def initialize(name, block)
    super block, name: name
  end

  def parse(command_runner, arg)
    super
  end
end

class Option < Base
  def initialize(short_name, full_name, help, block)
    super block, short_name: short_name, full_name: full_name, help: help
    @short_name = short_name
    @full_name  = full_name
  end

  def exists?(arg)
    arg.include? ("-#{@short_name}" || "--#{@full_name}")
  end

  def parse(command_runner, arg)
      super command_runner, true if option?(arg) && exists?(arg)
  end
end

# class OptionWithParameter
#
#   def initialize(short_name, full_name, help, placeholder, block)
#     super block, short_name: short_name, full_name: full_name, \
#                        help: help, placeholder: placeholder
#     @short_name  = short_name
#     @full_name   = full_name
#     @help        = help
#     @placeholder = placeholder
#     @block       = block
#     p self.attributes
#   end
#
#   def parse(command_runner, arg)
#     super
#   end
# end



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

  # def option_with_parameter(short_name, full_name, help, placeholder, &block)
  #   @arguments <<
  #   OptionWithParameter.new(short_name, full_name, help, placeholder, block)
  # end

  def parse(command_runner, argv)
    @arguments.each.zip(argv) do |element, arg|
      element.parse(command_runner, arg)
    end
  end

  private

  # def argument_attributes
  #   dict = {}
  #   @arguments.select { |element| element.instance_of? Argument }
  #             .each { |arg| dict = arg.attributes }
  #   dict
  # end
  #
  # def option_attributes
  #   dict = {}
  #   @arguments.select { |element| element.instance_of? Option }
  #             .each { |opt| dict = opt.attributes }
  #   dict
  # end
  #
  # def option_with_parameters_attributes
  #   dict = {}
  #   @arguments.select { |element| element.instance_of? OptionWithParameter }
  #             .each { |opt| dict = opt.attributes }
  #   dict
  # end
  #
  # def help
  #   a = argument_attributes
  #   b = option_attributes
  #   c = option_with_parameters_attributes
  #   %(Usage: #{@command_name} [#{a[:name]}]\n\
  #   -#{b[:short_name]}, --#{b[:full_name]} #{b[:help]}\n\
  #   -#{c[:short_name]}, --#{c[:full_name]}=#{c[:placeholder]} #{c[:help]}\n)
  # end
end

parser = CommandParser.new('rspec')

parser.option('v', 'version', 'show version number') do |runner, value|
  runner[:version] = value
end

command_runner = {}
parser.parse(command_runner, ['--version'])

command_runner #=> {version: true}

command_runner = {}
parser.parse(command_runner, ['-v'])

p command_runner #=> {version: true}
