module VCAP

  module Micro

    module_function

    # Run a shell command and raise an exception if its exit status is
    # non-zero.
    #
    # Return its output.
    def shell_raiser(command)
      output = `#{command} 2>&1`
      raise output unless $? == 0

      output
    end

  end

end
