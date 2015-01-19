require 'fileutils'
def detect_heading(code,extension)
  case extension
  when ".rb"
    if code[0] == "#"
      code = "<h1>#{code[1..-1]}</h1>"
    else
      code = "<p>#{code}</p>"
    end
  when ".js"
    if code[0..1] == "//"
      code = "<h1>#{code[2..-1]}</h1>"
    end
  end
  return code
end

def generate_html_wrapper(code) 
  return "
  <html>
    <head>
      <style>
        body {font-family: Tahoma, Geneva, sans-serif; font-size: 14px; line-height: 20px;}
        div.container{ width: 1040px; margin: 0 auto; }
        h1 {font-size: 20px; color: #777;text-transform: capitalize; font-family: 'Open Sans', sans-serif;}
        p {color: #777;background: #EEE; margin: 0px; padding: 7px 10px;}
      </style>
    </head>
    <body>
      <div class='container'>
        #{code}
      </div>
    </body>
  </html>"
end
# Read all files from a directory
# a = Dir.glob("**/*")
output_directory = "documentation"
snippet_directory = "snippets"
files = Dir["#{snippet_directory}/**/*"]
FileUtils.mkdir_p output_directory
files.each do |file|
  if File.file?(file)
    html = ""
    extension = file[/\.[0-9a-z]+$/]
    File.open(file, "r").each_line do |line|
      # detect if first charachter is a comment depending on the type of file
      # ruby -> #
      unless line.strip.empty?
        line = detect_heading(line,extension)
        html = "#{html}#{line}"
      end
    end
    html = generate_html_wrapper(html)
    file.gsub!(snippet_directory,output_directory)
    file.gsub!(extension,".html")
    file = File.new(file,"w")
    file.write(html)
    file.close
  else
    FileUtils.mkdir_p file.gsub(snippet_directory,output_directory)
  end
end


