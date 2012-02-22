require 'spec_helper' 

describe Vaporize::Config do
  
  describe 'initialize' do
    
    before :each do
      @dir       = mock
      @interval  = mock
      @daemonize = mock
      
      Dir.stub!(:open).with(@dir)
      Vaporize::Config.stub!(:validate_interval)
      Vaporize::Config.stub!(:validate_daemonize)
    end
    
    after :each do
      Vaporize::Config.new({
        :directory => @dir,
        :interval  => @interval,
        :daemonize => @daemonize
      })
    end
    
    it 'should open directory' do
      Dir.should_receive(:open).with(@dir)
    end
    
    it 'should validate interval' do
      Vaporize::Config.should_receive(:validate_interval).with(@interval)
    end
    
    it 'should validate daemonize' do
      Vaporize::Config.should_receive(:validate_daemonize).with(@daemonize)
    end
  end
  
  describe 'validate interval' do
    
    subject { lambda { Vaporize::Config.send(:validate_interval, @interval)  } }
    
    context 'positive' do
      before :each do
        @interval = 5
      end
      
      it { should_not raise_error }
    end
    
    context 'zero' do
      before :each do
        @interval = 0
      end
      
      it { should raise_error }
    end
    
    context 'less than zero' do
      before :each do
        @interval = -5
      end
      
      it { should raise_error }
    end
  end
  
  describe 'validate daemonize' do
    
    subject { Vaporize::Config.send(:validate_daemonize, @daemonize) }
    
    context 'yes' do
      before :each do
        @daemonize = "yes"
      end
      
      it { should be_true }
    end
    
    context 'not yes' do
      before :each do
        @daemonize = "no"
      end
      
      it { should be_false }
    end
  end
end