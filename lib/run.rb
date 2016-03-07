require "watir-webdriver"
require 'roo-xls'
require "headless"

browser = Watir::Browser.new

config = YAML.load(File.read("config.yml"))
browser.goto "http://timetracker.bairesdev.com"

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
    browser.link(text: "New record").click
    browser.link(title: report[:date].strftime("%B %-d")).click
    browser.select_list(id: "ctl00_ContentPlaceHolder_idProyectoDropDownList").select("iSeatz - iSeatz")
    browser.select_list(id: "ctl00_ContentPlaceHolder_idTipoAsignacionDropDownList").select("Software Development")
    browser.text_field(id: "ctl00_ContentPlaceHolder_TiempoTextBox").set report[:hours]
    browser.textarea(id: "ctl00_ContentPlaceHolder_DescripcionTextBox").set work_description(report, config)
    browser.select_list(id: "ctl00_ContentPlaceHolder_idFocalPointClientDropDownList").select(config["focal_point"])
    browser.button(id: "ctl00_ContentPlaceHolder_btnAceptar").click
  end
  puts "-"*50
  puts "Renaming.. #{file}"
  puts "-"*50
  File.rename(file, file + ".finished")
end

browser.close
