require 'spec_helper'

module EEE

  describe Scenario do

    describe "#append_call" do

      module TestInterface
        include Methods::Definition

        method :test_method
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
        scenario = EEE::Scenario.new TestInterface
        scenario.append_call :test_method

        http = double('http')
        http.should_receive(:request).and_return(ok_response)

        scenario.send nil, http
      end

      it "appends EEE method calls" do
        scenario = EEE::Scenario.new TestInterface
        scenario.append_call :test_method
        scenario.append_call :test_method

        http = double('http')
        http.should_receive(:request).twice.and_return(ok_response)

        scenario.send nil, http
      end

    end

  end

  module Methods

    describe Call do

      describe "#name" do

        it "returns method name" do
          method_call = Call.new 'ESClient.getServerAttributes', [], nil
          method_call.name.should eq 'ESClient.getServerAttributes'
        end

      end

      describe "#params=" do

        it "translates abstract parameters to XML-RPC paramers" do
          method_call = Call.new 'ESClient.getServerAttributes',
            [ { type: String } ], nil
          method_call.params = ['']

          method_call.xmlrpc_params.should have(1).item
          method_call.xmlrpc_params.first.should eq ''
        end

      end

      describe "#xmlrpc_result=" do
      end

    end

    describe Definition do

      describe "::method" do

        it "creates new module function representing EEE method call" do
          module TestInterface
            include Definition

            method :test_method
          end

          TestInterface.test_method.should be_kind_of Call
        end

        it "defines input parameters of EEE method call in block" do
          module TestInterface
            include Definition

            method :test_method do |m|
              m.in String
            end
          end

          TestInterface.test_method(['']).xmlrpc_params.first.should eq ''
        end

        it "translates Ruby method name to EEE method name" do
          module TestInterface
            include Definition

            method :test_method
          end

          TestInterface.test_method.name.should eq 'ESTestInterface.testMethod'
        end

      end

    end

  end

end
