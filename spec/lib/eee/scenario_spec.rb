require_relative '../../spec_helper'

module EEE

  describe Scenario do

    describe "#append_call" do

      class TestInterface
        include Methods::Definition

        eee_method :test_method
      end

      def ok_response
        response = double('ok_response')
        response.stub(:code).and_return(200)
        response.stub(:[]).and_return('text/xml')
        response.stub(:body).and_return(
          '<methodResponse><params><param/></params></methodResponse>'
        )

        response
      end

      it "sends appended EEE method calls to the server" do
        scenario = EEE::Scenario.new TestInterface.new
        scenario.append_call :test_method

        http = double('http')
        http.should_receive(:request).and_return(ok_response)

        scenario.send nil, http
      end

      it "appends EEE method calls" do
        scenario = EEE::Scenario.new TestInterface.new
        scenario.append_call :test_method
        scenario.append_call :test_method

        http = double('http')
        http.should_receive(:request).twice.and_return(ok_response)

        scenario.send nil, http
      end

    end

  end

end
