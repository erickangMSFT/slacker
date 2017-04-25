require 'slacker'
require 'spec_helper'
require 'ostruct'

class RSpecSlackerHost
  include Slacker::RSpecExt
end

describe Slacker::RSpecExt do
  before(:each) do
    Slacker::configure do |config|
      config.base_dir = SpecHelper.expand_test_files_path('test_slacker_project')
    end

    example = OpenStruct.new
    example.metadata = {:sql => '', :example_group => {:file_path => SpecHelper.expand_test_files_path('test_slacker_project/spec/example_xyz.rb')}}

    @instance = RSpecSlackerHost.new
    @instance.stub(:example).and_return(example)
  end

  it 'responds to query' do
    @instance.should respond_to(:query)
  end

  it 'responds to match' do
    @instance.should respond_to(:match)
  end

  it 'responds to csv' do
    @instance.should respond_to(:csv)
  end

  it 'responds to load_csv' do
    @instance.should respond_to(:load_csv)
  end

  it 'responds to load_csv' do
    @instance.should respond_to(:touch_csv)
  end

  it 'responds to sql' do
    @instance.should respond_to(:sql)
  end

  context 'responds to ghost methods' do
    before(:each) do
      Slacker.application.stub(:query_script) {|sql| sql}
    end

    specify 'described as SQL files found in the sql/helpers folder' do
      @instance.sql.respond_to?(:helpers).should be true
      @instance.sql.helpers.respond_to?(:helper_1).should be true
      @instance.sql.helpers.helper_1.should == 'helpers/helper_1.sql called'
    end

    specify 'described as SQL.ERB files found in the sql/helpers folder' do
      @instance.sql.helpers.respond_to?(:helper_2).should be true
      @instance.sql.helpers.helper_2.should == 'helpers/helper_2.sql.erb called'
    end

    specify 'with SQL files taking priority over SQL.ERB files' do
      @instance.sql.helpers.respond_to?(:helper_3).should be true
      @instance.sql.helpers.helper_3.should == 'helpers/helper_3.sql called'
    end

    specify 'but ignores non-existing methods' do
      @instance.sql.helpers.respond_to?(:some_bogus_method).should be false
    end

    specify 'but ignores files which are not with SQL or SQL.ERB extension' do
      @instance.sql.helpers.respond_to?(:text_file_1).should be false
    end

    specify 'from folders other than helpers' do
      @instance.sql.respond_to?(:example_1).should be true
      @instance.sql.example_1.respond_to?(:helper_1).should be true
      @instance.sql.example_1.helper_1.should == 'example_1/helper_1.sql called'
    end

    specify "works with deeply nested example files reflecting their location in the lookup of SQL files in the SQL folder" do
      @instance.sql.respond_to?(:nest).should be true
      @instance.sql.nest.respond_to?(:example_1).should be true
      @instance.sql.nest.example_1.respond_to?(:helper_1).should be true
      @instance.sql.nest.example_1.helper_1.should == 'nest/example_1/helper_1.sql.erb called'
    end
  end
end