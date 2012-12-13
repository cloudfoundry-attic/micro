require 'spec_helper'

describe VCAP::Micro::Commenter do

  before(:all) {
    @test_file = Tempfile.new('commenter')
  }

  before(:each) {
    @test_file.truncate(0)
  }

  after(:all) {
    @test_file.unlink
  }

  describe '.comment' do

    context 'file does not exist' do
      it 'does not raise an exception' do
        expect { VCAP::Micro::Commenter.new('/a/b/c/d/e').comment }
          .to_not raise_error
      end
    end

    context 'no lines are commented out' do

      subject {
        @test_file.write("a\nb\nc\n")
        @test_file.flush

        VCAP::Micro::Commenter.new(@test_file.path)
      }

      it 'comments out all the lines' do
        subject.comment
        open(@test_file.path) { |f| f.read }.should == "# a\n# b\n# c\n"
      end

    end

    context 'some lines are commented out' do

      subject {
        @test_file.write("a\n# b\nc\n")
        @test_file.flush

        VCAP::Micro::Commenter.new(@test_file.path)
      }

      it 'comments out all the uncommented lines' do
        subject.comment
        open(@test_file.path) { |f| f.read }.should == "# a\n# b\n# c\n"
      end

    end

  end

  describe '.uncomment' do

    context 'file does not exist' do
      it 'does not raise an exception' do
        expect { VCAP::Micro::Commenter.new('/a/b/c/d/e').uncomment }
          .to_not raise_error
      end
    end

    context 'no lines are commented out' do

      subject {
        @test_file.write("a\nb\nc\n")
        @test_file.flush

        VCAP::Micro::Commenter.new(@test_file.path)
      }

      it 'does nothing' do
        subject.uncomment
        open(@test_file.path) { |f| f.read }.should == "a\nb\nc\n"
      end

    end

    context 'some lines are commented out' do

      subject {
        @test_file.write("a\n# b\nc\n")
        @test_file.flush

        VCAP::Micro::Commenter.new(@test_file.path)
      }

      it 'uncomments all the commented lines' do
        subject.uncomment
        open(@test_file.path) { |f| f.read }.should == "a\nb\nc\n"
      end

    end

  end

end
