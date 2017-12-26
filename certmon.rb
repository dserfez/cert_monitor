require 'httpclient'
require 'json'

urllist = ARGV[0]
days = ARGV[1]


if urllist.nil? or days.nil?
    puts "This tool requires 2 parameters: <url_list_file> <days>"
    raise
end


def certificate_get(url)
    c = HTTPClient.new
    r = c.get( url )
    return r.peer_cert
end

def valid_for_days?(cert)
    #cert = certificate_get(url)
    #return ((a.not_after - Time.now) / (3600*24)).round
    return ((cert.not_after - Time.now) / (3600*24)).to_i
end


#outlist = "#{urllist}.out"

out = []

File.readlines(urllist).each do |url|
    if url.start_with?("https://")
        url.chomp!
        cert = certificate_get(url)
        vd = valid_for_days?(cert)
        if vd.to_i <= days.to_i
            out << {url: url, subject: cert.subject, valid_days: vd, last_check: Time.now.iso8601}
            #puts {url: url, subject: cert.subject, valid_days: vd}.to_json
        end
    end
end

#outf = File.open(outlist, "w")
#outf.write(out.to_json)
#outf.close

puts out.to_json
