require "watir-webdriver"
require 'roo-xls'
require "headless"

config = YAML.load(File.read("config.yml"))

begin
  browser = Watir::Browser.new config["browser"].to_sym
rescue
  puts "No valid browser in config file, using default"
  browser = Watir::Browser.new
end

browser.goto "http://timetracker.bairesdev.com"

puts "Visiting the site..."

browser.text_field(id: "ctl00_ContentPlaceHolder_UserNameTextBox").set config["user"]
browser.text_field(id: "ctl00_ContentPlaceHolder_PasswordTextBox").set config["password"]

browser.button(id: "ctl00_ContentPlaceHolder_LoginButton").click

if browser.text.include? "Welcome"
  puts "You're in!!!"
else
  puts "Sorry"
end

def worked_hours(file)
  xls = Roo::Spreadsheet.open(file)
  sheet = xls.sheet("Worklogs")
  sheet.parse(
    date: /Work date/,
    hours: /Hours/,
    description: /Work Description/,
    summary: /Issue summary/
  )
end

def work_description(report, config)
  if config["add_issue_summary"]
    "#{report[:summary]}: #{report[:description]}"
  else
    "#{report[:description]}"
  end
end

Dir.glob(File.join(config["directory"], "*.xls")).each do |file|
  puts "="*50
  puts "Processing.... #{file}"
  puts "="*50
  worked_hours(file).each do |report|
    next if report[:date].is_a? String
    next if report[:date].nil? 
    browser.link(text: "Track Hours").click
    browser.text_field(id: "ctl00_ContentPlaceHolder_txtFrom").set report[:date].strftime("%d/%m/%Y")
    browser.select_list(id: "ctl00_ContentPlaceHolder_idProyectoDropDownList").select("iSeatz - iSeatz")
    browser.select_list(id: "ctl00_ContentPlaceHolder_idTipoAsignacionDropDownList").select("Software Development")
    Watir::Wait.until { browser.text_field(id: "ctl00_ContentPlaceHolder_TiempoTextBox").exist? }  
    browser.text_field(id: "ctl00_ContentPlaceHolder_TiempoTextBox").set report[:hours]
    browser.textarea(id: "ctl00_ContentPlaceHolder_DescripcionTextBox").set work_description(report, config)
    sleep(1)
    browser.select_list(id: "ctl00_ContentPlaceHolder_idFocalPointClientDropDownList").select(config["focal_point"])
    sleep(1)
    browser.textarea(id: "ctl00_ContentPlaceHolder_DescripcionTextBox").set work_description(report, config)
    browser.select_list(id: "ctl00_ContentPlaceHolder_idTipoAsignacionDropDownList").select("Software Development")
    browser.text_field(id: "ctl00_ContentPlaceHolder_TiempoTextBox").set report[:hours]
    browser.button(id: "ctl00_ContentPlaceHolder_btnAceptar").click
  end
  puts "-"*50
  puts "Renaming.. #{file}"
  puts "-"*50
  File.rename(file, file + ".finished")
end

browser.close
