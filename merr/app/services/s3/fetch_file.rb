# typed: true
# frozen_string_literal: true

module S3
  class FetchFile
    def initialize
      @secret_key = EnvHelper.env_or_error("ALAYACARE_SECRET_ACCESS_KEY")
      @access_key = EnvHelper.env_or_error("ALAYACARE_ACCESS_KEY_ID")
      @aws_reigon = EnvHelper.env_or_error("ALAYACARE_AWS_REGION")
      @bucket = EnvHelper.env_or_error("ALAYACARE_S3_BUCKET")
      @folder = EnvHelper.env_or_error("ALAYACARE_S3_FOLDER")
    end

    def client
      @client ||= Aws::S3::Client.new(
        access_key_id:     @access_key,
        secret_access_key: @secret_key,
        region:            @aws_reigon
      )
    end

    def fetch(bucket, key)
      resp = @client.get_object(bucket: bucket, key: key)
      resp.body # StringIO
    end

    def list_files
      @list_files ||= client.list_objects_v2(
        {
          bucket: @bucket,
          prefix: @fodler
        }
      ).contents.collect(&:key).select {|name| name.split(".").last.downcase == "csv" }
    end
  end
end
