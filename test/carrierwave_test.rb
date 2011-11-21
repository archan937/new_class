require File.expand_path("../test_helper", __FILE__)

class CarrierWaveTest < Test::Unit::TestCase

  context "A variable dependent CarrierWave Uploader class" do
    setup do
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
          "uploads" # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end

        def extension_white_list
          config[:extension_white_list]
        end
      end

      @MagickUploader = Uploader.new_class :config => {
        :processor => CarrierWave::RMagick,
        :storage => :file,
        :versions => [[800, 800], {:thumb => [200, 200]}, {:icon => [100, 100]}],
        :extension_white_list => %w(jpg jpeg gif png)
      }
      @magick_uploader = @MagickUploader.new

      # @magick_uploader.store! File.open(File.expand_path("../carrierwave_test/archan937.png", __FILE__))
    end

    should "have respond to image processing methods" do
      assert @MagickUploader.respond_to?(:resize_to_fill)
      assert @MagickUploader.respond_to?(:resize_to_fit)
    end

    should "have the expected storage" do
      assert_equal CarrierWave::Storage::File, @MagickUploader.storage
    end

    # should "have the expected urls" do
    #   assert_equal [], @magick_uploader.url
    #   assert_equal [], @magick_uploader.thumb.url
    #   assert_equal [], @magick_uploader.icon.url
    # end
    #
    # should "have the expected versions" do
    #   assert_equal [], @magick_uploader.versions
    # end

    should "have the expected extension white list" do
      assert_equal %w(jpg jpeg gif png), @magick_uploader.extension_white_list
    end
  end

end