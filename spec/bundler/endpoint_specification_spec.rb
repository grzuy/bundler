# frozen_string_literal: true
require "spec_helper"

describe Bundler::EndpointSpecification do
  let(:name)         { "foo" }
  let(:version)      { "1.0.0" }
  let(:platform)     { Gem::Platform::RUBY }
  let(:dependencies) { [] }
  let(:metadata)     { nil }

  subject { described_class.new(name, version, platform, dependencies, metadata) }

  describe "#build_dependency" do
    let(:name)           { "foo" }
    let(:requirement1)   { "~> 1.1" }
    let(:requirement2)   { ">= 1.1.7" }

    it "should return a Gem::Dependency" do
      expect(subject.send(:build_dependency, name, requirement1, requirement2)).to be_instance_of(Gem::Dependency)
    end

    context "when an ArgumentError occurs" do
      before do
        allow(Gem::Dependency).to receive(:new).with(name, requirement1, requirement2) {
          raise ArgumentError.new("Some error occurred")
        }
      end

      it "should raise the original error" do
        expect { subject.send(:build_dependency, name, requirement1, requirement2) }.to raise_error(
          ArgumentError, "Some error occurred")
      end
    end

    context "when there is an ill formed requirement" do
      before do
        allow(Gem::Dependency).to receive(:new).with(name, requirement1, requirement2) {
          raise ArgumentError.new("Ill-formed requirement [\"#<YAML::Syck::DefaultKey")
        }
        # Eliminate extra line break in rspec output due to `puts` in `#build_dependency`
        allow(subject).to receive(:puts) {}
      end

      it "should raise a Bundler::GemspecError with invalid gemspec message" do
        expect { subject.send(:build_dependency, name, requirement1, requirement2) }.to raise_error(
          Bundler::GemspecError, /Unfortunately, the gem foo \(1\.0\.0\) has an invalid gemspec/)
      end
    end
  end
end
