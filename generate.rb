require 'fileutils'
require 'byebug'
$output_directory = "documentation"
$snippet_directory = "snippets"
$files = Array.new

# document snippets contained within different file types
# do it using class and creating a new class variable that sets the title etc.

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
      code = "<h2>#{code}</h2>"
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

def generate_html_wrapper(code,sidebar,title) 
  return "
  <html>
    <head>
      <title>DocSnip</title>
      <script src='https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js'></script>
      <style>
        body {position: relative; font-family: 'Helvetica Neue', Helvetica, 'Segoe UI', Arial, freesans, sans-serif; font-size: 14px; line-height: 20px; margin: 0px;}
        div.container{ width: 760px; margin: 0 auto; padding: 10px 30px; border-left: 1px solid #EEE; border-right: 1px solid #EEE; color: #333; min-height: 100%;}
        h1 {font-size: 36px; color: #333;text-transform: capitalize; border-bottom: 1px solid #EEE; padding: 20px 30px; margin: 0px -30px;}
        p {color: #333; }
        p.code{ background: #f7f7f7; margin: 0px; padding: 7px 10px; font: 12px Consolas, 'Liberation Mono', Menlo, Courier, monospace;}
        div.sidebar{position: absolute; top: 75px; left: 0px; padding: 0px 0px; }
        div.sidebar a{ color: #BBB; text-decoration: none;border-bottom: 1px solid #EEE; width: 200px; display: block; padding: 10px; }
        div.sidebar a:hover{ color: #777; text-decoration: none;}
        div.sidebar a.current{ color: #555; text-decoration: none; background: #F7F7F7; border-right: 1px solid #EEE;}
        a.show-search{ position: absolute; visibility: hidden;}
        input#search{padding: 8px 20px; font-size: 18px; margin: 10px; width: 213px; outline: none; border: 1px solid #DDD; -webkit-border-radius: 20px; -moz-border-radius: 20px; border-radius: 20px;}
      </style>
    </head>
    <body>
      <div class='sidebar'><input id='search' type='text'>#{sidebar}</div>
      <div class='container'>
        <h1>#{title}</h1>
        #{code}
      </div>
      <script>
        $(document).ready(function () {
          $.extend($.expr[':'], {
            'containsIN': function(elem, i, match, array) {
            return (elem.textContent || elem.innerText || '').toLowerCase().indexOf((match[3] || '').toLowerCase()) >= 0;
            }
          })
          $('#search').keyup(function (e) {
            var filter = $(this).val();
            $('div.sidebar a').removeClass('show-search');
            if (filter.length > 3){
              $('div.sidebar a:not(:containsIN('+filter+'))').addClass('show-search');
            }
           });
        });
      </script>

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
      navigation+="<a class='current' href='#{href}'>#{title}</a>"
    else
      # extract end name
      navigation+="<a href='#{href}'>#{title}</a>"
    end
  end
  return navigation
end

FileUtils.rm_rf($output_directory)
iterate_files
$files.each do |file|
  html = ""
  extension = file[/\.[0-9a-z]+$/]
  f = File.open(file, "r")
  f.each_line do |line|
    unless line.strip.empty?
      line = detect_heading(line,extension)
      html = "#{html}#{line}"
    end
  end
  f.close
  sidebar = generate_navigation(file)
  title = file.split("/").last.split(".").first.gsub(/[^0-9A-Za-z]/, ' ').capitalize
  html = generate_html_wrapper(html,sidebar,title)
  file.gsub!($snippet_directory,$output_directory)
  file.gsub!(extension,".html")
  file = File.new(file,"w")
  file.write(html)
  file.close
end


