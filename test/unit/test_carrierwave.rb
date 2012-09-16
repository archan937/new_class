require File.expand_path("../../test_helper", __FILE__)

require "carrierwave/orm/activerecord"

CarrierWave.root = File.expand_path("../test_carrierwave", __FILE__)
ActiveRecord::Base.logger = nil
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
ActiveRecord::Schema.define do
  create_table :users do |table|
    table.column :avatar, :string
  end
end

module Unit
  class TestCarrierWave < MiniTest::Unit::TestCase

    describe "A variable dependent CarrierWave Uploader class" do
      before do
        class Uploader < CarrierWave::Uploader::Base
          include NewClass

          def self.defined
            include config[:processor]
            storage config[:storage]

            config[:versions].each do |v|
              case v.class.name
              when "Array"
                process :resize_to_fit => v
              when "Hash"
                version v.keys.first do
                  process :resize_to_fit => v.values.first
                end
              end
            end
          end

          def store_dir
            "uploads/#{model.class.name.match(/[^:]+$/).to_s.underscore}/#{mounted_as}/#{model.id}"
          end

          def cache_dir
            "tmp"
          end

          def extension_white_list
            config[:extension_white_list]
          end
        end

        @Uploader = Uploader.new_class({
          :config => {
            :processor => CarrierWave::RMagick,
            :storage => :file,
            :versions => [[800, 800], {:thumb => [200, 200]}, {:icon => [100, 100]}],
            :extension_white_list => %w(jpg jpeg gif png)
          }
        })
      end

      it "should have respond to image processing methods" do
        assert @Uploader.respond_to?(:resize_to_fill)
        assert @Uploader.respond_to?(:resize_to_fit)
      end

      it "should have the expected storage" do
        assert_equal CarrierWave::Storage::File, @Uploader.storage
      end

      describe "used within an ActiveRecord::Base class" do
        before do
          class User < ActiveRecord::Base; end
          User.mount_uploader :avatar, @Uploader
          @user = User.new
          @user.avatar = File.open(File.expand_path("../test_carrierwave/archan937.png", __FILE__))
        end

        after do
          FileUtils.rm_rf File.expand_path("../test_carrierwave/uploads", __FILE__)
          FileUtils.rm_rf File.expand_path("../test_carrierwave/tmp", __FILE__)
        end

        it "should have the expected cache urls" do
          assert @user.avatar.url.match(/\/tmp\/[^\/]+\/archan937.png/)
          assert @user.avatar.thumb.url.match(/\/tmp\/[^\/]+\/thumb_archan937.png/)
          assert @user.avatar.icon.url.match(/\/tmp\/[^\/]+\/icon_archan937.png/)
        end

        it "should have the expected store urls" do
          @user.save
          assert @user.avatar.url.match(/\/uploads\/user\/avatar\/1\/archan937.png/)
          assert @user.avatar.thumb.url.match(/\/uploads\/user\/avatar\/1\/thumb_archan937.png/)
          assert @user.avatar.icon.url.match(/\/uploads\/user\/avatar\/1\/icon_archan937.png/)
        end

        it "should have the expected versions" do
          assert_equal(%w(icon thumb), @Uploader.versions.keys.collect(&:to_s).sort)
        end

        it "should have the expected extension white list" do
          assert_equal %w(jpg jpeg gif png), @user.avatar.extension_white_list
        end
      end
    end

  end
end