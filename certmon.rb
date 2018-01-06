require 'httpclient'
require 'json'
require 'pry'

urllist = ARGV[0]
days = ARGV[1]

$VERBOSE = nil

if urllist.nil? or days.nil?
    puts "This tool requires 2 parameters: <url_list_file> <days>"
    raise
end

module CertMon
    class Cert
        attr_accessor :url, :certificate, :error, :last_check

        def certificate_get
            client = HTTPClient.new
            begin
                r = client.get( self.url )
            rescue OpenSSL::SSL::SSLError => e
                client.ssl_config.verify_mode=OpenSSL::SSL::VERIFY_NONE
                r = client.get( self.url )
                self.error = e
            end
            self.certificate = r.peer_cert
            self.last_check = Time.now.iso8601
        end

        def valid_for_days?
            return ((self.certificate.not_after - Time.now) / (3600*24)).to_i
        end

        def is_https?
            if self.url.start_with?("https://")
                self.url.chomp!
            else
                return false
            end
        end
    
        def export
            r = {
                url: self.url,
                subject: self.certificate.subject,
                valid_days: self.valid_for_days?,
                last_check: self.last_check
            }
            r[:error] = self.error.message if self.error
            return r
        end
    end
end


out = []

File.readlines(urllist).each do |url|
    c = CertMon::Cert.new
    c.url = url
    if c.is_https?
        cert = c.certificate_get
        vd = c.valid_for_days?
        if vd.to_i <= days.to_i
            out << c.export
        end
    end
end

puts out.to_json
