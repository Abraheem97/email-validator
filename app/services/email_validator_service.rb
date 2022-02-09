class EmailValidatorService
  include HTTParty
  base_uri 'http://apilayer.net/api'.freeze
  attr_reader :first_name, :last_name, :url

  def initialize(first_name, last_name, url)
    @first_name = first_name
    @last_name = last_name
    @url = url
    @options = {
      query: { access_key: ENV["MAILBOX_ACCESS_TOKEN"]}
    }
  end

  def call
    return if url.empty?

    validated_email = ""
    addresses.each do |address|
      @options[:query].merge!(email: address)
      response = self.class.get('/check', @options)
      if response.parsed_response.values_at("format_valid", "mx_found", "smtp_check", "catch_all") == [true, true, true, false]
        return address
      end
    end
    validated_email
  end

  def addresses
    p1 = first_name + '@' + url

    # bobsmith@url.com
    p2 = first_name + last_name + '@' + url

    # bob.smith@url.com
    p3 = first_name + '.' + last_name + '@' + url

    # smith@url.com
    p4 = last_name + '@' + url

    # bsmith@url.com
    p5 = first_name[0] + last_name + '@' + url

    # b.smith@url.com
    p6 = first_name[0] + '.' + last_name + '@' + url

    # bobs@url.com
    p7 = first_name + last_name[0] + '@' + url

    # bob.s@url.com
    p8 = first_name + '.' + last_name[0] + '@' + url

    # bs@url.com
    p9 = first_name[0] + last_name[0] + '@' + url

    addresses = [p1, p2, p3, p4, p5, p6, p7, p8, p9]
  end
end
