require_relative '../../spec_helper'

module EEE

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

      describe "::eee_method" do

        class TestInterface
          include Definition
        end

        def test_interface
          TestInterface.new
        end

        it "creates new module function representing EEE method call" do
          class TestInterface
             eee_method :test_method
          end

          test_interface.test_method.should be_kind_of Call
        end

        it "defines input parameters of EEE method call in block" do
          class TestInterface
            eee_method :test_method do |m|
              m.in String
            end
          end

          test_interface.test_method([''])
            .xmlrpc_params.first.should eq ''
        end

        it "translates Ruby method name to EEE method name" do
          class TestInterface
            eee_method :test_method
          end

          test_interface.test_method
            .name.should eq 'ESTestInterface.testMethod'
        end

      end

    end

  end

end
