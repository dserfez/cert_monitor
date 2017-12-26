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


def certificate_get(url)
    c = HTTPClient.new
    begin
        r = c.get( url )
    rescue OpenSSL::SSL::SSLError => e
        c.ssl_config.verify_mode=OpenSSL::SSL::VERIFY_NONE
        r = c.get( url )
    end
    return r.peer_cert, e
end

def valid_for_days?(cert)
    return ((cert.not_after - Time.now) / (3600*24)).to_i
end


#outlist = "#{urllist}.out"

out = []

File.readlines(urllist).each do |url|
    if url.start_with?("https://")
        url.chomp!
        cert, error = certificate_get(url)
        #binding.pry
        vd = valid_for_days?(cert)
        if vd.to_i <= days.to_i
            if error.nil?
                out << {url: url, subject: cert.subject, valid_days: vd, last_check: Time.now.iso8601}
            else
                out << {url: url, subject: cert.subject, valid_days: vd, last_check: Time.now.iso8601, error: "#{error.message}"}
            end
            #puts {url: url, subject: cert.subject, valid_days: vd}.to_json
        end
    end
end

#outf = File.open(outlist, "w")
#outf.write(out.to_json)
#outf.close

puts out.to_json
