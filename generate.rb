require 'fileutils'
require 'byebug'
$output_directory = "documentation"
$snippet_directory = "snippets"
$files = Array.new

# document snippets contained within different file types

def detect_comments(code,extension)
  flag=false
  case extension
  when ".rb"
    if code[0] == "#"
      code = code[1..-1]
      flag = true
    end
  when ".js"
    if code[0..1] == "//"
      code = code[2..-1]
      flag = true
    end
  when ".py"
    if code[0] == "#"
      code = code[1..-1]
      flag = true
    end
  end
  return code,flag
end

def detect_heading(code,extension)
  code,flag = detect_comments(code,extension)
  if flag
    if code[0] == "#"
      code = code.gsub("#","")
      code = "<h1>#{code}</h1>"
    elsif code[0] == "*"
      code = code.gsub("*","")
      code = "<li>#{code}</li>"
    else
      code = "<p>#{code}</p>"
    end
  else
    code = "<p class='code'>#{code}</p>"
  end
  return code
end

def generate_html_wrapper(code,sidebar) 
  return "
  <html>
    <head>
      <style>
        body {position: relative; font-family: 'Helvetica Neue', Helvetica, 'Segoe UI', Arial, freesans, sans-serif; font-size: 14px; line-height: 20px; margin: 0px;}
        div.container{ width: 760px; margin: 0 auto; padding: 10px 30px; border-left: 1px solid #EEE; border-right: 1px solid #EEE; color: #333;}
        h1 {font-size: 36px; color: #333;text-transform: capitalize; border-bottom: 1px solid #EEE; padding: 20px 30px; margin: 0px -30px;}
        p {color: #333; }
        p.code{ background: #f7f7f7; margin: 0px; padding: 7px 10px; font: 12px Consolas, 'Liberation Mono', Menlo, Courier, monospace;}
        div.sidebar{position: absolute; top: 75px; left: 0px;}
      </style>
    </head>
    <body>
      #{sidebar}
      <div class='container'>
        #{code}
      </div>
    </body>
  </html>"
end

def iterate_files
  all_files = Dir["#{$snippet_directory}/**/*"]
  FileUtils.mkdir_p $output_directory
  all_files.each do |file|
    if File.file?(file)
      $files.push(file)
    else
      FileUtils.mkdir_p file.gsub($snippet_directory,$output_directory)
    end
  end

end

def generate_navigation(current_file)
  navigation = ""
  $files.each do |file|
    extension = file[/\.[0-9a-z]+$/]
    href = "#{Dir.pwd}/#{file.gsub(extension,'.html').gsub($snippet_directory,$output_directory)}"
    title = file.split("/").last.split(".").first.gsub(/[^0-9A-Za-z]/, ' ').capitalize
    if file == current_file
      navigation+="<a class='current' href='#{href}'>#{title}</a><br/>"
    else
      # extract end name
      navigation+="<a href='#{href}'>#{title}</a><br/>"
    end
  end
  navigation = "<div class='sidebar'>#{navigation}</div>"
  return navigation
end

iterate_files
$files.each do |file|
  html = ""
  extension = file[/\.[0-9a-z]+$/]
  File.open(file, "r").each_line do |line|
    unless line.strip.empty?
      line = detect_heading(line,extension)
      html = "#{html}#{line}"
    end
  end
  sidebar = generate_navigation(file)
  html = generate_html_wrapper(html,sidebar)
  file.gsub!($snippet_directory,$output_directory)
  file.gsub!(extension,".html")
  file = File.new(file,"w")
  file.write(html)
  file.close
end


