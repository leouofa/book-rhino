# frozen_string_literal: true

require 'ipaddr'
require 'resolv'
require 'base64'
require 'stringio'

module Api
  class ImageAttacher
    class AttachmentError < StandardError; end

    MAX_FILE_SIZE = 25.megabytes
    BLOCKED_IP_RANGES = [
      IPAddr.new('127.0.0.0/8'),
      IPAddr.new('10.0.0.0/8'),
      IPAddr.new('172.16.0.0/12'),
      IPAddr.new('192.168.0.0/16'),
      IPAddr.new('169.254.0.0/16'),
      IPAddr.new('0.0.0.0/8'),
      IPAddr.new('::1'),
      IPAddr.new('fc00::/7'),
      IPAddr.new('fe80::/10')
    ].freeze

    def self.attach!(record, file: nil, image_url: nil, image_base64: nil, filename: nil, content_type: nil)
      new(record).attach!(file: file, image_url: image_url, image_base64: image_base64, filename: filename, content_type: content_type)
    end

    def initialize(record)
      @record = record
    end

    def attach!(file: nil, image_url: nil, image_base64: nil, filename: nil, content_type: nil)
      if file.present?
        attach_uploaded_file(file, filename: filename)
      elsif image_base64.present?
        attach_base64(image_base64, filename: filename, content_type: content_type)
      elsif image_url.present?
        attach_url(image_url, filename: filename)
      else
        raise AttachmentError, 'No image payload provided (file, image_url, or image_base64 required)'
      end
    end

    private

    def attach_uploaded_file(file, filename: nil)
      target_filename = filename.presence || (file.respond_to?(:original_filename) ? file.original_filename : 'uploaded_image.png')
      @record.image.attach(file)
      @record.image.blob.update_columns(filename: target_filename) if filename.present? && @record.image.attached?
      @record
    end

    def attach_base64(data_or_uri, filename: nil, content_type: nil)
      encoded = data_or_uri.to_s
      detected_content_type = content_type

      if encoded =~ /\Adata:([^;]+);base64,(.*)\z/m
        detected_content_type ||= Regexp.last_match(1)
        encoded = Regexp.last_match(2)
      end

      decoded = begin
        Base64.decode64(encoded)
      rescue StandardError => e
        raise AttachmentError, "Invalid base64 payload: #{e.message}"
      end

      if decoded.bytesize > MAX_FILE_SIZE
        raise AttachmentError, "Image exceeds maximum allowed size of #{MAX_FILE_SIZE / 1.megabyte}MB"
      end

      ext = extension_for(detected_content_type)
      target_filename = filename.presence || "image_#{SecureRandom.hex(6)}.#{ext}"
      detected_content_type ||= "image/#{ext}"

      @record.image.attach(
        io: StringIO.new(decoded),
        filename: target_filename,
        content_type: detected_content_type
      )
      @record
    end

    def attach_url(raw_url, filename: nil)
      uri = URI.parse(raw_url.to_s.strip)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        raise AttachmentError, 'Invalid image URL scheme (must be http or https)'
      end

      host = uri.host
      raise AttachmentError, 'Image URL host missing' if host.blank?

      validate_ip_not_private!(host)

      response = HTTParty.get(
        uri.to_s,
        timeout: 10,
        headers: { 'User-Agent' => 'BookRhino/1.0 (+https://bookrhino.app)' }
      )

      unless response.success?
        raise AttachmentError, "Failed to download image from URL (HTTP #{response.code})"
      end

      body = response.body
      if body.bytesize > MAX_FILE_SIZE
        raise AttachmentError, "Remote image exceeds maximum allowed size of #{MAX_FILE_SIZE / 1.megabyte}MB"
      end

      content_type = response.headers['content-type']&.split(';')&.first&.strip
      if content_type.blank? || !content_type.start_with?('image/')
        raise AttachmentError, "Remote URL did not return an image content-type (got '#{content_type}')"
      end

      ext = extension_for(content_type)
      url_filename = File.basename(uri.path)
      target_filename = filename.presence || (url_filename.present? && url_filename.include?('.') ? url_filename : "downloaded_image.#{ext}")

      @record.image.attach(
        io: StringIO.new(body),
        filename: target_filename,
        content_type: content_type
      )
      @record
    end

    def validate_ip_not_private!(host)
      ips = Resolv.getaddresses(host)
      raise AttachmentError, "Could not resolve host: #{host}" if ips.empty?

      ips.each do |ip_str|
        ip = IPAddr.new(ip_str)
        if BLOCKED_IP_RANGES.any? { |range| range.include?(ip) }
          raise AttachmentError, "Access to private/internal network addresses (#{ip_str}) is blocked"
        end
      end
    end

    def extension_for(content_type)
      case content_type
      when 'image/jpeg', 'image/jpg' then 'jpg'
      when 'image/png' then 'png'
      when 'image/gif' then 'gif'
      when 'image/webp' then 'webp'
      when 'image/svg+xml' then 'svg'
      else 'png'
      end
    end
  end
end
