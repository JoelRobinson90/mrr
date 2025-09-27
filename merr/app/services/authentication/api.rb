# typed: true
# frozen_string_literal: true

require "rest-client"

module Authentication
  class Api
    attr_reader :broker

    def initialize(broker)
      @broker = broker
    end

    def get(path, params = {}, timeout = 10)
      request(:get, path, params, timeout = timeout)
    end

    def post(path, body, timeout = 10)
      request(:post, path, body, timeout = timeout)
    end

    def put(path, body, timeout = 10)
      request(:put, path, body, timeout = timeout)
    end

    def delete(path, body = {}, timeout = 10)
      request(:delete, path, body, timeout = timeout)
    end

    def file_upload(url, file)
      return unless token

      result = begin
        RestClient.post(url, {file: file}, @broker.headers(:post))
      rescue RestClient::ExceptionWithResponse => e
        e.response
      end

      response(result)
    end

    private

    def response(result)
      OpenStruct.new({success?: result.code.in?([200, 201, 204]),
                      body:     result.body,
                      code:     result.code})
    rescue StandardError => e
      Sentry.capture_exception(e)
      OpenStruct.new({success?: false, error: e.message})
    end

    def request(method, path, body = {}, _timeout = 10)
      Rails.logger.error(path)
      Rails.logger.error(method)
      Rails.logger.error("Body#{body}")
      unless @broker.required_authentication_fufilled?
        return OpenStruct.new({success?: false, body: "Authentication missing",
                               code: ""})
      end
      url ||= [@broker.base_url, path].join("/")

      t = Time.now

      result = begin
        case method
        when :get
          url += "?#{body.to_query}" if body.present?
          RestClient.get(url, @broker.headers(method))
        when :delete
          url += "?#{body.to_query}" if body.present?
          RestClient.delete(url, @broker.headers(method))
        else
          headers = @broker.headers(method)
          enc_body = headers[:content_type].include?("json") ? body.to_json : body

          RestClient.send(method, url, enc_body, headers)
        end
      rescue RestClient::ExceptionWithResponse => e
        e.response
      end
      run_id = @run_id.present? ? " (run_id: #{@run_id})" : ""
      p "#{sprintf('%.3f', Time.now - t)} seconds to #{method.upcase} #{url}#{run_id}"
      response(result)
    end
  end
end
