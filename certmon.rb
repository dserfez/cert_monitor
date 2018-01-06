require 'httpclient'
require 'json'
require 'pry'
require 'concurrent'

urllist = ARGV[0]
days = ARGV[1]

DEBUG = 0

CONCURRENT = 10

$VERBOSE = nil # This fixes HTTPClient unknown response headers being printed to output and invalidating JSON 

if urllist.nil? or days.nil?
    puts "This tool requires 2 parameters: <url_list_file> <days>"
    raise
end

module CertMon
    class Cert
        attr_accessor :url, :certificate, :error, :valid_days, :last_check

        def valid_for_days?
            return ((@certificate.not_after - Time.now) / (3600*24)).to_i
        end

        def certificate_get
            client = HTTPClient.new
            begin
                r = client.get( @url )
            rescue OpenSSL::SSL::SSLError => e
                client.ssl_config.verify_mode=OpenSSL::SSL::VERIFY_NONE
                r = client.get( @url )
                @error = e
            end
            @certificate = r.peer_cert
            @valid_days = valid_for_days?
            @last_check = Time.now.iso8601
        end

        def is_https?
            if @url.start_with?("https://")
                return true
            else
                return false
            end
        end
    
        def export
            r = {
                url: @url,
                subject: @certificate.subject.to_s,
                valid_until: @certificate.not_after.iso8601,
                valid_days: @valid_days,
                last_check: @last_check
            }
            r['error'] = @error.message if @error
            return r
        end

    end

end

out = []
ps = []

entries = File.readlines(urllist)

until entries.empty? and ps.empty?
  
  if ps.count < CONCURRENT
    unless entries.empty?
      url = entries.shift.chomp
      STDERR.puts "URL: #{url}" unless DEBUG == 0
      ps << Concurrent::Promise.execute{ 
        c = CertMon::Cert.new
        c.url = url
        if c.is_https?
            STDERR.puts "GETTING CERT FOR: #{url}" unless DEBUG == 0
            cert = c.certificate_get
            if c.valid_days.to_i <= days.to_i
                out << c.export
            end
        end
        STDERR.puts "DONE: #{c.url}" unless DEBUG == 0
      }
    end

    ps.each {
      |p|
      ps = ps - [p] if p.complete?
      #p "#{url} #{p.state}"
      #p "#{url} #{p.state} #{p.reason}" if p.rejected?
      ##if p.fulfilled?
        ##ps = ps - [p]
        #out << p.value
      ##elsif p.rejected?
        ##ps = ps - [p]
        #out << p.reason
      ##end

    }
  end

sleep 0.01
end

#        c = CertMon::Cert.new
#        c.url = url
#        if c.is_https?
#            cert = c.certificate_get
#            if c.valid_days.to_i <= days.to_i
#                out << c.export
#            end
#        end
    


puts out.to_json

#File.readlines(urllist).each do |url|
#    c = CertMon::Cert.new
#    c.url = url
#    if c.is_https?
#        cert = c.certificate_get
#        vd = c.valid_for_days?
#        if vd.to_i <= days.to_i
#            out << c.export
#        end
#    end
#end

#puts c.out.to_json
