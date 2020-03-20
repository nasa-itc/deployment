module Configuration
    class Parser
        def initialize(lines)
            #puts "initialize"
            @lines = []
            lines.each do |line|
                @lines.push(line.gsub(/#.*/, ""))
            end
            #puts @lines
        end
        def get_string(name)
            #puts "get_string"
            #puts @lines
            regex = Regexp.new(/^\s*#{name}\s*:/i)
            matches = @lines.grep(regex)
            if (matches.empty?)
                return nil
            else
                value = matches[0].split(":")[1].strip
                #puts value
                return value
            end
        end
        def get_boolean(name)
            #puts "get_boolean"
            print "Key=#{name}, "
            value = get_string(name)
            if ((value != nil) and (value.upcase == "TRUE"))
                puts "Value=true"
                return true
            else
                puts "Value=false"
                return false
            end
        end
        def get_string_in_list(name, list, default)
            print "Key=#{name}, "
            value = get_string(name)
            if (value != nil)
                found = list.grep(value)
                if (found.empty?)
                    puts "Value=#{default}"
                    return default
                else
                    puts "Value=#{value}"
                    return value
                end
            else
                puts "Value=#{default}"
                return default
            end
        end
    end
end
