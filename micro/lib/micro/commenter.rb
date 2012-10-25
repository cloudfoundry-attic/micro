require 'fileutils'
require 'tempfile'

module VCAP

  module Micro

    # Comment and uncomment all lines in a file.
    class Commenter

      def initialize(file_path)
        @file_path = file_path
        @comment_str = '# '
      end

      # Comment out uncommented lines of the file.
      def comment
        if File.exist?(@file_path)
          temp = Tempfile.new('commenter')

          open(file_path).each_line do |line|
            if line[/^#{comment_str}/]
              new_line = line
            else
              new_line = "#{comment_str}#{line}"
            end
            temp.write new_line
          end
          temp.flush
          FileUtils.mv temp.path, file_path
        end
      end

      # Uncomment commented out lines of the file.
      def uncomment
        if File.exist?(file_path)
          temp = Tempfile.new('commenter')

          open(file_path).each_line do |line|
            temp.write(line.sub(/^#{comment_str}/, ''))
          end
          temp.flush
          FileUtils.mv temp.path, file_path
        end

      end

      attr_accessor :comment_str
      attr_accessor :file_path
    end

  end

end
